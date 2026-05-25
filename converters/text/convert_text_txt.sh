#!/usr/bin/env bash

function convert_text_txt() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.txt"

    [[ "$input_file" == "$output_file" ]] && return 0

    pandoc \
        "$input_file" \
        -t plain \
        -o "$output_file"
}

export -f convert_text_txt