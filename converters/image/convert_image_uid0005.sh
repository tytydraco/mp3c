#!/usr/bin/env bash

convert_image_uid0005() {
    [[ -n "${1:-}" ]] || return 1

    local -r input_file="$1"
    local -r output_file="${2:-${input_file%.*}.uid0005.jpg}"

    local -r size='128x128'
    local -r convert_args=(
        -interlace none
        -auto-orient
        -colorspace sRGB
        -strip
        -resize "$size^"
        -gravity center
        -extent "$size"
    )

    convert \
        "$input_file" \
        "${convert_args[@]}" \
        "$output_file"
}

export -f convert_image_uid0005

[[ "${BASH_SOURCE[0]}" == "$0" ]] && convert_image_uid0005 "$@"