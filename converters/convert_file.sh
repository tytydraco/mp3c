#!/usr/bin/env bash

function convert_file() {
    [[ -z "${1:-}" ]] && return 1

    # Source the config since the call will be through a subshell.
    # shellcheck disable=SC1090
    source "$CONFIG_FILE"

    local mode="$1"
    local input_file="$2"

    local converters=()
    case "$mode" in
        "audio")
            converters=("${CONVERTERS_AUDIO[@]}")
            ;;
        "image")
            converters=("${CONVERTERS_IMAGE[@]}")
            ;;
        "text")
            converters=("${CONVERTERS_TEXT[@]}")
            ;;
        "video")
            converters=("${CONVERTERS_VIDEO[@]}")
            ;;
        *)
            return 1
            ;;
    esac

    [[ "${#converters[@]}" -eq 0 ]] && return 0

    for converter in "${converters[@]}"; do
        eval "$converter" "$(printf '%q' "$input_file")"
    done
}

export -f convert_file