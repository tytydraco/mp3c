#!/usr/bin/env bash

convert_image_uid0001() {
	[[ -n "${1:-}" ]] || return 1

	local -r input_file="$1"
	local -r output_file="${2:-${input_file%.*}.uid0001.jpg}"

	local -r size='240x320'
	local -r magick_args=(
		-interlace none
		-auto-orient
		-colorspace sRGB
		-strip
		-rotate '-90>'
		-resize "$size^"
		-gravity center
		-extent "$size"
	)

	magick \
		"$input_file" \
		"${magick_args[@]}" \
		"$output_file"
}

export -f convert_image_uid0001

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
	convert_image_uid0001 "$@"
fi
