#!/bin/sh
set -e

# Check if macOS, else assume Linux
if [ "$(uname -s)" == "Darwin" ]; then
  MACOS=1
  GIT_CREDENTIAL="osxkeychain"
else
  GIT_CREDENTIAL="cache"
fi

# Pretty logs
info() {
  printf "\r\n\e[01;34m→ \e[39m$1\e[0m \n"
}

success() {
  printf "\r\e[01;32m✔︎ \e[39m$1\e[0m \n"
}

question() {
  printf "\e[01;33m? \e[39m$1\e[0m"
}

# Install Homebrew
install_brew() {
  if ! command -v brew &> /dev/null; then
    info "Installing Homebrew…"

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    success "Homebrew installed"
  fi
}
install_brew

# Configure git
configure_git() {
  info "Configuring git…"
  question "Your full name:"
  read -p ' ' -e GIT_NAME

  question 'Your email:'
  read -p ' ' -e GIT_EMAIL

  question "Your GitHub username:"
  read -p ' ' -e GITHUB_USERNAME

  question "Your GitHub PAT for auth:"
  read -p ' ' -e GITHUB_TOKEN

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
  success "Git configured"
}
configure_git

configure_dotfiles() {
  info "Cloning dotfiles repository…"

  if ! [ -d "${HOME}/.dotfiles" ]; then
    git clone https://github.com/${GITHUB_USERNAME}/dotfiles ~/.dotfiles
  else
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
}
configure_dotfiles

bundle_install() {
  info "Installing formulae, casks, and apps"

  if ! [ -n "$MACOS" ]; then
    HOMEBREW_BUNDLE_CASK_SKIP=1
    HOMEBREW_BUNDLE_MAS_SKIP=1
  fi

  info "Make sure you're logged into the App Store"
  echo 'Press any key to continue'
  read -r

  if ! [ -f "${HOME}/.Brewfile" ]; then
    brew bundle check --global || brew bundle --global
    success "Installed from Brewfile"
  else
    info "No Brewfile found"
  fi
}
bundle_install

if [ -n "$MACOS" ]; then
  setup_macOS_preferences() {
    info "Setting up macOS defaults"

    source "${HOME}/.dotfiles/.macos"

    success "macOS defaults set"

    # Restart affected apps
    for APP in "Dock" "Finder" "Safari"; do
      killall "${APP}" > /dev/null 2>&1
    done
  }
  setup_macOS_preferences
fi

success "Install complete"

# Restart for some system changes to take effect
info "Some of these changes require you to restart"
question "Restart now? (y/n)"
read -p ' ' -e RESTART
shopt -s nocasematch
if [[ "${RESTART}" =~ y[es]? ]]; then
  for i in {03..01}; do
    echo -en "\rRestarting in $i..."
    sleep 1
  done
  echo ''
  sudo shutdown -r now
fi
