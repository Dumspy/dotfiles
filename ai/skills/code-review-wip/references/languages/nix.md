# Nix Code Review Reference

Language-specific review guidance for Nix expressions, modules, and flakes.

## Security

**Secret Management with opnix**
This repository uses opnix for 1Password secrets integration. Never embed secrets directly in derivations (Nix store is world-readable).

```nix
# BAD - secret visible in nix store
pkgs.writeText "config" ''
  password = "${secret}"
''

# GOOD - use opnix for secrets
services.onepassword-secrets = {
  enable = true;
  tokenFile = "/etc/opnix-token";
  secrets = {
    mySecret = {
      reference = "op://VaultName/ItemName/field";
    };
  };
};

# Then reference at runtime
configFile = pkgs.writeText "config" ''
  password_file = "/run/secrets/mySecret"
'';
```

## Flake Best Practices

**Pinning with flake.lock**
- Flakes automatically track dependencies in `flake.lock`
- Run `nix flake update` deliberately to update dependencies
- Use `follows` to prevent duplicate dependencies

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
```

**Always Quote URLs**
RFC 45 deprecated bare URLs:

```nix
# BAD
url = https://github.com/NixOS/nixpkgs;

# GOOD
url = "https://github.com/NixOS/nixpkgs";
```

## Language Anti-Patterns

**Avoid `rec` (Recursive Attribute Sets)**
Causes hard-to-debug infinite recursion. Use `let ... in` instead:

```nix
# BAD
rec {
  a = 1;
  b = a + 2;
}

# GOOD
let
  a = 1;
in {
  a = a;
  b = a + 2;
}

# GOOD - explicit self-reference
let
  attrs = {
    a = 1;
    b = attrs.a + 2;
  };
in attrs
```

**Avoid `with` at Top Level**
Makes static analysis impossible. Use explicit `let` or `inherit`:

```nix
# BAD
with (import <nixpkgs> {});

# GOOD
let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) curl jq;
in

# GOOD - for package lists
buildInputs = builtins.attrValues {
  inherit (pkgs) curl jq git;
};
```

**Avoid `<...>` Lookup Paths**
Depends on `$NIX_PATH`, not reproducible. Use explicit flake inputs:

```nix
# BAD
import <nixpkgs> {}

# GOOD
{ inputs, ... }: let
  pkgs = inputs.nixpkgs.legacyPackages.${system};
in
```

**Explicit Nixpkgs Config**
Always set `config` and `overlays` explicitly to prevent impurities:

```nix
# BAD - may read from /etc/nix/nixpkgs-config.nix
import inputs.nixpkgs {}

# GOOD
import inputs.nixpkgs {
  config = {};
  overlays = [];
}
```

## Module Structure

This repository uses a custom module system under `modules/`:

### Home Modules (`modules/home/`)

```nix
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.home.<moduleName>;
  portable = config.myModules.home.portable or false;
in {
  options.myModules.home.<moduleName> = {
    enable = lib.mkEnableOption "description";
    
    someOption = lib.mkOption {
      type = lib.types.str;
      default = "default-value";
      description = "What this option does";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.<program> = {
      enable = true;
    };
  };
}
```

**Key Patterns:**
- Use `myModules.home.<name>` namespace
- Access `portable` mode for local override support
- Gate config with `lib.mkIf cfg.enable`
- Use `lib.optional` / `lib.optionals` for conditional lists

### System Modules (`modules/system/`)

```nix
{
  config,
  lib,
  pkgs,
  isDarwin,  # Special arg for platform detection
  ...
}: let
  cfg = config.myModules.system.<moduleName>;
in {
  options.myModules.system.<moduleName> = {
    enable = lib.mkEnableOption "description";
  };

  config = lib.mkIf cfg.enable {
    services.<service>.enable = true;
  };
}
```

**Key Patterns:**
- Use `myModules.system.<name>` namespace
- Use `isDarwin` specialArg for platform logic
- Import conditionally with `lib.optionals`:

```nix
{
  imports = [
    ./common.nix
  ] ++ lib.optionals (!isDarwin) [
    ./linux-only.nix
  ];
}
```

### Module Anti-Patterns

**Don't use `imports` in `config`**
`imports` is special, not part of `config`:

```nix
# BAD - won't work
config = lib.mkIf config.foo.enable {
  imports = [ ./foo.nix ];
};

# GOOD - use lib.optionals
imports = lib.optionals config.foo.enable [ ./foo.nix ];
```

**Avoid infinite recursion in config**

```nix
# BAD
config = if config.foo then { warnings = ["foo"]; } else {};

# GOOD - use lib.mkIf
config = lib.mkIf config.foo { warnings = ["foo"]; };

# GOOD - condition on attribute
config.warnings = if config.foo then ["foo"] else [];
```

## Overlays

**Basic Structure**

```nix
final: prev: {
  myPackage = prev.callPackage ./my-package {};
}
```

- `prev` = package set before this overlay
- `final` = package set after all overlays applied

**When to Use `prev` vs `final`**

- Use `prev` when overriding existing symbols (prevents infinite recursion)
- Use `final` when referencing packages that should observe other overlays

```nix
# GOOD - overriding with prev
hello = prev.hello.overrideAttrs (old: { ... });

# GOOD - referencing with final
myPackage = prev.callPackage ./my-package { 
  hello = final.hello;  # Sees any hello overrides
};
```

**Overlay Anti-Patterns**

**Don't use `rec` in overlays** - Packages won't observe overrides:

```nix
# BAD - pkg-b won't see pkg-a overrides
final: prev: rec {
  pkg-a = prev.callPackage ./a {};
  pkg-b = prev.callPackage ./b { dep-a = pkg-a; };
}

# GOOD - pkg-b observes all pkg-a overrides
final: prev: {
  pkg-a = prev.callPackage ./a {};
  pkg-b = prev.callPackage ./b { dep-a = final.pkg-a; };
}
```

**Don't use external parameters** - Breaks composability:

```nix
# BAD
{ boost }: final: prev: {
  myPkg = prev.callPackage ./pkg { inherit boost; };
}

# GOOD
final: prev: {
  myBoost = final.boost185;
  myPkg = prev.callPackage ./pkg { boost = final.myBoost; };
}
```

**Don't collect overlays in `~/.config/nixpkgs/overlays/`** - Creates impurity.

## Performance

**Deep Attrset Merges**
`//` is shallow and loses nested values. Use `lib.recursiveUpdate`:

```nix
# BAD - loses nested values
{ a = { b = 1; }; } // { a = { c = 3; }; }
# Result: { a = { c = 3; }; }

# GOOD
lib.recursiveUpdate 
  { a = { b = 1; }; } 
  { a = { c = 3; }; }
# Result: { a = { b = 1; c = 3; }; }
```

**IFD (Import From Derivation)**
Avoid `builtins.readFile` on derivation outputs - causes evaluation to depend on build.

**Reproducible Source Paths**
`./.` uses parent directory name in store path. Use fixed name:

```nix
# BAD
src = ./.;

# GOOD
src = builtins.path { path = ./.; name = "myproject"; };
```

## Idioms

**Use `lib` Functions**

```nix
# BAD
packages = if enableGui then [ pkgs.firefox ] else [];
value = config.services.nginx.virtualHosts;  # crashes if missing

# GOOD
packages = lib.optional enableGui pkgs.firefox;
value = config.services.nginx.virtualHosts or {};
value = lib.attrByPath [ "services" "nginx" "virtualHosts" ] {} config;
```

**Proper Option Types**
- Use `types.str` not `types.string` (deprecated)
- Use `types.lines` for string accumulation
- Always include descriptions

```nix
# BAD
options.myOption = lib.mkOption {
  type = types.string;
  default = "";
};

# GOOD
options.myOption = lib.mkOption {
  type = lib.types.str;
  default = "";
  description = "Clear description of purpose";
};
```

## Testing

- `nix flake check` - flake validation
- `nix build .#packageName` - build packages
- `nixos-rebuild dry-build` / `darwin-rebuild check` - test modules
- `alejandra` or `nixfmt` - formatting

## Issue Format

```
[NIX-001] [Category] - file.nix:line
Problem: Description
Impact: How it affects builds
Evidence: Code snippet
Fix: Nix-idiomatic solution
```

Example:
```
[NIX-001] [Security] - modules/secrets.nix:15
Problem: Secret embedded in derivation
Impact: Visible in world-readable /nix/store
Evidence: pkgs.writeText "config" "password = ${secret}"
Fix: Use opnix services.onepassword-secrets, reference /run/secrets/
```
