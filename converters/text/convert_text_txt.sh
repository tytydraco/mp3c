#!/usr/bin/env bash

convert_text_txt() {
    [[ -n "${1:-}" ]] || return 1

    local -r input_file="$1"
    local -r output_file="${2:-${input_file%.*}.txt}"

    [[ "$input_file" != "$output_file" ]] || return 1

    ebook-convert "$input_file" "$output_file"
}

export -f convert_text_txt

[[ "${BASH_SOURCE[0]}" == "$0" ]] && convert_text_txt "$@"