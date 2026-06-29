#!/usr/bin/env bash
# shellcheck disable=SC1090
# shellcheck disable=SC1091

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
WORKING_DIR="$SCRIPT_DIR/working"
CONVERTERS_DIR="$SCRIPT_DIR/converters"
CONFIG_FILE="$SCRIPT_DIR/config.sh"

FFMPEG_YP3="$SCRIPT_DIR/tools/ffmpeg/ffmpeg-yp3-patch/static/ffmpeg" # Or: WINEDEBUG=-all wine "$SCRIPT_DIR/tools/ffmpeg/vendor/ffmpeg-mod-shenju.exe"
ATJ_AVI_ENCODER="$SCRIPT_DIR/tools/ffmpeg/atj-avi-encoder/make-atj-avi-encoder.sh"

function source_converters() {
    while IFS= read -r -d '' lib_file; do
        source "$lib_file"
    done < <(find "$CONVERTERS_DIR" -type f -name "*.sh" -print0 | sort -z)
}

function main() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo "No config.sh file found."
        exit 1
    fi

    # Pull latest submodules.
    git submodule update --init --recursive --remote

    source "$CONFIG_FILE"
    source_converters

    for mode in audio image text video; do
        find -L "$WORKING_DIR/$mode" -type f \
            -exec bash -c 'convert_file "$1" "$2"' _ "$mode" "{}" \;
    done
}

export SCRIPT_DIR
export WORKING_DIR
export CONVERTERS_DIR
export CONFIG_FILE
export FFMPEG_YP3
export ATJ_AVI_ENCODER

# Execute the program.
[[ "${BASH_SOURCE[0]}" == "$0" ]] && main