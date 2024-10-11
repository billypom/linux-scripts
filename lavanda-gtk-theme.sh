#!/bin/sh
# credit: https://github.com/drewgrif/bookworm-scripts

# Function to check if a directory exists
check_directory() {
    if [ -d "$1" ]; then
        return 0  # Directory exists
    else
        return 1  # Directory does not exist
    fi
}

# Check if Lavanda-gtk-theme is installed
if check_directory "$HOME/.themes/Lavanda-Dark"; then
    echo "Lavanda gtk theme is already installed."
else
    echo "Installing Lavanda-gtk-theme..."
    cd ~/Downloads || exit
    if [ -d "Lavanda-gtk-theme" ]; then
        echo "Lavanda-gtk-theme repository already cloned. Skipping clone step."
    else
        git clone https://github.com/vinceliuice/Lavanda-gtk-theme
        cd Lavanda-gtk-theme
        bash install.sh
    fi
    rm -rf ~/Downloads/Lavanda-gtk-theme
    echo "Finished installing Lavanda-gtk-theme"
fi
