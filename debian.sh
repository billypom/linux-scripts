#!/bin/bash
fg_black="$(tput setaf 0)"
fg_red="$(tput setaf 1)"
fg_green="$(tput setaf 2)"
fg_yellow="$(tput setaf 3)"
fg_blue="$(tput setaf 4)"
fg_magenta="$(tput setaf 5)"
fg_cyan="$(tput setaf 6)"
fg_white="$(tput setaf 7)"
reset="$(tput sgr0)"
scriptdir=$PWD

confirm() {
    # call with a prompt string or use a default
    read -r -p "${fg_yellow}${1:-Are you sure? [y/N]}${reset} " response
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
is_server=true
install_themes=false
install_nerdfonts=false
install_neovim=false
install_dotfiles=false
install_gnome_configs=false
include_debian_backports=false
# colored text stopped working? idk
# confirm "\033[94mSwap Left Super & Left Control? (Mac keyboard)\033[0m" && is_macbook=true
# confirm "\033[94mInstall GTK themes?\033[0m" && install_themes=true
# confirm "\0cc[94mInstall Nerd Fonts?\033[0m" && install_nerdfonts=true

echo "${fg_blue}"
cat ascii.txt
echo "${fg_cyan}-----Debian Install Script-----${reset}"
confirm "Is this a server?" && is_server=true
confirm "Include debian backports in apt package manager? (Y/N)" && include_debian_backports=true
confirm "Swap Left Super & Left Control <for mac keyboard> (Y/N)" && is_macbook=true
if $is_server; then
    echo ":3"
else 
    if echo $DESKTOP_SESSION | grep -q "gnome"; then
        confirm "Install gnome extensions, tweaks, and configs? (Y/N)" && install_gnome_configs=true
    fi
fi
confirm "Install GTK themes? (Y/N)" && install_themes=true
confirm "Install Nerd Fonts? (Y/N)" && install_nerdfonts=true
confirm "Install billypom dotfiles? - includes .bash_aliases file, tmux, kitty, and nvim configs (Y/N)" && install_dotfiles=true
confirm "Install Neovim? (Y/N)" && install_neovim=true

echo "Updating package manager"
sudo apt update
echo "Purging yucky packages"
sudo apt purge nano evolution nautilus
echo "Installing yummy packages"
sudo apt install vim git cifs-utils nfs-common ripgrep stow virtualenv wget zip unzip kitty libfuse-dev python3-pip nemo ncdu tldr htop

if $is_server; then
    echo ":3"
else
    # wayland specific packages
    if echo $XDG_SESSION_TYPE | grep -q "wayland"; then
        echo "Installing wayland specific packages"
        sudo apt install -y wl-clipboard
    fi

    # gnome specific packages
    if echo $DESKTOP_SESSION | grep -q "gnome" && $install_gnome_configs; then
        echo "Installing gnome-specific packages"
        sudo apt install -y gnome-tweaks
        gsettings set org.gnome.desktop.interface gtk-theme Lavanda-Sea-Dark
        gsettings set org.gnome.shell.extensions.user-theme name Lavanda-Sea-Dark
        gsettings set org.gnome.desktop.interface icon-theme breeze
        gsettings set org.gnome.desktop.default-applications.terminal exec ‘kitty’
        # better alt tab functionality
        echo "Making alt-tab better :)"
        gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
        gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Alt>Tab', '<Alt>Above_Tab']"
        gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
        gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "[]"
        if $is_macbook; then 
            echo "Swapping left Super & left Control"
            bash options/toggle-gnome-macbook-keyboard.sh 1
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
fi
# nerdfonts
if $install_nerdfonts; then
    echo "Installing nerdfonts"
    bash options/install-nerdfonts.sh
fi

# themes
if $is_server; then
    echo ":3"
else
    if $install_themes; then
        # user theme directory
        echo "Installing themes"
        mkdir -p ~/.themes
        bash options/install-colloid-gtk-theme.sh
        bash options/install-lavanda-gtk-theme.sh
    fi
fi

# set default file manager
xdg-mime default nemo.desktop inode/directory

# install neovim
if $install_neovim; then
    echo "Installing neovim"
    bash options/install-neovim.sh
fi

# install my dotfiles
if $install_dotfiles; then
    echo "Installing billypom dotfiles"
    bash options/install-dotfiles.sh
fi

# apt repositories setup
# this wont work because of permissions...hmmm
if ! grep -q "deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware" /etc/apt/sources.list; then echo "deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware" >> /etc/apt/sources.list; fi

if ! grep -q "deb-src http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware" /etc/apt/sources.list; then echo "deb-src http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware" >> /etc/apt/sources.list; fi
if $include_debian_backports; then
    if ! grep -q "deb http://deb.debian.org/debian bookworm-backports main contrib non-free non-free-firmware" /etc/apt/sources.list; then echo "deb http://deb.debian.org/debian bookworm-backports main contrib non-free non-free-firmware" >> /etc/apt/sources.list; fi

    if ! grep -q "deb-src http://deb.debian.org/debian bookworm-backports main contrib non-free non-free-firmware" /etc/apt/sources.list; then echo "deb-src http://deb.debian.org/debian bookworm-backports main contrib non-free non-free-firmware" >> /etc/apt/sources.list; fi
fi
echo "\e[0;32m--- debian install script finished running ---\e[0m"
