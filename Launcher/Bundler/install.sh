#!/bin/sh

source "${MBOX_CORE_LAUNCHER}/launcher.sh"

mbox_print_title Configurate Bundler
# 设置 bundle 下载镜像地址
# mbox_exe bundle config --global mirror.https://rubygems.org https://gems.ruby-china.com

# 设置 Gems 路径 (防止污染全局)
bundle_gems_path=`bundle config --global path --parseable 2>/dev/null`
if [[ $bundle_gems_path == "" ]]; then
    mbox_exe bundle config --global path '~/.bundle/vendor'
fi

# Bundler < 2.2 下，默认不会添加 Ruby 版本到 ~/.bundle/vendor 下，导致 Native Gem 在切换 Ruby 版本后会异常
mbox_exe bundle config --global global_path_appends_ruby_scope true
