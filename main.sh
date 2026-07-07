#!/usr/bin/env bash
# shellcheck disable=SC1090
# shellcheck disable=SC1091

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
WORKING_DIR="$SCRIPT_DIR/working"
CONVERTERS_DIR="$SCRIPT_DIR/converters"
CONFIG_FILE="$SCRIPT_DIR/config.sh"

FFMPEG_YP3_DIR="$SCRIPT_DIR/tools/ffmpeg/yp3_patch"
FFMPEG_YP3="$FFMPEG_YP3_DIR/ffmpeg-amd64" # Or: WINEDEBUG=-all wine "$SCRIPT_DIR/tools/ffmpeg/vendor/ffmpeg-mod-shenju.exe"
[[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]] && FFMPEG_YP3="$FFMPEG_YP3_DIR/ffmpeg-arm64"

function source_converters() {
    while IFS= read -r -d '' lib_file; do
        source "$lib_file"
    done < <(find "$CONVERTERS_DIR" -type f -name "*.sh" -print0 | sort -z)
}

function pull_yp3_binaries() {
    local name

    mkdir -p "$FFMPEG_YP3_DIR"
    
    for platform in amd64 arm64; do
        for binary in ffmpeg ffprobe; do
            name="$binary-$platform"
            [[ -f "$FFMPEG_YP3_DIR/$name" ]] && continue

            wget -P "$FFMPEG_YP3_DIR" "https://github.com/tytydraco/static-ffmpeg-yp3-patch/releases/latest/download/$binary-$platform"
            chmod +x "$FFMPEG_YP3_DIR/$binary-$platform"
        done
    done
}

function main() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo "No config.sh file found."
        exit 1
    fi

    pull_yp3_binaries

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

# Execute the program.
[[ "${BASH_SOURCE[0]}" == "$0" ]] && main