#!/usr/bin/env bash

function convert_text_txt() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.txt"

    if [[ "$input_file" == "$output_file" ]]; then
        echo "[$0] Input is already converted: $input_file"
        return 0
    fi

    pandoc \
        "$input_file" \
        -t plain \
        -o "$output_file"
}

export -f convert_text_txt