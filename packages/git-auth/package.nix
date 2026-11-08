# Time-limited git SSH auth + commit signing for unattended agents.
#
# Self-contained so it works with Home Manager, a NixOS system module, or a
# bare `nix profile install`: every path resolves against $HOME at run time
# and `git-auth login` starts its own ssh-agent, so no service is needed.
# Wire it into git by including share/git-auth/git-auth.inc (see README.md).
{
  lib,
  writeShellApplication,
  writeText,
  symlinkJoin,
  openssh,
  coreutils,
  opReference ? "op://Private/Agent Git Key/private key?ssh-format=openssh",
  opCommand ? "op",
  lifetime ? "24h",
}: let
  # Kept in sync with the include file below, which uses ~/ (git expands it).
  paths = ''
    socket="$HOME/.ssh/git-auth-agent.sock"
    state="$HOME/.local/state/git-auth"
  '';

  # Fails loudly instead of letting git fall through to a 1Password prompt
  # nobody is around to approve.
  requireSession = ''
    ${paths}
    if ! SSH_AUTH_SOCK="$socket" ssh-add -l >/dev/null 2>&1 || [ ! -s "$state/key.pub" ]; then
      echo "git-auth: no session key loaded (expired?). Run 'git-auth login' (or 'git-auth login --remote <host>')." >&2
      exit 1
    fi
  '';

  gitAuthSsh = writeShellApplication {
    name = "git-auth-ssh";
    runtimeInputs = [openssh];
    text = ''
      ${requireSession}
      # Command-line -o wins over IdentityAgent from ~/.ssh/config.
      exec ssh \
        -o IdentityAgent="$socket" \
        -o IdentitiesOnly=yes \
        -o IdentityFile="$state/key.pub" \
        "$@"
    '';
  };

  gitAuthSign = writeShellApplication {
    name = "git-auth-sign";
    runtimeInputs = [openssh];
    text = ''
      ${requireSession}
      SSH_AUTH_SOCK="$socket" exec ssh-keygen "$@"
    '';
  };

  includeFile = writeText "git-auth.inc" (lib.generators.toGitINI {
    core.sshCommand = "${gitAuthSsh}/bin/git-auth-ssh";
    user.signingKey = "~/.local/state/git-auth/key.pub";
    commit.gpgSign = true;
    gpg = {
      format = "ssh";
      ssh.program = "${gitAuthSign}/bin/git-auth-sign";
    };
  });

  gitAuth = writeShellApplication {
    name = "git-auth";
    runtimeInputs = [openssh coreutils];
    text = ''
      ${paths}
      ref="${opReference}"
      op="${opCommand}"

      usage() {
        cat <<EOF
      Usage: git-auth <command>

        login [-t LIFETIME] [--remote HOST]
                     Load the agent key from 1Password into the session agent
                     (default lifetime ${lifetime}). With --remote, push it into
                     HOST's session agent over ssh instead.
        status       Show whether a session key is loaded and when it expires.
        logout       Remove the session key.
        exec CMD...  Run CMD with git using the session key regardless of path.
      EOF
      }

      to_seconds() {
        local v="$1"
        case "$v" in
          *d) echo $(( ''${v%d} * 86400 )) ;;
          *h) echo $(( ''${v%h} * 3600 )) ;;
          *m) echo $(( ''${v%m} * 60 )) ;;
          *s) echo "''${v%s}" ;;
          *) echo "$v" ;;
        esac
      }

      # Started on demand; dies with the machine, which is when the key
      # should be gone anyway.
      ensure_agent() {
        local rc=0
        SSH_AUTH_SOCK="$socket" ssh-add -l >/dev/null 2>&1 || rc=$?
        if [ "$rc" -eq 2 ]; then
          mkdir -p "$(dirname "$socket")"
          rm -f "$socket"
          ssh-agent -a "$socket" >/dev/null
        fi
      }

      read_key() {
        if ! command -v "$op" >/dev/null 2>&1; then
          echo "git-auth: 1Password CLI '$op' not found here; run 'git-auth login --remote $(hostname)' from a machine that has it." >&2
          exit 1
        fi
        "$op" read "$ref"
      }

      # Shared by local login and the remote side of --remote. Reads the
      # private key on stdin; it only ever lives in the agent's memory.
      load_key() {
        local lifetime="$1"
        ensure_agent
        mkdir -p "$state"
        SSH_AUTH_SOCK="$socket" ssh-add -D >/dev/null 2>&1 || true
        SSH_AUTH_SOCK="$socket" ssh-add -q -t "$(to_seconds "$lifetime")" -
        # The agent holds only this key now, so its public half is the signing key.
        SSH_AUTH_SOCK="$socket" ssh-add -L > "$state/key.pub"
        echo $(( $(date +%s) + $(to_seconds "$lifetime") )) > "$state/expires"
        echo "git-auth: session key loaded on $(hostname) for $lifetime"
      }

      cmd="''${1:-}"
      shift || true

      case "$cmd" in
        login)
          lifetime="${lifetime}"
          remote=""
          while [ $# -gt 0 ]; do
            case "$1" in
              -t) lifetime="$2"; shift 2 ;;
              --remote) remote="$2"; shift 2 ;;
              *) usage; exit 1 ;;
            esac
          done
          if [ -n "$remote" ]; then
            # Lifetime is meant to expand locally; %q keeps it a single remote arg.
            # shellcheck disable=SC2029
            read_key | ssh "$remote" "git-auth _load $(printf %q "$lifetime")"
          else
            read_key | load_key "$lifetime"
          fi
          ;;
        _load)
          load_key "$1"
          ;;
        status)
          if SSH_AUTH_SOCK="$socket" ssh-add -l >/dev/null 2>&1; then
            fp="$(SSH_AUTH_SOCK="$socket" ssh-add -l)"
            left=$(( $(cat "$state/expires" 2>/dev/null || echo 0) - $(date +%s) ))
            if [ "$left" -gt 0 ]; then
              printf 'git-auth: loaded %s (expires in %dh%02dm)\n' "$fp" $((left / 3600)) $((left % 3600 / 60))
            else
              echo "git-auth: loaded $fp"
            fi
          else
            echo "git-auth: no session key loaded"
            exit 1
          fi
          ;;
        logout)
          SSH_AUTH_SOCK="$socket" ssh-add -D >/dev/null 2>&1 || true
          rm -f "$state/expires"
          echo "git-auth: session key removed"
          ;;
        exec)
          [ $# -gt 0 ] || { usage; exit 1; }
          export GIT_CONFIG_COUNT=1
          export GIT_CONFIG_KEY_0=include.path
          export GIT_CONFIG_VALUE_0="${includeFile}"
          exec "$@"
          ;;
        *)
          usage
          [ -z "$cmd" ] || [ "$cmd" = help ] || [ "$cmd" = -h ] || exit 1
          ;;
      esac
    '';
  };
in
  symlinkJoin {
    name = "git-auth";
    paths = [gitAuth gitAuthSsh gitAuthSign];
    postBuild = ''
      install -Dm644 ${includeFile} $out/share/git-auth/git-auth.inc
    '';
    passthru.includeFile = includeFile;
    meta = {
      description = "Time-limited git SSH auth and commit signing for unattended agents";
      mainProgram = "git-auth";
    };
  }
