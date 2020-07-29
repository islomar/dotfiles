zmodload zsh/zprof
# If you come from bash you might have to change your $PATH.
export PATH="/usr/local/opt/python/libexec/bin:/usr/local/sbin:$GOPATH/bin:$HOME/bin:$DOTFILES_PATH/bin:$PATH"
GPG_TTY=$(tty)
export GPG_TTY


# Configure Python
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Devel
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
    export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
    export VIRTUALENVWRAPPER_VIRTUALENV=/usr/local/bin/virtualenv
fi
source /usr/local/bin/virtualenvwrapper.sh

export FZF_BASE=/usr/local/bin/fzf

# Install Ruby Gems to ~/gems
export GEM_HOME="$HOME/gems"
export PATH="$HOME/gems/bin:$PATH"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting fzf docker docker-compose symfony2 z zsh-sdkman)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# My aliases
#alias ls="exa"
alias brewery='brew update; brew upgrade; brew cleanup; brew doctor'
alias cleanup-docker='docker stop $(docker ps -qa) && docker rm $(docker ps -qa) && docker system prune -f && docker volume prune -f'
alias cdw="cd $HOME/workspace"
alias cdc="cd $HOME/workspace/codium"
alias cdp="cd $HOME/workspace/personal"
alias cdh="cd $HOME/workspace/habitissimo"
alias cat="bat --theme=\$(defaults read -globalDomain AppleInterfaceStyle &> /dev/null && echo default || echo GitHub)"
alias please='sudo $(fc -ln -1)'
alias vzsh="vim ~/.zshrc"
alias szsh="source ~/.zshrc"
alias lg="lazygit"
alias gplr="git pull --rebase"
alias update_git_repos="$HOME/bin/update_all_github_repos.sh"
alias vphpini="vim $(php -i | grep "Loaded Configuration File" | cut -d" " -f 5)"
alias xdebug-enable="mv /usr/local/etc/php/7.4/conf.d/ext-xdebug.ini.bak /usr/local/etc/php/7.4/conf.d/ext-xdebug.ini"
alias xdebug-disable="mv /usr/local/etc/php/7.4/conf.d/ext-xdebug.ini /usr/local/etc/php/7.4/conf.d/ext-xdebug.ini.bak"
alias blackfire-enable="mv /usr/local/etc/php/7.4/conf.d/ext-blackfire.ini.bak /usr/local/etc/php/7.4/conf.d/ext-blackfire.ini"
alias blackfire-disable="mv /usr/local/etc/php/7.4/conf.d/ext-blackfire.ini /usr/local/etc/php/7.4/conf.d/ext-blackfire.ini.bak"
alias dc="$HOME/bin/docker-connect.sh"
alias sof="$HOME/bin/show_open_files.sh"

[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

prompt_context(){} # To hide the user@hostname

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

RPROMPT="[%D{%f/%m/%y}|%@]"

if [[ "$unamestr" == 'Linux' ]]; then
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi
