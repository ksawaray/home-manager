{ pkgs, lib, config, username, ... }: {
  home.username = username;
  home.homeDirectory =
    if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";

  # NixOS 以外の Linux（Ubuntu など）で XDG_DATA_DIRS などを整える
  targets.genericLinux.enable = pkgs.stdenv.isLinux;

  # Home Manager 自体をインストールしてパスを通す
  programs.home-manager.enable = true;

  # ここに普段使いたいパッケージを書く
  home.packages = with pkgs; [
    # 共通
    peco
    pet
    gh
    lazygit
    podman
    podman-compose
    (python312.withPackages (ps: with ps; [
      ipython
      requests
      pandas
      numpy
    ]))
    nodejs_24
    ghidra
    claude-code
  ] ++ lib.optionals stdenv.isDarwin [
    # macOS のみ
    lima
    lima-additional-guestagents
  ] ++ lib.optionals stdenv.isLinux [
    # Linux のみ
  ];

  programs.zsh = let
    zshrc = "./configs/zsh/zshrc_nix";
  in {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "candy";
    };

    initContent = ''
      [[ -f ${zshrc} ]] && source ${zshrc}
    '';
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Kyoji Ogasawara";
        email = "sawara04.o@gmail.com";
      };
    };
  };

  programs.tmux = {
    enable = true;
    extraConfig = ''
      source-file -q ./configs/tmux/tmux.conf
    '';
  };

  # nix-direnv を programs モジュールで管理
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.stateVersion = "25.11";
}

