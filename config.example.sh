#!/usr/bin/env bash

CONVERTERS_AUDIO=(
    "convert_audio_adts_aac"
    "convert_audio_mp3"
)
CONVERTERS_IMAGE=(
    "convert_image_generic_jpg"
    "convert_image_generic_bmp"
)
CONVERTERS_TEXT=(
    "convert_text_txt"
)
CONVERTERS_VIDEO=(
    "convert_video_generic_mp4"
    "convert_video_generic_avi"
    "convert_video_generic_amv"
)

export CONVERTERS_AUDIO
export CONVERTERS_IMAGE
export CONVERTERS_TEXT
export CONVERTERS_VIDEO