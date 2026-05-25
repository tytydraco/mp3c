#!/usr/bin/env bash

CONVERTERS_AUDIO=(
    "convert_audio_adts_aac"
    "convert_audio_mp3"
)
CONVERTERS_IMAGE=(
    "convert_image_agptek_m6_jpg"
    "convert_image_agptek_m6_bmp"
    "convert_image_ruizu_x52_jpg"
    "convert_image_ruizu_x52_bmp"
)
CONVERTERS_TEXT=(
    "convert_text_txt"
)
CONVERTERS_VIDEO=(
    "convert_video_1080p_mp4"
    "convert_video_agptek_m6_avi"
    "convert_video_ruizu_x52_amv"
)

export CONVERTERS_AUDIO
export CONVERTERS_IMAGE
export CONVERTERS_TEXT
export CONVERTERS_VIDEO