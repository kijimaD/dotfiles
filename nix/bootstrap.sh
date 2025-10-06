#!/usr/bin/env bash
set -euo pipefail

echo "=== Dotfiles Bootstrap ==="
echo ""

# ----- Functions -----

# git と curl をインストール（apt経由）
install_dependencies() {
    echo "Checking dependencies..."
    local need_install=false

    if ! command -v git &> /dev/null; then
        echo "  git not found"
        need_install=true
    fi

    if ! command -v curl &> /dev/null; then
        echo "  curl not found"
        need_install=true
    fi

    if [ "$need_install" = true ]; then
        echo "  Installing git and curl via apt..."
        sudo apt update
        sudo apt install -y git curl
        echo "  Done"
    else
        echo "  Skip: git and curl already installed"
    fi
}

# dotfiles リポジトリをHTTPS経由でクローン（SSH鍵不要）
clone_dotfiles() {
    echo "Cloning dotfiles..."
    if [ -d "$HOME/dotfiles" ]; then
        echo "  Skip: already exists"
    else
        git clone https://github.com/kijimaD/dotfiles.git "$HOME/dotfiles"
        echo "  Done"
    fi
}

# Nix パッケージマネージャをインストール
install_nix() {
    echo "Installing Nix..."
    if command -v nix &> /dev/null; then
        echo "  Skip: already installed"
        echo "  Nix version: $(nix --version)"
    else
        echo "  Downloading and installing Nix (multi-user mode)..."
        curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate

        # Verify installation
        if command -v nix &> /dev/null; then
            echo "  Done. Nix version: $(nix --version)"
        else
            echo "  Error: Nix installation failed"
            echo "  Please log out and log back in, then run this script again"
            exit 1
        fi
    fi

    # Ensure Nix is in PATH
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
}

# home-manager を実行してパッケージをインストール（SSH鍵も自動生成される）
run_home_manager() {
    echo "Running home-manager switch..."
    local username=$(whoami)
    cd "$HOME/dotfiles/nix"

    if [ ! -f "flake.nix" ]; then
        echo "  Error: flake.nix not found"
        exit 1
    fi

    if ! grep -q "\"$username\"" flake.nix; then
        echo "  Error: No configuration for user $username"
        echo "  Available: violet, gray"
        exit 1
    fi

    # First run: use nix run with experimental features enabled
    echo "  Running initial home-manager switch..."
    nix run home-manager -- switch --flake ".#$username"
    home-manager switch --flake ".#$username"

    echo "  Done"
}

# GitHub CLI でログインしてSSH鍵を登録
setup_github_ssh() {
    echo "Setting up GitHub SSH..."

    # Check gh command
    if ! command -v gh &> /dev/null; then
        echo "  Error: gh command not found"
        echo "  Please ensure home-manager switch completed successfully"
        return 1
    fi

    # GitHub CLI login
    if ! gh auth status &> /dev/null; then
        echo "  Logging in to GitHub CLI..."
        gh auth login
    else
        echo "  Skip: already logged in to GitHub CLI"
    fi

    # Add SSH key to GitHub
    local hostname=$(hostname)
    local key_title="dotfiles-${hostname}"
    local public_key=$(cat "$HOME/.ssh/id_ed25519.pub")

    if gh ssh-key list | grep -q "${public_key%% *}"; then
        echo "  Skip: SSH key already registered on GitHub"
    else
        echo "  Adding SSH key to GitHub..."
        gh ssh-key add "$HOME/.ssh/id_ed25519.pub" -t "$key_title"
    fi

    # Test SSH connection
    if ssh -T -o StrictHostKeyChecking=no git@github.com 2>&1 | grep -q "successfully authenticated"; then
        echo "  Done: GitHub SSH connection successful"
    else
        echo "  Warning: SSH connection test failed"
    fi
}

# dotfiles リポジトリのリモートURLをHTTPSからSSHに変更
switch_remote_to_ssh() {
    echo "Switching dotfiles remote to SSH..."
    cd "$HOME/dotfiles"
    local current_remote=$(git remote get-url origin)

    if [[ "$current_remote" == https://* ]]; then
        git remote set-url origin git@github.com:kijimaD/dotfiles.git
        echo "  Done: changed from HTTPS to SSH"
    else
        echo "  Skip: already using SSH"
    fi
}

# ssh configのテンプレをコピー
copy_sensitive_files() {
    echo "Copying sensitive files..."

    if [ -f "$HOME/.ssh/config" ]; then
        echo "  Skip: .ssh/config already exists"
    else
        mkdir -p "$HOME/.ssh"
        if [ -f "$HOME/dotfiles/.ssh/config" ]; then
            cp "$HOME/dotfiles/.ssh/config" "$HOME/.ssh/config"
            chmod 600 "$HOME/.ssh/config"
            echo "  Done: copied .ssh/config"
        else
            echo "  Skip: source file not found"
        fi
    fi
}

# inotify の監視上限を拡張（開発環境用）
expand_inotify() {
    echo "Expanding inotify limits..."

    # Skip if running in container
    if [ -f "/.dockerenv" ] || grep -q "docker\|lxc" /proc/1/cgroup 2>/dev/null; then
        echo "  Skip: running in container"
        return 0
    fi

    echo "  Setting fs.inotify.max_user_watches=524288..."
    echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
    echo "  Done"
}

# crontab を設定
init_crontab() {
    echo "Initializing crontab..."

    # Skip if running in container
    if [ -f "/.dockerenv" ] || grep -q "docker\|lxc" /proc/1/cgroup 2>/dev/null; then
        echo "  Skip: running in container"
        return 0
    fi

    if [ -f "$HOME/dotfiles/crontab" ]; then
        crontab "$HOME/dotfiles/crontab"
        echo "  Done: crontab initialized"
    else
        echo "  Skip: crontab file not found"
    fi
}

# Docker をsudoなしで使えるように設定＆自動起動を有効化
init_docker() {
    echo "Initializing Docker..."

    if ! command -v docker &> /dev/null; then
        echo "  Skip: docker not installed"
        return 0
    fi

    # Add user to docker group
    local username=$(whoami)
    if groups | grep -q docker; then
        echo "  Skip: user already in docker group"
    else
        echo "  Adding user to docker group..."
        sudo gpasswd -a "$username" docker
        echo "  Done: added to docker group (re-login required)"
    fi

    # Enable docker service
    if systemctl is-enabled docker &>/dev/null; then
        echo "  Skip: docker service already enabled"
    else
        echo "  Enabling docker service..."
        sudo systemctl enable docker
        echo "  Done: docker service enabled"
    fi

    # Start docker service
    if systemctl is-active docker &>/dev/null; then
        echo "  Skip: docker service already running"
    else
        echo "  Starting docker service..."
        sudo systemctl start docker
        echo "  Done: docker service started"
    fi
}

# stow でシンボリックリンクを作成
run_stow() {
    echo "Running stow..."

    if ! command -v stow &> /dev/null; then
        echo "  Error: stow command not found"
        echo "  Please ensure home-manager switch completed successfully"
        return 1
    fi

    cd "$HOME/dotfiles"
    stow . --adopt
    echo "  Done: stow completed"
}

# Emacs 設定をクローンして cask install を実行
setup_emacs() {
    echo "Setting up Emacs..."

    # Clone .emacs.d to temporary location first
    local temp_dir="$HOME/.emacs.d.tmp"

    if [ -d "$temp_dir/.git" ]; then
        echo "  Updating existing .emacs.d clone..."
        cd "$temp_dir"
        git pull
    else
        echo "  Cloning .emacs.d to temporary location..."
        rm -rf "$temp_dir"
        git clone git@github.com:kijimaD/.emacs.d.git "$temp_dir"
        echo "  Done: cloned .emacs.d"
    fi

    # Move to final location (overwrite if exists)
    echo "  Moving to $HOME/.emacs.d..."
    rm -rf "$HOME/.emacs.d"
    mv "$temp_dir" "$HOME/.emacs.d"
    echo "  Done: moved to final location"

    # Run cask install
    if ! command -v cask &> /dev/null; then
        echo "  Error: cask command not found"
        echo "  Please ensure home-manager switch completed successfully"
        return 1
    fi

    echo "  Running cask install..."
    cd "$HOME/.emacs.d"
    cask install
    echo "  Done: cask install completed"
}

# gclone でリポジトリを一括クローン（LONG環境変数が設定されている場合のみ）
run_gclone() {
    echo "Running gclone..."

    if ! command -v gclone &> /dev/null; then
        echo "  Skip: gclone not installed"
        return 0
    fi

    if [ -z "$LONG" ]; then
        echo "  Skip: LONG environment variable not set"
        return 0
    fi

    if [ -f "$HOME/dotfiles/gclone.yml" ]; then
        gclone -f "$HOME/dotfiles/gclone.yml"
        echo "  Done: gclone completed"
    else
        echo "  Skip: gclone.yml not found"
    fi
}

# ----- Main -----

install_dependencies
clone_dotfiles
install_nix
run_home_manager
setup_github_ssh
switch_remote_to_ssh
copy_sensitive_files
expand_inotify
init_crontab
init_docker
run_stow
setup_emacs
run_gclone

echo ""
echo "=== Bootstrap completed ==="
echo ""
