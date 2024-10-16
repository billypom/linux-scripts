#!/bin/bash
scriptdir=$PWD

confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}


check_dir_exists() {
    dir=$1
    if [ -d dir ]; then
        return 1  # Dir exists
    else
        return 0  # Dir does not exist
    fi
}

is_macbook=false
install_themes=false
install_nerdfonts=false
confirm "\033[94mSwap Left Super & Left Control? (Mac keyboard)\033[0m" && is_macbook=true
confirm "\033[94mInstall GTK themes?\033[0m" && install_themes=true
confirm "\0cc[94mInstall Nerd Fonts?\033[0m" && install_nerdfonts=true

sudo apt update
sudo apt upgrade
sudo apt purge nano evolution nautilus
sudo apt install vim git cifs-utils nfs-common ripgrep stow virtualenv wget npm zip unzip kitty libfuse-dev python3-pip nemo
# wayland specific packages
if "$XDG_SESSION_TYPE" == "wayland"; then
    echo "Installing wayland specific packages"
    sudo apt install -y wl-clipboard
fi
# gnome specific packages
if "$DESKTOP_SESSION" == "gnome"; then
    echo "Installing gnome-specific packages"
    sudo apt install -y gnome-tweaks
    gsettings set org.gnome.desktop.interface gtk-theme Lavanda-Sea-Dark
    gsettings set org.gnome.shell.extensions.user-theme name Lavanda-Sea-Dark
    gsettings set org.gnome.desktop.interface icon-theme breeze
    gsettings set org.gnome.desktop.default-applications.terminal exec ‘kitty’
    # better alt tab functionality
    gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
    gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Alt>Tab', '<Alt>Above_Tab']"
    gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
    gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "[]"
    if $is_macbook; then 
        echo "Swapping left Super & left Control"
        gsettings set org.gnome.desktop.input-sources xkb-options "['ctrl:swap_lwin_lctl']"
    fi
    sudo apt install -y pipx
    # adds ~/.local/bin to PATH
    pipx ensurepath
    # https://github.com/essembeh/gnome-extensions-cli
    pipx install gnome-extensions-cli --system-site-packages
    # install gnome extensions
    gext install dash-to-dock@micxgx.gmail.com user-theme@gnome-shell-extensions.gcampax.github.com openbar@neuromorph emoji-copy@felipeftn tiling-assistant@leleat-on-github Vitals@CoreCoding.com compiz-windows-effect@hermes83.github.com
    # enable gnome extensions
    gext enable dash-to-dock@micxgx.gmail.com user-theme@gnome-shell-extensions.gcampax.github.com openbar@neuromorph emoji-copy@felipeftn tiling-assistant@leleat-on-github Vitals@CoreCoding.com compiz-windows-effect@hermes83.github.com
fi
# nerdfonts
if $install_nerdfonts; then
    bash nerdfonts.sh
fi
# themes
if $install_themes; then
    # user theme directory
    mkdir -p ~/.themes
    bash colloid-gtk-theme.sh
    bash lavanda-gtk-theme.sh
fi

# set default file manager
xdg-mime default nemo.desktop inode/directory

# install neovim
mkdir -p ~/applications
wget -q --show-progress https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
if check_dir_exists ~/applications/nvim-linux64/; then
    mv ~/applications/nvim-linux64/ ~/applications/nvim-linux64.old/
fi
tar xzf nvim-linux64.tar.gz
mv nvim-linux64 ~/applications/
rm nvim-linux64.tar.gz
rm -r ~/applications/nvim-linux64.old
if ! grep -q "alias vim" ~/.bash_aliases; then echo ‘alias vim=“~/applications/nvim-linux64/bin/nvim”’ >> ~/.bash_aliases; fi
echo "Installed latest neovim"

# install my dotfiles
if check_dir_exists ~/code/dotfiles; then
    cd ~/code/dotfiles
    git pull
    echo "Pulled billypom/dotfiles from github"
else
    mkdir -p ~/code
    cd ~/code
    git clone https://github.com/billypom/dotfiles.git
    echo "Cloned billypom/dotfiles from github"
fi
cd ~/code
stow --adopt dotfiles/
echo "Stowed dotfiles"
# repository setup
if ! grep -q "deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware" /etc/apt/sources.list; then echo "deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware" >> /etc/apt/sources.list; fi

if ! grep -q "deb-src http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware" /etc/apt/sources.list; then echo "deb-src http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware" >> /etc/apt/sources.list; fi

echo -e "\e[0;32m--- debian install script finished running ---\e[0m"
