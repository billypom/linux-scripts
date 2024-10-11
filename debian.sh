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
confirm "Swap Left Super & Left Control? (Mac keyboard)" && is_macbook=true

sudo apt update
sudo apt upgrade
sudo apt install vim git cifs-utils nfs-common ripgrep stow virtualenv wget npm zip unzip kitty libfuse-dev python3-pip pipx nemo breeze-icon-theme gnome-tweaks
sudo apt purge nano evolution nautilus
# erdfonts
bash nerdfonts.sh
# themes
# user theme directory
mkdir -p ~/.themes
bash colloid-gtk-theme.sh
bash lavanda-gtk-theme.sh
# adds ~/.local/bin to PATH
pipx ensurepath
# default gnome stuff
gsettings set org.gnome.desktop.interface gtk-theme Lavanda-Sea-Dark
gsettings set org.gnome.shell.extensions.user-theme name Lavanda-Sea-Dark
gsettings set org.gnome.desktop.interface icon-theme breeze
xdg-mime default nemo.desktop inode/directory
gsettings set org.gnome.desktop.default-applications.terminal exec ‘kitty’
if $is_macbook; then 
    echo "Swapping left Super & left Control"
    gsettings set org.gnome.desktop.input-sources xkb-options "['ctrl:swap_lwin_lctl']"
fi
# install gnome extensions manager, cli
# https://github.com/essembeh/gnome-extensions-cli
pipx install gnome-extensions-cli --system-site-packages
# install gnome extensions
gext install dash-to-dock@micxgx.gmail.com user-theme@gnome-shell-extensions.gcampax.github.com openbar@neuromorph emoji-copy@felipeftn tiling-assistant@leleat-on-github Vitals@CoreCoding.com compiz-windows-effect@hermes83.github.com
# enable gnome extensions
gext enable dash-to-dock@micxgx.gmail.com user-theme@gnome-shell-extensions.gcampax.github.com openbar@neuromorph emoji-copy@felipeftn tiling-assistant@leleat-on-github Vitals@CoreCoding.com compiz-windows-effect@hermes83.github.com
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
