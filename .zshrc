# Load Nodenv
eval "$(nodenv init -)"

# Add Visual Studio Code (code)
export PATH="\$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Completion
autoload -Uz compinit
compinit

setopt MENU_COMPLETE
setopt CORRECT
setopt CORRECT_ALL

zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'

# Stylize prompt with git status
autoload -Uz add-zsh-hook vcs_info
add-zsh-hook precmd vcs_info

setopt prompt_subst

zstyle ':vcs_info:*' check-for-changes true # check for changes
zstyle ':vcs_info:*' unstagedstr '%F{1}*%f' # customize unstaged changes string
zstyle ':vcs_info:*' stagedstr '%F{2}+%f' # customize staged changes string
zstyle ':vcs_info:git:*' formats '(%b%u%c)' # set the format for vcs_info
zstyle ':vcs_info:git:*' actionformats '(%b|%a%u%c)' # set the action format, e.g. rebase, for vcs_info
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked # set hook format for untracked changes

+vi-git-untracked(){
    if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
        git status --porcelain | grep '??' &> /dev/null ; then

        hook_com[staged]+='%F{3}?%f'
    fi
}

PROMPT='%B%F{7}%~%f%F{12}${vcs_info_msg_0_}%f%b '
