#   Oh My Zsh installation Path
export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/.local/bin:$PATH"

#   Theme
ZSH_THEME="robbyrussell"

#   Plugins
plugins=(git zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

#   Aliases
alias up="sudo pacman -Syu && yay"
alias e="exit"
alias refresh="source ~/.zshrc"
alias c="clear; fastfetch"
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

fastfetch

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export PATH=$PATH:/home/ziadlawatey/.spicetify
