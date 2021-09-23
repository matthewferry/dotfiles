# dotfiles

My personal dotfiles. Contains:

- .zshrc with a minimal prompt and completion
- a very simple Terminal.app theme using macOS system colors with light/dark out of box
- a global gitignore
- a macos script to set my system preferences
- Brewfile with all the stuffs I couldn’t live without

## Installation

The install script is on a separate branch so that GitHub Codespaces does a minimal copy of my dotfiles and doesn’t run the script.

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/matthewferry/dotfiles/install/install.sh)"
```
