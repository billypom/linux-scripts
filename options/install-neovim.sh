sudo apt install npm
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
mkdir -p ~/applications
wget -q --show-progress https://github.com/neovim/neovim/releases/download/v0.10.4/nvim-linux-x86_64.tar.gz
if check_dir_exists ~/applications/nvim-linux-x86_64/; then
    mv ~/applications/nvim-linux-x86_64/ ~/applications/nvim-linux-x86_64.old/
fi
tar xzf nvim-linux-x86_64.tar.gz
mv nvim-linux-x86_64 ~/applications/
rm nvim-linux-x86_64.tar.gz
rm -r ~/applications/nvim-linux-x86_64.old
if ! grep -q "alias vim" ~/.bash_aliases; then echo "alias vim='~/applications/nvim-linux-x86_64/bin/nvim'" >> ~/.bash_aliases; fi
echo "Installed latest neovim"
