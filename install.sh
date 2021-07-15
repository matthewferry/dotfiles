#!/bin/sh
set -e

if [ "$(uname -s)" == "Darwin" ]; then
  MACOS=1
  VSCODE_SETTINGS_PATH="${HOME}/Library/Application Support"
  GIT_CREDENTIAL="osxkeychain"
else
  VSCODE_SETTINGS_PATH="${HOME}/.config"
  GIT_CREDENTIAL="cache"
fi

info() {
  printf "\r\n\033[00;34m→ $1…\033[0m\n"
}

success() {
  printf "\r\033[01;32m✔︎ $1\033[0m \n"
}

question() {
  printf "\033[1;33m? $1\033[0m "
}

install_brew() {
  info "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  brew update --quiet
  success "Homebrew installed"
}
# install_brew

configure_git() {
  info "Configuring git"
  brew install --quiet git
  question "Your full name:"
  read -e GIT_NAME
  question 'Your email:'
  read -e GIT_EMAIL
  question "Your GitHub username:"
  read -e GITHUB_USERNAME
  question "Your GitHub PAT for auth:"
  read -e GITHUB_TOKEN
  git config --global user.name "${GIT_NAME}"
  git config --global user.email "${GIT_EMAIL}"
  git config --global github.user "${GITHUB_USERNAME}"
  git config --global credential.helper "${GIT_CREDENTIAL}"
  git config --global push.default simple
  git config --global core.excludesfile "${HOME}/.gitignore"
  printf "protocol=https\\nhost=github.com\\n" | git credential reject
  printf "protocol=https\\nhost=github.com\\nusername=%s\\npassword=%s\\n" \
        "${GITHUB_USERNAME}" "${GITHUB_TOKEN}" | git credential approve
  success "Git configured"
}
# configure_git

congigure_dotfiles() {
  info "Symlinking dotfiles"
  git clone https://github.com/${GITHUB_USERNAME}/dotfiles ~/.dotfiles
  cd ~/.dotfiles
  info "Symlinking dotfiles"
  for LINK in Brewfile zshrc gitignore; do
    ln -s "${PWD}/.${LINK}" "${HOME}/.${LINK}"
    success "Symlinked ${LINK} to ${HOME}"
  done
  
  info "Symlinking vscode settings"
  rm "${VSCODE_SETTINGS_PATH}/Code/User/settings.json"
  ln -s "${PWD}/.vscode/settings.json" "${VSCODE_SETTINGS_PATH}/Code/User/settings.json"
  success "Symlinked vscode settings to ${VSCODE_SETTINGS_PATH}"
}
# congigure_dotfiles

bundle_install() {
  info "Installing formulae, casks, and apps"
  if ! [ -n "$MACOS" ]; then
    HOMEBREW_BUNDLE_CASK_SKIP=1
    HOMEBREW_BUNDLE_MAS_SKIP=1
  fi
  brew bundle check --global || brew bundle --global
  success "Installed from Brewfile"
}
# bundle_install

if [ -n "$MACOS" ]; then
  setup_macOS_preferences() {
    info "Setting up macOS defaults"
    source "${PWD}/macos.sh"
    success "macOS defaults set"
  }
  # setup_macOS_preferences
fi

success "Install complete"