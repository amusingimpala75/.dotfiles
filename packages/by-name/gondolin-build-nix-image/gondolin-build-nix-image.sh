usage() {
  cat <<'EOF'
Usage: gondolin-build-nix-image [--devshell NAME] [--name NAME]

Build a Gondolin image for the flake containing the current directory.
The image is written to @output@/<name>, where <name> defaults to the flake
root's directory name. NAME selects the flake devShell (default: default); it
may also be a fully-qualified devShell attribute such as
 devShells.x86_64-linux.ci.
EOF
}

die() {
  printf '%s\n' "gondolin-build-nix-image: $*" >&2
  exit 1
}

devshell=default
image_name=
while [ "$#" -gt 0 ]; do
  case "$1" in
    --devshell)
      [ "$#" -ge 2 ] || die "--devshell requires a value"
      devshell=$2
      shift 2
      ;;
    --name)
      [ "$#" -ge 2 ] || die "--name requires a value"
      image_name=$2
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown option: $1"
      ;;
  esac
done

project_root=$PWD
while [ "$project_root" != / ] && [ ! -e "$project_root/flake.nix" ]; do
  project_root=$(dirname "$project_root")
done
[ -e "$project_root/flake.nix" ] || die "could not find flake.nix above $PWD"
project_root=$(cd "$project_root" && pwd -P)

if [ -z "$image_name" ]; then
  image_name=$(basename "$project_root")
fi
case "$image_name" in
  ""|*[!A-Za-z0-9._-]*)
    die "image names may only contain letters, digits, ., _, and -"
    ;;
esac

# Relative output paths are deliberately rooted at HOME: the image cache is
# global rather than being created inside the project that supplied the flake.
image_dir="@output@/$image_name"
case "$image_dir" in
  /*) ;;
  *) image_dir="$HOME/$image_dir" ;;
esac
# Match Pi's getAgentDir(): PI_CODING_AGENT_DIR overrides ~/.pi/agent.
registry="${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}/gondolin-images.json"
temporary_dir=$(mktemp -d)
image_build_parent=
remove_directory() {
  # Builds and Nix copies can preserve read-only directory modes. Restore
  # owner write permission before removing their temporary output.
  chmod -R u+w "$1" 2>/dev/null || true
  rm -rf "$1"
}
cleanup() {
  remove_directory "$temporary_dir"
  if [ -n "$image_build_parent" ]; then
    remove_directory "$image_build_parent"
  fi
}
trap cleanup EXIT

case "$(uname -m)" in
  aarch64|arm64) arch=aarch64 ;;
  x86_64|amd64) arch=x86_64 ;;
  *) die "unsupported host architecture: $(uname -m)" ;;
esac

# A bare flake fragment resolves packages before devShells.  Resolve named
# shells explicitly so the default is devShells.<system>.default, while still
# accepting an already-qualified devShells.<system>.<name> argument.
case "$devshell" in
  devShells.*) devshell_attr=$devshell ;;
  *)
    system=$(nix eval --impure --raw --expr builtins.currentSystem)
    devshell_attr="devShells.$system.$devshell"
    ;;
esac
flake_ref="$project_root#$devshell_attr"

# Copy the complete dev-shell closure into a chroot Nix store. This is
# intentionally done before serialising print-dev-env: every store path
# referenced by PATH is available in the guest without exposing the host's
# store. A chroot store rooted at $temporary_dir places paths under
# $temporary_dir/nix/store, preserving their guest location of /nix/store.
devshell_path=$(nix build --no-link --print-out-paths "$flake_ref")
# The chroot store is not a binary cache. Dev-shell closures can include local
# derivations and therefore do not necessarily carry binary-cache signatures.
# The source was just built/resolved from the user's local store, so bypass
# destination signature checks while staging it into the image.
nix copy --no-check-sigs --to "$temporary_dir" "$devshell_path"
store_root="$temporary_dir/nix/store"
# Gondolin stages postBuild.copy recursively. Its staging implementation must
# create child paths after each copied directory, so source directories cannot
# retain Nix's read-only mode while it performs that copy.
chmod -R u+w "$store_root"

nix print-dev-env --json "$flake_ref" > "$temporary_dir/dev-env.json"
python3 - \
  "$temporary_dir/dev-env.json" \
  "$temporary_dir/gondolin-build.json" \
  "$arch" \
  "$store_root" <<'PY'
import json
import sys

dev_environment, config_path, arch, store_root = sys.argv[1:]
with open(dev_environment, encoding="utf-8") as source:
    variables = json.load(source).get("variables", {})

environment = {
    name: definition["value"]
    for name, definition in variables.items()
    if definition.get("type") == "exported" and isinstance(definition.get("value"), str)
}
# These values are meaningful in the host build environment, not in the guest
# where /workspace is the project mount. In particular, Nix dev shells provide
# HOME=/homeless-shelter while evaluating package builds; retain Alpine's guest
# user home instead.
environment.pop("HOME", None)
environment.pop("PWD", None)
environment.pop("OLDPWD", None)
# Gondolin applies env.PATH directly, bypassing Alpine's profile scripts. Keep
# the dev-shell tools first, but retain the conventional Alpine command paths.
alpine_path = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
if environment.get("PATH"):
    environment["PATH"] = f'{environment["PATH"]}:{alpine_path}'
else:
    environment["PATH"] = alpine_path
environment["NIX_CONFIG"] = (
    "experimental-features = nix-command flakes pipe-operators\\n"
    "build-users-group ="
)

config = {
    "arch": arch,
    "distro": "alpine",
    "alpine": {
        "version": "3.24.2",
        "kernelPackage": "linux-virt",
        "kernelImage": "vmlinuz-virt",
        "rootfsPackages": [
            "linux-virt",
            "bash",
            "openssh",
            "nix",
            "git",
            "jujutsu",
            "python3",
            "ripgrep",
        ],
    },
    "container": {"force": True},
    "rootfs": {"label": "gondolin-nix"},
    "env": environment,
    "postBuild": {
        "copy": [
            {"src": store_root, "dest": "/"},
            {"src": "@global-gitignore@", "dest": "/etc/gitignore"},
            {"src": "@agent-gitconfig@", "dest": "/etc/gitconfig"},
            {"src": "@agent-jj-config@", "dest": "/etc/jj/config.toml"},
        ],
        "commands": [
            "mkdir -p /etc/nix /root/.config/nix",
            "printf '%s\\n%s\\n' 'experimental-features = nix-command flakes pipe-operators' 'build-users-group =' > /etc/nix/nix.conf",
            "printf '%s\\n' 'experimental-features = nix-command flakes pipe-operators' 'build-users-group =' > /root/.config/nix/nix.conf",
        ],
    },
}
with open(config_path, "w", encoding="utf-8") as destination:
    json.dump(config, destination)
PY

mkdir -p "$(dirname "$image_dir")"
gondolin build --config "$temporary_dir/gondolin-build.json" --output "$image_dir"

# Keep the global directory -> image mapping consumed by pi-gondolin. A
# successful build also becomes the selected image for the next Pi session.
python3 - "$registry" "$project_root" "$image_name" "$image_dir" "$devshell" <<'PY'
import json
import os
import posixpath
import sys

registry_path, project_root, name, image_path, devshell = sys.argv[1:]
try:
    with open(registry_path, encoding="utf-8") as source:
        registry = json.load(source)
except FileNotFoundError:
    registry = {}
if not isinstance(registry, dict):
    registry = {}
images = registry.get("images")
if not isinstance(images, dict):
    images = {}
# Image rebuilds must not discard workspace-specific guest memory mounts that
# were configured by the Pi extension. Validate and canonicalise them here so a
# malformed hand-edited registry cannot produce an invalid Gondolin mount path.
previous = images.get(project_root)
memory_mounts = set()
if isinstance(previous, dict) and isinstance(previous.get("memoryMounts"), list):
    for mount in previous["memoryMounts"]:
        if not isinstance(mount, str):
            continue
        mount = mount.strip().replace("\\", "/")
        if not mount or "\0" in mount or mount.startswith("/"):
            continue
        mount = posixpath.normpath(mount)
        if mount in (".", "..") or mount.startswith("../"):
            continue
        memory_mounts.add(mount)

previous_image = images.get(project_root)
previous_revision = (
    previous_image.get("revision", 0)
    if isinstance(previous_image, dict) and isinstance(previous_image.get("revision", 0), int)
    else 0
)
image = {
    "name": name,
    "imagePath": image_path,
    "devShell": devshell,
    # Bump this even when the output path is reused. The Pi extension uses it
    # to replace an already-running VM with the rebuilt image.
    "revision": previous_revision + 1,
}
if memory_mounts:
    image["memoryMounts"] = sorted(memory_mounts)
images[project_root] = image
registry["version"] = 1
registry["images"] = images
# Building an image is an explicit request to use it. This also means the next
# Pi session selects a newly rebuilt project image without /gondolin-image.
registry["lastSelected"] = project_root

os.makedirs(os.path.dirname(registry_path), exist_ok=True)
temporary_path = f"{registry_path}.{os.getpid()}.tmp"
with open(temporary_path, "w", encoding="utf-8") as destination:
    json.dump(registry, destination, indent=2)
    destination.write("\n")
os.replace(temporary_path, registry_path)
PY

printf 'Built Gondolin image: %s\n' "$image_dir"
