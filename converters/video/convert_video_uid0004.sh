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
	local -r fps_max=25
	local fps_raw
	local fps_original

	fps_raw="$(ffprobe \
		-v error \
		-select_streams v:0 \
		-show_entries stream=avg_frame_rate \
		-of csv=p=0 \
		"$1")" || return 1
	fps_original="$(awk -F '/' \
		'{ if ($2) print $1 / $2; else print $1 }' <<< "$fps_raw")"
	fps_original="${fps_original:-$fps_max}"

	awk -v fps="$fps_original" -v max="$fps_max" \
		'BEGIN { if (fps > max) print max; else print fps }'
}

_temporal_gop() {
	local -r fps="$1"
	local -r seconds="$2"
	awk -v fps="$fps" -v seconds="$seconds" \
		'BEGIN { r = int( ( seconds * fps + 0.5 )); print ( r < 1 ? 1 : r ) }'
}

convert_video_uid0004() {
	[[ -n "${1:-}" ]] || return 1

	local -r input_file="$1"
	local -r output_file="${2:-${input_file%.*}.uid0004.avi}"

	local fps
	fps="$(_choose_fps "$input_file")" || return 1

	local gop
	gop="$(_temporal_gop "$fps" 0.25)" || return 1

	local -r size='240:320'
	local -r ffmpeg_args=(
		-f avi
		-c:v libx264
		-x264-params 'ipratio=2:psy=0:me=tesa:subme=11:trellis=2'
		-profile:v baseline
		-filter:v
		"
			transpose=cclock:passthrough=portrait,
			scale=$size:force_original_aspect_ratio=increase:flags=area,
			crop=$size
		"
		-sws_flags 'accurate_rnd+full_chroma_int+full_chroma_inp'
		-pix_fmt:v yuvj420p
		-r:v "$fps"
		-qp:v 35
		-g:v "$gop"
		-sc_threshold:v 0
		-refs:v 1
		-c:a pcm_s16le
		-ac:a 1
		-ar:a 16000
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
			-i 'anullsrc=channel_layout=mono:sample_rate=16000'
			-map 0:v:0
			-map 1:a
			-shortest
		)
	fi

	ffmpeg-yp3-patch \
		-nostdin \
		-n \
		-i "$input_file" \
		"${ffmpeg_map_args[@]}" \
		"${ffmpeg_args[@]}" \
		"$output_file"
}

export -f _has_audio
export -f _choose_fps
export -f _temporal_gop
export -f convert_video_uid0004

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
	convert_video_uid0004 "$@"
fi
