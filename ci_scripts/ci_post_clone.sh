#!/bin/zsh

set -e

script_dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
cd "$script_dir/.."

defaults write com.apple.dt.Xcode IDEPackageOnlyUseVersionsFromResolvedFile -bool NO
defaults write com.apple.dt.Xcode IDEDisableAutomaticPackageResolution -bool NO

curl https://mise.jdx.dev/install.sh | sh
export PATH=$PATH:/Users/local/.local/bin
mise install # Installs the version from .mise.toml

make
