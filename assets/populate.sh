#!/bin/bash

# Setting current script directory - https://code.whatever.social/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script#246128
SOURCE=${BASH_SOURCE[0]}
while [ -L "${SOURCE}" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$( cd -P "$( dirname "${SOURCE}" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "${SOURCE}")
  [[ ${SOURCE} != /* ]] && SOURCE=${DIR}/${SOURCE} # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR=$( cd -P "$( dirname "${SOURCE}" )" >/dev/null 2>&1 && pwd )

CROSSCODE_DIR=""
# Checking if there is a first argument and it's CrossCode's base path
if [ $# -eq 1 ] && [ -d "${1}" ]; then
    if [ -d "${1}/assets" ] && [ -r "${1}/assets" ]; then
        CROSSCODE_DIR="${1}"
    else
        echo -e "\"${1}\" is not a valid CrossCode installation directory."
        echo "Check if the directory exists and has read permissions."
        exit 1
    fi
fi

while [ -z "${CROSSCODE_DIR}" ]; do
    echo -n "Input CrossCode installation directory: "
    read -r CROSSCODE_DIR
    if [ -z "${CROSSCODE_DIR}" ]; then
        echo "Given directory is empty, please provide a valid directory."
    elif [ ! -d "${CROSSCODE_DIR}" ]; then
        echo "Given directory does not exist."
    elif [ ! -r "${CROSSCODE_DIR}" ]; then
        echo "Given directory cannot be read."
    elif [ ! -d "${CROSSCODE_DIR}/assets" ] && [ ! -r "${CROSSCODE_DIR}/assets" ]; then
        echo "Given directory does not have assets directory or assets directory does not have read permissions."
        echo "Please provide a valid CrossCode installation directory."
    fi
done

# Get list of needed assets from assets.txt and copy them into script directory
while IFS='=' read -r name path; do
    if [ "${name}" = "HallFetica" ]; then
        echo "Downloading Hall Fetica font..."
        if wget -q -O "${DIR}/${name}.ttf" "${path}"; then
            echo "Downloaded Hall Fetica font successfully."
        else
            >&2 echo "Failed to download Hall Fetica font."
            exit 1
        fi
    else
        echo "Copying ${name}..."
        if ! cp "${CROSSCODE_DIR}/${path}" "${DIR}/${name}.${path##*.}"; then
            >&2 echo "Failed to copy ${name}."
            exit 1
        fi
    fi
done < "${DIR}/assets-list"

echo ""
echo "Assets copied successfully."
echo ""

# Edit login fields if requested
echo "The first login field asset is assymetric."
echo "Do you wish to modify it so it look's like in the preview? (y/N): "
read -r modify_asset
if [ "${modify_asset}" = "y" ] || [ "${modify_asset}" = "Y" ]; then
    if command -v magick > /dev/null; then
        magick "${DIR}/login-fields.png" \
            -fill "#2c98f0" -draw "point 17,0 point 18,0" \
            -fill "#5ecdfa" -draw "line 17,1 17,2 line 18,1 18,2 line 17,24 17,25 line 18,24 18,25" \
            -fill "#2c98f0" -draw "line 17,3 17,23 line 18,3 18,23" \
            -fill "#2c98f0" -draw "point 22,0 point 23,0" \
            -fill "#5ecdfa" -draw "line 22,1 22,2 line 23,1 23,2 line 22,24 22,25 line 23,24 23,25" \
            -fill "#2c98f0" -draw "line 22,3 22,23 line 23,3 23,23" \
            "${DIR}/login-fields-tmp.png"
        mv "${DIR}/login-fields-tmp.png" "${DIR}/login-fields.png"
    else
        echo "Magick not found, the asset population will stop now."
        exit 0
    fi
fi
echo "Finished populating assets."
exit 0
