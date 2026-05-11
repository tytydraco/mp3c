#!/usr/bin/env bash
# shellcheck disable=SC1090
# shellcheck disable=SC1091

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKING_DIR="$SCRIPT_DIR/working"
CONVERTERS_DIR="$SCRIPT_DIR/converters"
CONFIG_FILE="$SCRIPT_DIR/config.sh"

function source_converters() {
    while IFS= read -r -d '' lib_file; do
        source "${lib_file}"
    done < <(find "$CONVERTERS_DIR" -type f -name "*.sh" -print0 | sort -z)
}

function main() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo "No config.sh file found."
        exit 1
    fi

    source "$CONFIG_FILE"
    source_converters

    for mode in audio image text video; do
        find "$WORKING_DIR/$mode" -type f \
            -exec bash -c 'convert_file $1 $2' _ "$mode" {} \;
    done
}

export SCRIPT_DIR
export WORKING_DIR
export CONVERTERS_DIR
export CONFIG_FILE

# Execute the program.
[[ "${BASH_SOURCE[0]}" == "$0" ]] && main