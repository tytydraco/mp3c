#!/usr/bin/env bash
# shellcheck disable=SC1090
# shellcheck disable=SC1091

SCRIPT_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")"
WORKING_DIR="$SCRIPT_DIR/working"
CONVERTERS_DIR="$SCRIPT_DIR/converters"
CONFIG_FILE="$SCRIPT_DIR/config.sh"
FFMPEG_YP3_DIR="$SCRIPT_DIR/tools/ffmpeg/yp3_patch"

function source_converters() {
    while IFS= read -r -d '' lib_file; do
        source "$lib_file"
    done < <(find "$CONVERTERS_DIR" -type f -name "*.sh" -print0 | sort -z)
}

function pull_yp3_binaries() {
    local name

    mkdir -p "$FFMPEG_YP3_DIR"

    function pull_arch_binary() {
        [[ -f "$FFMPEG_YP3_DIR/$1" ]] && return 0
        wget -P "$FFMPEG_YP3_DIR" "https://github.com/tytydraco/static-ffmpeg-yp3-patch/releases/latest/download/$1"
        chmod +x "$FFMPEG_YP3_DIR/$1"
    }

    case "$(uname -m)" in
        x86_64|amd64)
            pull_arch_binary "ffmpeg-amd64"
            FFMPEG_YP3="$FFMPEG_YP3_DIR/ffmpeg-amd64"
            ;;
        aarch64|arm64)
            pull_arch_binary "ffmpeg-arm64"
            FFMPEG_YP3="$FFMPEG_YP3_DIR/ffmpeg-arm64"
            ;;
        *)
            echo "Unsupported architecture."
            exit 1
            ;;
    esac
}

function convert_all() {
    local dir
    local array_name
    local files

    for mode in audio image text video; do
        array_name="CONVERTERS_${mode^^}[@]"

        [[ -z "${!array_name}" ]] && continue

        dir="$WORKING_DIR/$mode"
        [[ ! -d "$dir" ]] && continue

        mapfile -d '' files < <(find "$dir" -type f -print0)
        [[ "${#files[@]}" -eq 0 ]] && continue

        for input_file in "${files[@]}"; do
            for converter in "${!array_name}"; do
                "$converter" "$input_file"
            done

	    [[ "$PRESERVE_ORIGINAL" == "false" ]] && rm "$input_file"
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

    convert_all
}

export SCRIPT_DIR
export WORKING_DIR
export CONVERTERS_DIR
export CONFIG_FILE
export FFMPEG_YP3

# Execute the program.
[[ "${BASH_SOURCE[0]}" == "$0" ]] && main
