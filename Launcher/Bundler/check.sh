#!/bin/sh

source "${MBOX_CORE_LAUNCHER}/launcher.sh"

mbox_print_title Checking Bundler

if mbox_check_exist bundle; then
  echo "Bundler has installed."

  # Check Gems Directory
  bundle_gems_path=`bundle config --global path --parseable 2>/dev/null`
  if [[ $bundle_gems_path == "" ]]; then
    mbox_print_error "Bundler lose the path value."
    exit 1
  fi

  # Check ffi build config
  if [[ "$(uname -m)" == "arm64" ]]; then
    ffi=`bundle config --global build.ffi --parseable 2>/dev/null`
    if [[ $ffi == "" ]]; then
      mbox_print_error "Bundler lose the build.ffi value."
      exit 1
    fi
  fi
else
  mbox_print_error "Bundler is missing."
  exit 1
fi
