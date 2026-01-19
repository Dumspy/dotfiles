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
        continuation_prompt = "[▸▹ ](#cad1d9)";
        format = ''          ($nix_shell$container$fill$git_metrics
          )$cmd_duration$hostname$localip$shlvl$shell$env_var$jobs$sudo$username$character'';
        right_format = ''$singularity$kubernetes$directory$vcsh$fossil_branch$git_branch$git_commit$git_state$git_status$hg_branch$pijul_channel$docker_context$package$c$cpp$cmake$cobol$daml$dart$deno$dotnet$elixir$elm$erlang$fennel$fortran$golang$guix_shell$haskell$haxe$helm$java$julia$kotlin$gradle$lua$nim$nodejs$ocaml$opa$perl$php$pulumi$purescript$python$raku$rlang$red$ruby$rust$scala$solidity$swift$terraform$vlang$vagrant$xmake$zig$buf$conda$pixi$meson$spack$memory_usage$aws$gcloud$openstack$azure$crystal$custom$status$os$battery$time'';

        # Fill
        fill = {symbol = " ";};

        # Character symbols (Catppuccin Macchiato)
        character = {
          format = "$symbol ";
          success_symbol = "[◎](bold #eed49f)";
          error_symbol = "[○](italic #ed8796)";
          vimcmd_symbol = "[■](italic #a6da95)";
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
          style = "bold #c6a0f6";
          symbol = "⋈┈";
          disabled = false;
        };

        # Username
        username = {
          style_user = "#eed49f bold";
          style_root = "#c6a0f6 bold";
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
          style = "#8aadf4";
          format = "[$path]($style)[$read_only]($read_only_style)";
          repo_root_style = "bold #8aadf4";
          repo_root_format = "[$before_root_path]($before_repo_root_style)[$repo_root]($repo_root_style)[$path]($style)[$read_only]($read_only_style) [△](bold #8aadf4)";
        };

        # Command duration
        cmd_duration = {
          format = "[◄ $duration ](#cad1d9)";
        };

        # Jobs
        jobs = {
          format = "[$symbol$number]($style) ";
          style = "#cad1d9";
          symbol = "[▶](#8aadf4 italic)";
        };

        # Local IP
        localip = {
          ssh_only = true;
          format = " ◯[$localipv4](bold #c6a0f6)";
          disabled = false;
        };

        # Time
        time = {
          disabled = false;
          format = "[ $time]($style)";
          time_format = "%R";
          utc_time_offset = "local";
          style = "#cad1d9";
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
            style = "bold #ed8796";
          }
          {
            threshold = 60;
            style = "#c6a0f6";
          }
          {
            threshold = 70;
            style = "#eed49f";
          }
        ];

        # Git branch
        git_branch = {
          format = " [$branch(:$remote_branch)]($style)";
          symbol = "[△](bold #91d7e3)";
          style = "#91d7e3";
          truncation_symbol = "⋯";
          truncation_length = 11;
          ignore_branches = ["main" "master"];
          only_attached = true;
        };

        # Git metrics
        git_metrics = {
          format = "([▴$added]($added_style))([▿$deleted]($deleted_style))";
          added_style = "bold #a6da95";
          deleted_style = "bold #ed8796";
          ignore_submodules = true;
          disabled = false;
        };

        # Git status
        git_status = {
          style = "bold #91d7e3";
          format = "([⎪$ahead_behind$staged$modified$untracked$renamed$deleted$conflicted$stashed⎥]($style))";
          conflicted = "[◪◦](#c6a0f6)";
          ahead = "[▴│[$\{count\}](#cad1d9)│](#a6da95)";
          behind = "[▿│[$\{count\}](#cad1d9)│](#ed8796)";
          diverged = "[◇ ▴┤[$\{ahead_count\}](#cad1d9)│▿┤[$\{behind_count\}](#cad1d9)│](#c6a0f6)";
          untracked = "[◌◦](#eed49f)";
          stashed = "[◃◈](#cad1d9)";
          modified = "[●◦](#eed49f)";
          staged = "[▪┤[$count](#cad1d9)│](#91d7e3)";
          renamed = "[◎◦](#91d7e3)";
          deleted = "[✕](#ed8796)";
        };

        # Language/tool symbols (nerd fonts)
        deno = {
          format = " [deno](italic #cad1d9) [∫ $version](#a6da95 bold)";
          version_format = "$\{raw\}";
        };

        lua = {
          format = " [lua](italic #cad1d9) [$\{symbol\}$\{version\}]($style)";
          version_format = "$\{raw\}";
          symbol = "⨀ ";
          style = "bold #eed49f";
        };

        nodejs = {
          format = " [node](italic #cad1d9) [◫ ($version)](bold #a6da95)";
          version_format = "$\{raw\}";
          detect_files = ["package-lock.json" "yarn.lock"];
          detect_folders = ["node_modules"];
          detect_extensions = [];
        };

        python = {
          format = " [py](italic #cad1d9) [$\{symbol\}$\{version\}]($style)";
          symbol = "[⌉](bold #91d7e3)⌊ ";
          version_format = "$\{raw\}";
          style = "bold #eed49f";
        };

        ruby = {
          format = " [rb](italic #cad1d9) [$\{symbol\}$\{version\}]($style)";
          symbol = "◆ ";
          version_format = "$\{raw\}";
          style = "bold #ed8796";
        };

        rust = {
          format = " [rs](italic #cad1d9) [$symbol$version]($style)";
          symbol = "⊃ ";
          version_format = "$\{raw\}";
          style = "bold #ed8796";
        };

        package = {
          format = " [pkg](italic #cad1d9) [$symbol$version]($style)";
          version_format = "$\{raw\}";
          symbol = "◨ ";
          style = "#eed49f bold";
        };

        swift = {
          format = " [sw](italic #cad1d9) [$\{symbol\}$\{version\}]($style)";
          symbol = "◁ ";
          style = "bold #ed8796";
          version_format = "$\{raw\}";
        };

        # AWS (disabled by default for tmux clarity)
        aws = {
          disabled = true;
          format = " [aws](italic #cad1d9) [$symbol $profile $region]($style)";
          style = "bold #8aadf4";
          symbol = "▲ ";
        };

        # Other language modules
        buf = {
          symbol = "■ ";
          format = " [buf](italic #cad1d9) [$symbol $version $buf_version]($style)";
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
          format = " [conda](#cad1d9) [$symbol$environment]($style)";
        };
        pixi = {
          symbol = "■ ";
          format = " [pixi](#cad1d9) [$symbol$version ($environment )]($style)";
        };
        dart = {
          symbol = "◁◅ ";
          format = " [dart](#cad1d9) [$symbol($version )]($style)";
        };
        docker_context = {
          symbol = "◧ ";
          format = " [docker](#cad1d9) [$symbol$context]($style)";
        };
        elixir = {
          symbol = "△ ";
          format = " [exs](#cad1d9) [$symbol $version OTP $otp_version ]($style)";
        };
        elm = {
          symbol = "◩ ";
          format = " [elm](#cad1d9) [$symbol($version )]($style)";
        };
        golang = {
          symbol = "∩ ";
          format = " [go](#cad1d9) [$symbol($version )]($style)";
        };
        haskell = {
          symbol = "❯λ ";
          format = " [hs](#cad1d9) [$symbol($version )]($style)";
        };
        java = {
          symbol = "∪ ";
          format = " [java](#cad1d9) [$\{symbol\}($\{version\} )]($style)";
        };
        julia = {
          symbol = "◎ ";
          format = " [jl](#cad1d9) [$symbol($version )]($style)";
        };
        memory_usage = {
          symbol = "▪▫▪ ";
          format = " [mem](#cad1d9) [$\{ram\}( $\{swap\})]($style)";
        };
        nim = {
          symbol = "▴▲▴ ";
          format = " [nim](#cad1d9) [$symbol($version )]($style)";
        };

        nix_shell = {
          style = "bold #8aadf4";
          symbol = "✶";
          format = "[$symbol nix⎪$state⎪]($style) [$name](#cad1d9)";
          impure_msg = "[⌽](bold #ed8796)";
          pure_msg = "[⌾](bold #a6da95)";
          unknown_msg = "[◌](bold #eed49f)";
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
