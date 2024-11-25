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
