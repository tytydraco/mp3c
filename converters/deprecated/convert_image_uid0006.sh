#!/usr/bin/env bash

function convert_image_uid0006() {
    [[ -z "$1" ]] && return 1

    local input_file="$1"
    local output_file="${2:-"${input_file%.*}.uid0006.jpg"}"

    local size="1340x1340"
    local convert_args=(
        -interlace none
        -auto-orient
        -resize "$size>"
    )

    convert \
        "$input_file" \
        "${convert_args[@]}" \
        "$output_file"
}

export -f convert_image_uid0006

[[ "${BASH_SOURCE[0]}" == "$0" ]] && convert_image_uid0006 "$@"