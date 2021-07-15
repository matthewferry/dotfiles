#!/bin/sh

# System Preferences > General > Appearance
# Set Appearance to "Auto"
defaults write -g AppleInterfaceStyleSwitchesAutomatically -bool true

# System Preferences > Language & Region > General > Time Format
# Enforces 24 hour time across all timestamps and clocks
defaults write -g AppleICUForce24HourTime -bool true

# System Preferences > Dock & Menu Bar > Dock size
# Set the dock size to small
defaults write com.apple.dock tilesize -int 42

# System Preferences > Dock & Menu Bar > Dock
# Set dock to hide/show automatically
defaults write com.apple.dock autohide -bool true

# System Preferences > Dock & Menu Bar > Dock
# Set the dock on the left side of the display
defaults write com.apple.dock orientation -string "left"

# System Preferences > Dock & Menu Bar > Dock
# Set dock to not display recent apps
defaults write com.apple.dock show-recents -bool false

# System Preferences > Dock & Menu Bar > Menu Bar
# Automatically hide/show Menu Bar
defaults write -g _HIHideMenuBar -bool true

# System Preferences > Security & Privacy > General
# Require password immediately after sleep or screensaver
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# System Preferences > Security & Privacy > Firewall
# Turn firewall on
sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1
sudo launchctl load /System/Library/LaunchDaemons/com.apple.alf.agent.plist 2>/dev/null

# System Preferences > Security & Privacy > Filevault
# Enable FileVault and output the recovery key
sudo fdesetup enable -user "${USER}" | tee ~/Desktop/"FileVault Recovery Key.txt"

# Safari > Disable Java
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles -bool false

# Safari > View > Hide/Show Favorites Bar
# Hides Safari’s favorites/bookmarks bar by default
defaults write com.apple.Safari ShowFavoritesBar -bool false

# Safari > Preferences > Advanced
# Show Developer menu item for developer tools
defaults write com.apple.Safari.SandboxBroker ShowDevelopMenu -bool true

# Safari > Preferences > Search > Search engine
# Set the Safari default search engine to DuckDuckGo
defaults write -g NSPreferredWebServices -string "{ NSWebServicesProviderWebSearch = { NSDefaultDisplayName = DuckDuckGo; NSProviderIdentifier = \"com.duckduckgo\"; }; }"
defaults write com.apple.SafariServices SearchProviderIdentifierMigratedToSystemPreference -int 1

# Screencapture > Options > Save to…
# Changes default location for screencaptures to ~/Documents
defaults write com.apple.screencapture location -string "${HOME}/Documents/"

# Terminal > Preferences > Profiles
# Set default theme to my modified version of Basic with system colors for auto light/dark mode
open "${PWD}/matthewferry.terminal"
sleep 1 # Wait to make sure the theme is loaded
defaults write com.apple.Terminal "Default Window Settings" -string "matthewferry"
defaults write com.apple.Terminal "Startup Window Settings" -string "matthewferry"

# Restart affected apps like Dock and Finder
for APP in "Dock" "Finder" "Safari"; do
  killall "${APP}" > /dev/null 2>&1
done

# Restart for some system changes to take effect
printf "\r\n\033[00;34m→ Some of these changes require you to restart.…\033[0m\n"
printf "\033[1;33m? Would you like to restart now? (y/n):\033[0m "
read -r

shopt -s nocasematch
if [[ "${REPLY}" =~ y[es]? ]]; then
  for i in {03..01}; do
    echo -en "\rRestarting in $i..."
    sleep 1
  done
  echo
  sudo shutdown -r now
fi
