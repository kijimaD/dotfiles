{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = "violet";
  home.homeDirectory = "/home/violet";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "24.05";

  # The home.packages option allows you to install Nix packages into your environment
  home.packages = with pkgs; [
    # Add your packages here
    # Example:
    # htop
    # ripgrep
    # fd
  ];

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'
  home.sessionVariables = {
    # EDITOR = "nvim";
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Git configuration example
  # programs.git = {
  #   enable = true;
  #   userName = "Your Name";
  #   userEmail = "your.email@example.com";
  # };

  # Bash configuration example
  # programs.bash = {
  #   enable = true;
  #   shellAliases = {
  #     ll = "ls -la";
  #   };
  # };
}
