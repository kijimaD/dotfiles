{ config, pkgs, ... }:

{
  # Allow unfree packages (needed for google-chrome)
  nixpkgs.config.allowUnfree = true;

  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = "violet";
  home.homeDirectory = "/home/violet";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "24.05";

  # The home.packages option allows you to install Nix packages into your environment
  home.packages = with pkgs; [
    claude-code
    curl
    delve
    docker
    docker-compose
    dunst
    emacs30
    fcitx5
    fcitx5-gtk
    fcitx5-mozc
    gimp
    go
    gocode-gomod
    gotools
    google-chrome
    gopls
    libvterm
    nodejs_24
    peco
    playerctl
    polybar
    python3
    qemu_kvm
    ripgrep
    stow
    unetbootin

    # Custom Go packages
    (buildGoModule {
      pname = "gclone";
      version = "unstable-2025-10-05";
      src = fetchFromGitHub {
        owner = "kijimaD";
        repo = "gclone";
        rev = "main";
        hash = "sha256-CVRh8dAVhNR3ceynvGxhJqSrDpuR+bT/nw2Oux3yoDI=";
      };
      vendorHash = "sha256-w3jHXjA/nYOn4CWJFZDwfClFy+ZYv/HFIYeqlfydPhQ=";
    })
  ];

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'
  home.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };

  # Prepend Nix profile to PATH
  home.sessionPath = [
    "$HOME/.nix-profile/bin"
  ];

  # User services
  systemd.user.services = {
    syncthing = {
      Unit.Description = "Syncthing";
      Service = {
        ExecStart = "${pkgs.syncthing}/bin/syncthing --no-browser";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "default.target" ];
    };

    redshift = {
      Unit.Description = "Redshift";
      Service = {
        ExecStart = "${pkgs.redshift}/bin/redshift";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "default.target" ];
    };

    dunst = {
      Unit.Description = "Dunst notification daemon";
      Unit.After = [ "graphical-session.target" ];
      Service = {
        ExecStart = "${pkgs.dunst}/bin/dunst";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Git configuration
  programs.git = {
    enable = true;
  };

  # Bash configuration example
  # programs.bash = {
  #   enable = true;
  #   shellAliases = {
  #     ll = "ls -la";
  #   };
  # };
}
