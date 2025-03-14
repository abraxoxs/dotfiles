# ~/.zshrc: Custom configuration for Zsh

# Enable command auto-correction
setopt correct_all

# Enable command auto-completion
autoload -U compinit
compinit

# Set the prompt (User@Host:Path$)
PROMPT='%F{cyan}%n@%m%f:%F{green}%~%f$ '

# Enable colors for ls and other commands
alias ls='ls --color=auto'
alias ll='ls -lh'
alias la='ls -lA'
alias grep='grep --color=auto'

# Use the system's history settings
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:ignorespace
export HISTTIMEFORMAT="%F %T "

# Set the default editor (nano or vim)
export VISUAL=nano
export EDITOR="\$VISUAL"

# Set up Python virtual environment
export WORKON_HOME=\$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=\$(which python3)
source /usr/local/bin/virtualenvwrapper.sh

# End of .zshrc
