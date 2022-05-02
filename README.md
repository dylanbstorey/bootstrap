Stripped down ohmyzsh 


export REMOTE="https://gitlab.com/dylanbstorey/ohmyzsh.git"
sh -c "$(wget -O- https://gitlab.com/dylanbstorey/ohmyzsh/-/raw/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
source ${HOME}/.zshrc



#Notes : 


Full install script 

1. install hyper.js
2. copy .hyper.js ${HOME}
3. install power10k fonts


export REMOTE="https://gitlab.com/dylanbstorey/ohmyzsh.git"
sh -c "$(wget -O- https://gitlab.com/dylanbstorey/ohmyzsh/-/raw/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

source ${HOME}/.zshrc