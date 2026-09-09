#!/usr/bin/env bash

convert_audio_mp3() {
	[[ -n "${1:-}" ]] || return 1

	local -r input_file="$1"
	local -r output_file="${2:-${input_file%.*}.mp3}"

	[[ "$input_file" != "$output_file" ]] || return 1

	local -ar ffmpeg_args=(
		-f mp3
		-ar:a 16000
		-ac:a 1
		-q:a 8
	)

	ffmpeg \
		-nostdin \
		-n \
		-i "$input_file" \
		"${ffmpeg_args[@]}" \
		"$output_file"
}

export -f convert_audio_mp3

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
	convert_audio_mp3 "$@"
fi
