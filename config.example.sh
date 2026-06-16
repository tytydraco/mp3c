#!/usr/bin/env bash

PRESERVE_ORIGINAL="true"
CONVERTERS_AUDIO=(
    "convert_audio_adts_aac"
    "convert_audio_mp3"
)
CONVERTERS_IMAGE=(
    "convert_image_uid0001"
    "convert_image_uid0002"
    "convert_image_uid0003"
    "convert_image_uid0004"
    "convert_image_uid0005"
    "convert_image_uid0006"
    "convert_image_uid0007"
    "convert_image_uid0008"
    "convert_image_uid0009"
    "convert_image_uid0010"
)
CONVERTERS_TEXT=(
    "convert_text_txt"
)
CONVERTERS_VIDEO=(
    "convert_video_uid0001"
    "convert_video_uid0002"
    "convert_video_uid0003"
    "convert_video_uid0004"
    "convert_video_uid0005"
    "convert_video_uid0006"
    "convert_video_uid0007"
    "convert_video_uid0008"
    "convert_video_uid0009"
    "convert_video_uid0010"
    "convert_video_uid0011"
)

export PRESERVE_ORIGINAL
export CONVERTERS_AUDIO
export CONVERTERS_IMAGE
export CONVERTERS_TEXT
export CONVERTERS_VIDEO