from dataclasses import dataclass
import json
import os
import sys

from cloudflare import Cloudflare

token: str | None = os.environ.get('CLOUDFLARE_API_TOKEN')
new_settings_path: str | None = os.environ.get('CLOUDFLARE_NEW_DNS_SETTINGS')

if token is None:
    print('Must provide token with CLOUDFLARE_API_TOKEN')
    exit()
elif new_settings_path is None:
    print('Must provide new settings with CLOUDFLARE_NEW_DNS_SETTINGS')
    exit()

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

    @classmethod
    def from_nix(cls, type: str, domain: str, value: any) -> Record:
        match type:
            case 'A' | 'AAAA' | 'MX':
                return Record(
                    id=None,
                    name=domain,
                    type=type,
                    content=value,
                )
            case 'CNAME':
                return Record(
                    id=None,
                    name=value[0] + '.' + domain,
                    type=type,
                    content=value[1],
                )
            case 'TXT':
                return Record(
                    id=None,
                    name=value['name'] + ('.' if value['name'] != '' else '') + domain,
                    type=type,
                    content=value['content'],
                )
            case _:
                print(f'unrecognized record type {type} for {domain} with value {value}')

    @classmethod
    def from_cf(cls, entry: any) -> Record:
        return Record(id=entry.id, name=entry.name, type=entry.type, content=entry.content)

    @property
    def without_id(self) -> Record:
        return Record(
            id=None,
            name=self.name,
            type=self.type,
            content=self.content,
        )

with open(new_settings_path) as file:
    data: dict[str, any] = json.load(file)

new_settings: dict[str, tuple[Record, ...]] = {
    domain:
        [Record.from_nix('A', domain, record) for record in entry['A']] +
        [Record.from_nix('AAAA', domain, record) for record in entry['AAAA']] +
        [Record.from_nix('CNAME', domain, record) for record in entry['CNAME'].items()] +
        [Record.from_nix('MX', domain, record) for record in entry['MX']] +
        [Record.from_nix('TXT', domain, record) for record in entry['TXT']]
    for domain, entry in data.items()
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
                ttl=1,
                proxied=True,
            )
