# ensure git and stow are installed
sudo apt install git stow
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
