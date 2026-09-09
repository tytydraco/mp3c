#!/usr/bin/env bash

_has_audio() {
	local output

	output="$(ffprobe \
		-v error \
		-select_streams a:0 \
		-show_entries stream=index \
		-of csv=p=0 \
		"$1")" || return 1

	[[ -n "$output" ]]
}

_choose_fps() {
	local -a fps_allowed
	local fps_max
	local fps_raw
	local fps_original
	local fps_nearest

	# Find valid FPS within [9, 25].
	readarray -t fps_allowed < <(seq 9 25 | awk '22050 % $1 == 0 { print $1 }')
	fps_max="${fps_allowed[-1]}"

	fps_raw="$(ffprobe \
		-v error \
		-select_streams v:0 \
		-show_entries stream=avg_frame_rate \
		-of csv=p=0 \
		"$1")" || return 1
	fps_original="$(awk -F '/' \
		'{ if ($2) print $1 / $2; else print $1 }' <<< "$fps_raw")"
	fps_nearest="$(printf \
		'%s\n' \
		"${fps_allowed[@]}" | awk \
		-v fps="$fps_original" \
		'$1 >= fps { print $1; exit }')"

	printf '%s\n' "${fps_nearest:-$fps_max}"
}

convert_video_uid0005() {
	[[ -n "${1:-}" ]] || return 1

	local -r input_file="$1"
	local -r output_file="${2:-${input_file%.*}.uid0005.amv}"

	local fps
	local block_size

	fps="$(_choose_fps "$input_file")" || return 1
	block_size="$((22050 / fps))"

	local -r size='128:128'
	local -r ffmpeg_args=(
		-f amv
		-c:v amv
		-filter:v
		"
            scale=$size:force_original_aspect_ratio=increase:flags=area,
            crop=$size
        "
		-sws_flags 'accurate_rnd+full_chroma_int+full_chroma_inp'
		-r:v "$fps"
		-block_size:a "$block_size"
	)

	local ffmpeg_map_args=()
	if _has_audio "$input_file"; then
		ffmpeg_map_args=(
			-map 0:v:0
			-map 0:a:0
		)
	else
		ffmpeg_map_args=(
			-f lavfi
			-i 'anullsrc=channel_layout=mono:sample_rate=22050'
			-map 0:v:0
			-map 1:a
			-shortest
		)
	fi

	ffmpeg \
		-nostdin \
		-n \
		-i "$input_file" \
		"${ffmpeg_map_args[@]}" \
		"${ffmpeg_args[@]}" \
		"$output_file"
}

export -f _has_audio
export -f _choose_fps
export -f convert_video_uid0005

[[ "${BASH_SOURCE[0]}" == "$0" ]] && convert_video_uid0005 "$@"
