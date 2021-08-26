#!/bin/sh

source "${MBOX_CORE_LAUNCHER}/launcher.sh"

mbox_print_title Configurate Bundler

# Change Gems Installation Directory
bundle_gems_path=`bundle config --global path --parseable 2>/dev/null`
if [[ $bundle_gems_path == "" ]]; then
    mbox_exe bundle config --global path '~/.bundle/vendor'
fi

mbox_exe bundle config --global global_path_appends_ruby_scope true
