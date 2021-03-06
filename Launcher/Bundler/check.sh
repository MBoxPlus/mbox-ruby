#!/bin/sh

source "${MBOX_CORE_LAUNCHER}/launcher.sh"

mbox_print_title Checking Bundler

if mbox_check_exist bundle; then
  echo "Bundler has installed."

  if [[ -f "/usr/local/bin/bundle" ]]; then
    if [[ "$(cat /usr/local/bin/bundle 2>/dev/null | head -1)" == "#!/System/Library/Frameworks/Ruby.framework/Versions/2.3/usr/bin/ruby" ]]; then
      mbox_exe rm -rf /usr/local/bin/bundle
    fi
  fi

  # Check Gems Directory
  bundle_gems_path=`bundle config --global path --parseable 2>/dev/null`
  if [[ $bundle_gems_path == "" ]]; then
    mbox_print_error "Bundler lose the path value."
    exit 1
  fi
else
  mbox_print_error "Bundler is missing."
  exit 1
fi
