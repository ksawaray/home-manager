{
  description = "Home Manager configuration Flake";

  inputs = {
    # Linux 用
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    # macOS 用（darwin 向けにテスト・キャッシュされたブランチ）
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-25.11-darwin";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-darwin, home-manager, ... }:
    let
      lib = nixpkgs.lib;

      mkHome = { system, username }:
        let
          isDarwin = lib.hasSuffix "darwin" system;
          nixpkgsSrc = if isDarwin then nixpkgs-darwin else nixpkgs;
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgsSrc {
            inherit system;
            config = {
              allowUnfree = true;
              allowInsecurePredicate = pkg:
                builtins.elem (lib.getName pkg) [
                  "lima"
                  "lima-additional-guestagents"
                ];
            };
          };
          extraSpecialArgs = { inherit username; };
          modules = [ ./home.nix ];
        };
    in {
      # 名前は "ユーザー名" または "ユーザー名@ホスト名" にしておくと
      # `home-manager switch --flake .` で自動的に選ばれる
      homeConfigurations = {
        # Mac
        "sawara" = mkHome {
          system = "aarch64-darwin"; # Intel Mac なら "x86_64-darwin"
          username = "sawara";
        };

        # Linux（ホスト名は実際のマシンに合わせて変更）
        "sawara@linux-box" = mkHome {
          system = "x86_64-linux"; # ARM なら "aarch64-linux"
          username = "sawara";
        };
      };
    };
}

