from dataclasses import dataclass
import json
import os
import sys

from cloudflare import Cloudflare

token_path: str | None = os.environ.get('CLOUDFLARE_API_TOKEN_FILE')
new_settings_path: str | None = os.environ.get('CLOUDFLARE_NEW_DNS_SETTINGS')

if not token_path:
    sys.exit('Must provide token file with CLOUDFLARE_API_TOKEN_FILE')
elif new_settings_path is None:
    sys.exit('Must provide new settings with CLOUDFLARE_NEW_DNS_SETTINGS')

try:
    with open(token_path) as file:
        token = file.read().strip()
except OSError:
    sys.exit(f'Could not read token file: {token_path}')

if not token:
    sys.exit(f'Token file is empty: {token_path}')

dry_run: bool = '--dry-run' in sys.argv

client: Cloudflare = Cloudflare(
    api_token=token,
)

@dataclass(frozen=True, slots=True)
class Record:
    id: str | None
    name: str
    type: str
    content: str
    proxied: bool
    ttl: int
    priority: int | None

    @classmethod
    def from_nix(cls, type: str, zone: str, name: str, value: dict) -> Record:
        return Record(
            id=None,
            name=zone if name == '@' else f'{name}.{zone}',
            type=type,
            content=value['content'],
            proxied=value.get('proxied', False),
            ttl=value.get('ttl', 1),
            priority=value.get('priority', 10) if type == 'MX' else None,
        )

    @classmethod
    def from_cf(cls, entry: any) -> Record:
        return Record(
            id=entry.id,
            name=entry.name,
            type=entry.type,
            content=entry.content,
            proxied=entry.proxied,
            ttl=entry.ttl,
            priority=getattr(entry, 'priority', None),
        )

    @property
    def without_id(self) -> Record:
        return Record(
            id=None,
            name=self.name,
            type=self.type,
            content=self.content,
            proxied=self.proxied,
            ttl=self.ttl,
            priority=self.priority,
        )

with open(new_settings_path) as file:
    data: dict[str, any] = json.load(file)

new_settings: dict[str, tuple[Record, ...]] = {
    zone: tuple(
        Record.from_nix(type, zone, name, record)
        for name, types in names.items()
        for type, records in types.items()
        for record in records
    )
    for zone, names in data.items()
}

for name, entries in new_settings.items():
    zones = client.zones.list(name=name)
    if not zones.result:
        print(f'zone {name} could not be found with the API token')
        continue

    zone = zones.result[0]

    current_settings: tuple[Record, ...] = tuple([
        Record.from_cf(entry)
        for entry
        in client.dns.records.list(zone_id=zone.id).result
    ])

    current_no_id: set[Record] = set(record.without_id for record in current_settings)

    add: tuple[Record, ...] = tuple([ record for record in entries if record not in current_no_id ])
    remove: tuple[Record, ...] = tuple([ record for record in current_settings if record.without_id not in entries])

    if dry_run:
        for name, list in [('add', add), ('remove', remove)]:
            print(f'{name}:')
            for item in list:
                print(f'{item.type} {item.name} {item.content}')
    else:
        for record in remove:
            client.dns.records.delete(
                zone_id=zone.id,
                dns_record_id=record.id,
            )

        for record in add:
            client.dns.records.create(
                zone_id=zone.id,
                type=record.type,
                name=record.name,
                content=record.content,
                ttl=record.ttl,
                proxied=record.proxied,
                priority=record.priority,
            )
