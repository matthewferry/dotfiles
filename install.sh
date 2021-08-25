#!/bin/sh
set -e
shopt -s nocasematch

# Check if macOS, else assume Linux
if [ "$(uname -s)" == "Darwin" ]; then
  MACOS=1
  GIT_CREDENTIAL="osxkeychain"
else
  GIT_CREDENTIAL="cache"
fi

# Pretty logs
info() {
  printf "\r\e[01;34m→ \e[39m$1\e[0m \n"
}

success() {
  printf "\r\e[01;32m✔︎ \e[39m$1\e[0m \n"
}

question() {
  printf "\r\e[01;33m? \e[39m$1\e[0m"
}

info "Let’s get your dotfiles set up…\n"

# Install Homebrew
install_brew() {
  if ! command -v brew &> /dev/null; then
    info "Installing Homebrew…"

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    success "Homebrew installed \n"
  fi
}

# Configure git
configure_git() {
  CONFIG_GIT=1
  if [ -f "${HOME}/.gitconfig" ]; then
    info "Found existing .gitconfig:"
    git config --global --list | sed "s/^/  /"

    question "Overwrite (y/n)"
    read -p " " -e OVERWRITE
    if ! [[ "${OVERWRITE}" =~ y[es]? ]]; then
      unset CONFIG_GIT
      success "Skipped git configuration \n"
    fi
  fi

  if [ -n "${CONFIG_GIT}" ]; then
    info "Configuring git…"
    question "Your full name:"
    read -p " " -e GIT_NAME

    question 'Your email:'
    read -p " " -e GIT_EMAIL

    question "Your GitHub username:"
    read -p " " -e GITHUB_USERNAME

    question "Your GitHub PAT for auth:"
    read  -s -p " " -e GITHUB_TOKEN
    echo '\r'

    # Add configurations
    git config --global user.name "${GIT_NAME}"
    git config --global user.email "${GIT_EMAIL}"
    git config --global github.user "${GITHUB_USERNAME}"
    git config --global credential.helper "${GIT_CREDENTIAL}"
    git config --global push.default simple
    git config --global core.excludesfile "${HOME}/.gitignore"

    # Auth and save token
    printf "protocol=https\\nhost=github.com\\n" | git credential reject
    printf "protocol=https\\nhost=github.com\\nusername=%s\\npassword=%s\\n" \
      "${GITHUB_USERNAME}" "${GITHUB_TOKEN}" | git credential approve
    success "Git configured \n"
  fi
}

configure_dotfiles() {
  info "Configuring dotfiles…"

  if ! [ -d "${HOME}/.dotfiles" ]; then
    info "Cloning dotfiles repository…"
    git clone https://github.com/${GITHUB_USERNAME}/dotfiles ~/.dotfiles
  else
    info "Updating dotfiles repository…"
    cd ~/.dotfiles
    git pull --rebase --autostash
  fi

  info "Symlinking dotfiles"

  for LINK in Brewfile zshrc gitignore; do
    if ! [ -f "${HOME}/.${LINK}" ]; then
      ln -s "${HOME}/.dotfiles/.${LINK}" "${HOME}/.${LINK}"
      success "Symlinked ${LINK} to ${HOME}"
    fi
  done

  success "Dotfiles configured \n"
}

bundle_install() {
  info "Installing formulae, casks, and apps"

  if ! [ -n "${MACOS}" ]; then
    HOMEBREW_BUNDLE_CASK_SKIP=1
    HOMEBREW_BUNDLE_MAS_SKIP=1
  fi

  info "Make sure you're logged into the App Store"
  echo 'Press any key to continue'
  read -r

  if [ -f "${HOME}/.Brewfile" ]; then
    brew bundle check --global || brew bundle --global
    success "Installed from Brewfile \n"
  else
    info "No Brewfile found \n"
  fi
}

if ! [ -n "${$CODESPACES}" ]; then
  install_brew
  configure_git
  bundle_install
fi

configure_dotfiles

if [ -n "${MACOS}" ]; then
  setup_macOS_preferences() {
    info "Setting up macOS defaults"

    source "${HOME}/.dotfiles/.macos"

    # # Restart affected apps
    # for APP in "Dock" "Finder" "Safari"; do
    #   killall "${APP}" > /dev/null 2>&1
    # done

    success "macOS defaults set \n"

  }
  setup_macOS_preferences
fi

success "Installation complete. Your dotfiles are now configured!"

# Some macOS system changes require restart for changes to take effect
if [ -n "${MACOS}" ]; then
  info "Next steps: some of these changes require you to restart your computer"
  question "Restart now? (y/n)"
  read -p " " -e RESTART

  if [[ "${RESTART}" =~ y[es]? ]]; then
    for i in {03..01}; do
      echo -en "\rRestarting in $i..."
      sleep 1
    done
    echo ''
    sudo shutdown -r now
  fi
fi

