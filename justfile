set positional-arguments

mode := "release"
install_dir := env_var("HOME") / ".local/bin"

default:
    @just --list

build m=mode:
    cargo build --profile {{ if m == "release" { "release" } else { "dev" } }} -p niri --bin niri

# Build and install the selected profile's niri binary to ~/.local/bin, replacing whatever
# is already running there (this is what the niri.service user-unit override at
# ~/.config/systemd/user/niri.service.d/override.conf points at — not /usr/local/bin or the
# apt-packaged /usr/bin/niri). A dated backup of the previous binary is kept alongside it.
# Does not restart niri: the new binary only takes effect on the next niri restart/relogin.
deploy-user m=mode: (build m)
    #!/usr/bin/env bash
    set -euo pipefail
    profile_dir="{{ if m == "release" { "release" } else { "debug" } }}"
    src="target/$profile_dir/niri"
    dest="{{install_dir}}/niri"
    mkdir -p "{{install_dir}}"
    if [[ -f "$dest" ]]; then
        # Second-resolution suffix: a same-day re-deploy must never silently clobber an
        # earlier backup from today (that already happened once and lost a genuine
        # pre-session build — see niri.bak-pre-session-3b9b6a20).
        backup="$dest.bak-$(date +%Y%m%d-%H%M%S)"
        cp "$dest" "$backup"
        echo "backed up previous binary to: $backup"
    fi
    # Not a plain overwrite: the destination may be the currently-running compositor's own
    # executable (ETXTBSY on open-for-write), so unlink first and create a fresh file.
    rm -f "$dest"
    cp "$src" "$dest"
    echo "installed: $dest ($("$dest" --version))"

# Validate a config file (default: the user's live niri config) against the just-built binary.
validate m=mode config=(env_var("HOME") / ".config/niri/config.kdl"): (build m)
    ./target/{{ if m == "release" { "release" } else { "debug" } }}/niri validate -c {{config}}

clean:
    cargo clean
