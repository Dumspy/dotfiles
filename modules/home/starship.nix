{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.home.starship;
in {
  options.myModules.home.starship = {
    enable = lib.mkEnableOption "starship prompt with nerd font symbols";
  };

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        # Core settings
        add_newline = true;
        continuation_prompt = "[▸▹ ](white)";
        format = ''          ($nix_shell$container$fill$git_metrics
          )$cmd_duration$hostname$localip$shlvl$shell$env_var$jobs$sudo$username$character'';
        right_format = ''$singularity$kubernetes$directory$vcsh$fossil_branch$git_branch$git_commit$git_state$git_status$hg_branch$pijul_channel$docker_context$package$c$cpp$cmake$cobol$daml$dart$deno$dotnet$elixir$elm$erlang$fennel$fortran$golang$guix_shell$haskell$haxe$helm$java$julia$kotlin$gradle$lua$nim$nodejs$ocaml$opa$perl$php$pulumi$purescript$python$raku$rlang$red$ruby$rust$scala$solidity$swift$terraform$vlang$vagrant$xmake$zig$buf$conda$pixi$meson$spack$memory_usage$aws$gcloud$openstack$azure$crystal$custom$status$os$battery$time'';

        # Fill
        fill = {symbol = " ";};

        # Character symbols
        character = {
          format = "$symbol ";
          success_symbol = "[◎](bold yellow)";
          error_symbol = "[○](italic magenta)";
          vimcmd_symbol = "[■](italic green)";
          vimcmd_replace_one_symbol = "◌";
          vimcmd_replace_symbol = "□";
          vimcmd_visual_symbol = "▼";
        };

        # Environment variables
        env_var = {
          VIMSHELL = {
            format = "[$env_value]($style)";
            style = "green italic";
          };
        };

        # Sudo
        sudo = {
          format = "[$symbol]($style)";
          style = "bold magenta";
          symbol = "⋈┈";
          disabled = false;
        };

        # Username
        username = {
          style_user = "yellow bold";
          style_root = "magenta bold";
          format = "[⭘ $user]($style) ";
          disabled = false;
          show_always = false;
        };

        # Directory
        directory = {
          home_symbol = "⌂";
          truncation_length = 2;
          truncation_symbol = "□ ";
          read_only = " ◈";
          use_os_path_sep = true;
          style = "blue";
          format = "[$path]($style)[$read_only]($read_only_style)";
          repo_root_style = "bold blue";
          repo_root_format = "[$before_root_path]($before_repo_root_style)[$repo_root]($repo_root_style)[$path]($style)[$read_only]($read_only_style) [△](bold blue)";
        };

        # Command duration
        cmd_duration = {
          format = "[◄ $duration ](white)";
        };

        # Jobs
        jobs = {
          format = "[$symbol$number]($style) ";
          style = "white";
          symbol = "[▶](blue italic)";
        };

        # Local IP
        localip = {
          ssh_only = true;
          format = " ◯[$localipv4](bold magenta)";
          disabled = false;
        };

        # Time
        time = {
          disabled = false;
          format = "[ $time]($style)";
          time_format = "%R";
          utc_time_offset = "local";
          style = "white";
        };

        # Battery
        battery = {
          format = "[ $percentage $symbol]($style)";
          full_symbol = "█";
          charging_symbol = "[↑](italic bold green)";
          discharging_symbol = "↓";
          unknown_symbol = "░";
          empty_symbol = "▃";
        };

        battery.display = [
          {
            threshold = 20;
            style = "bold red";
          }
          {
            threshold = 60;
            style = "magenta";
          }
          {
            threshold = 70;
            style = "yellow";
          }
        ];

        # Git branch
        git_branch = {
          format = " [$branch(:$remote_branch)]($style)";
          symbol = "[△](bold cyan)";
          style = "cyan";
          truncation_symbol = "⋯";
          truncation_length = 11;
          ignore_branches = ["main" "master"];
          only_attached = true;
        };

        # Git metrics
        git_metrics = {
          format = "([▴$added]($added_style))([▿$deleted]($deleted_style))";
          added_style = "bold green";
          deleted_style = "bold red";
          ignore_submodules = true;
          disabled = false;
        };

        # Git status
        git_status = {
          style = "bold cyan";
          format = "([⎪$ahead_behind$staged$modified$untracked$renamed$deleted$conflicted$stashed⎥]($style))";
          conflicted = "[◪◦](magenta)";
          ahead = "[▴│[$\{count\}](white)│](green)";
          behind = "[▿│[$\{count\}](white)│](red)";
          diverged = "[◇ ▴┤[$\{ahead_count\}](white)│▿┤[$\{behind_count\}](white)│](magenta)";
          untracked = "[◌◦](yellow)";
          stashed = "[◃◈](white)";
          modified = "[●◦](yellow)";
          staged = "[▪┤[$count](white)│](cyan)";
          renamed = "[◎◦](cyan)";
          deleted = "[✕](red)";
        };

        # Language/tool symbols (nerd fonts)
        deno = {
          format = " [deno](italic) [∫ $version](green bold)";
          version_format = "$\{raw\}";
        };

        lua = {
          format = " [lua](italic) [$\{symbol\}$\{version\}]($style)";
          version_format = "$\{raw\}";
          symbol = "⨀ ";
          style = "bold yellow";
        };

        nodejs = {
          format = " [node](italic) [◫ ($version)](bold green)";
          version_format = "$\{raw\}";
          detect_files = ["package-lock.json" "yarn.lock"];
          detect_folders = ["node_modules"];
          detect_extensions = [];
        };

        python = {
          format = " [py](italic) [$\{symbol\}$\{version\}]($style)";
          symbol = "[⌉](bold cyan)⌊ ";
          version_format = "$\{raw\}";
          style = "bold yellow";
        };

        ruby = {
          format = " [rb](italic) [$\{symbol\}$\{version\}]($style)";
          symbol = "◆ ";
          version_format = "$\{raw\}";
          style = "bold red";
        };

        rust = {
          format = " [rs](italic) [$symbol$version]($style)";
          symbol = "⊃ ";
          version_format = "$\{raw\}";
          style = "bold red";
        };

        package = {
          format = " [pkg](italic) [$symbol$version]($style)";
          version_format = "$\{raw\}";
          symbol = "◨ ";
          style = "yellow bold";
        };

        swift = {
          format = " [sw](italic) [$\{symbol\}$\{version\}]($style)";
          symbol = "◁ ";
          style = "bold bright-red";
          version_format = "$\{raw\}";
        };

        # AWS (disabled by default for tmux clarity)
        aws = {
          disabled = true;
          format = " [aws](italic) [$symbol $profile $region]($style)";
          style = "bold blue";
          symbol = "▲ ";
        };

        # Other language modules
        buf = {
          symbol = "■ ";
          format = " [buf](italic) [$symbol $version $buf_version]($style)";
        };
        c = {
          symbol = "ℂ ";
          format = " [$symbol($version(-$name))]($style)";
        };
        cpp = {
          symbol = "ℂ ";
          format = " [$symbol($version(-$name))]($style)";
        };
        conda = {
          symbol = "◯ ";
          format = " conda [$symbol$environment]($style)";
        };
        pixi = {
          symbol = "■ ";
          format = " pixi [$symbol$version ($environment )]($style)";
        };
        dart = {
          symbol = "◁◅ ";
          format = " dart [$symbol($version )]($style)";
        };
        docker_context = {
          symbol = "◧ ";
          format = " docker [$symbol$context]($style)";
        };
        elixir = {
          symbol = "△ ";
          format = " exs [$symbol $version OTP $otp_version ]($style)";
        };
        elm = {
          symbol = "◩ ";
          format = " elm [$symbol($version )]($style)";
        };
        golang = {
          symbol = "∩ ";
          format = " go [$symbol($version )]($style)";
        };
        haskell = {
          symbol = "❯λ ";
          format = " hs [$symbol($version )]($style)";
        };
        java = {
          symbol = "∪ ";
          format = " java [$\{symbol\}($\{version\} )]($style)";
        };
        julia = {
          symbol = "◎ ";
          format = " jl [$symbol($version )]($style)";
        };
        memory_usage = {
          symbol = "▪▫▪ ";
          format = " mem [$\{ram\}( $\{swap\})]($style)";
        };
        nim = {
          symbol = "▴▲▴ ";
          format = " nim [$symbol($version )]($style)";
        };

        nix_shell = {
          style = "bold blue";
          symbol = "✶";
          format = "[$symbol nix⎪$state⎪]($style) [$name](white)";
          impure_msg = "[⌽](bold red)";
          pure_msg = "[⌾](bold green)";
          unknown_msg = "[◌](bold yellow)";
        };

        spack = {
          symbol = "◇ ";
          format = " spack [$symbol$environment]($style)";
        };

        # OS symbols (nerd font)
        os = {
          symbols = {
            Alpaquita = " ";
            Alpine = " ";
            Amazon = " ";
            Android = " ";
            Arch = " ";
            Artix = " ";
            CentOS = " ";
            Debian = " ";
            DragonFly = " ";
            Emscripten = " ";
            EndeavourOS = " ";
            Fedora = " ";
            FreeBSD = " ";
            Garuda = "󰛓 ";
            Gentoo = " ";
            HardenedBSD = "󰞌 ";
            Illumos = "󰈸 ";
            Linux = " ";
            Mabox = " ";
            Macos = " ";
            Manjaro = " ";
            Mariner = " ";
            MidnightBSD = " ";
            Mint = " ";
            NetBSD = " ";
            NixOS = " ";
            OpenBSD = "󰈺 ";
            openSUSE = " ";
            OracleLinux = "󰌷 ";
            Pop = " ";
            Raspbian = " ";
            Redhat = " ";
            RedHatEnterprise = " ";
            Redox = "󰀘 ";
            Solus = "󰠳 ";
            SUSE = " ";
            Ubuntu = " ";
            Unknown = " ";
            Windows = "󰍲 ";
          };
        };

        # Remaining language symbols (from jetpack.toml)
        crystal = {symbol = " ";};
        fennel = {symbol = " ";};
        fossil_branch = {symbol = " ";};
        guix_shell = {symbol = " ";};
        haxe = {symbol = " ";};
        hg_branch = {symbol = " ";};
        hostname = {ssh_symbol = " ";};
        kotlin = {symbol = " ";};
        ocaml = {symbol = " ";};
        perl = {symbol = " ";};
        php = {symbol = " ";};
        pijul_channel = {symbol = " ";};
        rlang = {symbol = "󰟔 ";};
        scala = {symbol = " ";};
        zig = {symbol = " ";};
      };
    };
  };
}
