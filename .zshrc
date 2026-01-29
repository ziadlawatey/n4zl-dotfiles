#   Oh My Zsh installation Path
export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/.local/bin:$PATH"
export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34:st=37;44:ex=01;32:'
#

#   Theme
ZSH_THEME="robbyrussell"

#   Plugins
plugins=(git zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

#   Aliases
alias up="sudo pacman -Syu && yay"
alias e="exit"
alias refresh="source ~/.zshrc"
alias c="clear"
alias zshcfg="nvim ~/.zshrc"
alias edit="code ."
alias ist="sudo pacman -Syu"
alias osrelease="cat /etc/os-release"
alias rem="sudo pacman -Rns"
# alias autorem="sudo pacman -Qtdq; yay -Sc; sudo pacman -Scc"
alias autorem='echo "Removing orphaned packages..."; sudo pacman -Qtdq | sudo pacman -Rns - 2>/dev/null || echo "No orphans found"; echo "Cleaning yay cache..."; rm -rf ~/.cache/yay/* 2>/dev/null; echo "Removing ALL cached packages..."; sudo paccache -ruk0; sudo paccache -rk0; echo "Cleanup complete!"'
alias updesktop="update-desktop-database ~/.local/share/applications"
clear

eval "$(starship init zsh)"

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export PATH=$PATH:/home/ziadlawatey/.spicetify
