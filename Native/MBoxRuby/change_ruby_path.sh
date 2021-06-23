#!/bin/sh

declare -a arr=("${TARGET_BUILD_DIR}/${EXECUTABLE_PATH}" "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}/RubyGateway.framework/RubyGateway")
echo "${TARGET_BUILD_DIR}/${EXECUTABLE_PATH}"
set -x
for p in "${arr[@]}"
do
    path=$(otool -L "$p" | grep /usr/lib/libruby. | sed 's/^[[:blank:]]*//;s/[[:blank:]].*$//')
    install_name_tool -change "$path" "/usr/lib/libruby.dylib" "$p"
done
