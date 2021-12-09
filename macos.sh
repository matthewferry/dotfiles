#!/bin/sh

# Finder > Preferences > General
# Show all filename extensions 
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder > Preferences > General
# Show these items on ~/Desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false

# Finder > Preferences > General
# Show $HOME when opening new Finder windows
# defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}"

# Finder > Preferences > Sidebar
# Show these items in Finder sidebar
# defaults write com.apple.finder ShowRecentTags -bool false
# defaults write com.apple.finder SidebarPlacesSectionDisclosedState -bool true
# defaults write com.apple.finder SidebarShowingSignedIntoiCloud -bool true
# defaults write com.apple.finder SidebarShowingiCloudDesktop -bool false

# Finder > Show view options
# Always default to column view
# defaults write com.apple.Finder FXPreferredViewStyle -string "clmv"

# Finder > Show view options
# Arrange by kind
# defaults write com.apple.Finder FXArrangeGroupViewBy -string "Kind"
# /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy kind" ~/Library/Preferences/com.apple.finder.plist

# Safari > Disable Java
# defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled -bool false
# defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles -bool false

# Safari > View > Hide/Show Favorites Bar
# Hides Safari’s favorites/bookmarks bar by default
defaults write com.apple.Safari ShowFavoritesBar -bool false

# Safari > Preferences > Advanced
# Show Developer menu item for developer tools
defaults write com.apple.Safari.SandboxBroker ShowDevelopMenu -bool true

# Safari > Preferences > Search > Search engine
# Set the Safari default search engine to DuckDuckGo
# defaults write -g NSPreferredWebServices -string "{ NSWebServicesProviderWebSearch = { NSDefaultDisplayName = DuckDuckGo; NSProviderIdentifier = \"com.duckduckgo\"; }; }"
# defaults write com.apple.SafariServices SearchProviderIdentifierMigratedToSystemPreference -int 1
# defaults write com.apple.Safari SearchProviderIdentifier -string "com.duckduckgo"
# defaults write com.apple.SafariTechnologyPreview SearchProviderIdentifier -string "com.duckduckgo"

# System Preferences > General > Appearance
# Set Appearance to "Auto"
# defaults write -g AppleInterfaceStyleSwitchesAutomatically -bool true

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
# sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1
# sudo launchctl load /System/Library/LaunchDaemons/com.apple.alf.agent.plist 2>/dev/null

# System Preferences > Security & Privacy > Filevault
# Enable FileVault and output the recovery key
# if ! fdesetup status | grep $Q -E "FileVault is (On|Off, but will be enabled after the next restart)." >/dev/null; then
#     sudo fdesetup enable -user "${USER}" | tee ~/Desktop/"FileVault Recovery Key.txt"
# fi


# Screencapture > Options > Save to…
# Changes default location for screencaptures to ~/Documents
defaults write com.apple.screencapture location -string "${HOME}/Documents/Screenshots/"

# Terminal > Preferences > Profiles
# Set default theme to my modified version of Basic with system colors for auto light/dark mode
open "${PWD}/matthewferry.terminal"
sleep 1 # Wait to make sure the theme is loaded
defaults write com.apple.Terminal "Default Window Settings" -string "matthewferry"
defaults write com.apple.Terminal "Startup Window Settings" -string "matthewferry"
