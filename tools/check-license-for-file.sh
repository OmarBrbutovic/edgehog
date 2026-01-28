#!/usr/bin/env bash

# This file is part of Edgehog.
#
# Copyright 2026 SECO Mind Srl
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

# Move to project root
cd "$(dirname "$0")/.."
PROJECT_ROOT=$(pwd)
REUSE_CONFIG="$PROJECT_ROOT/REUSE.toml"

# ------------------------------------------------------------
# HELPER: Update date in REUSE.toml
# ------------------------------------------------------------
update_reuse_toml() {
    local pattern="$1"
    local current_year
    current_year=$(date +%Y)
    
    echo "  -> Updating copyright year to $current_year for pattern: [$pattern] in REUSE.toml"

    # Escape special regex characters in the pattern (like *, ., /) for use in sed
    # We escape: [ ] \ . * ^ $ /
    local escaped_pattern
    escaped_pattern=$(printf '%s\n' "$pattern" | sed 's/[][\.*^$/]/\\&/g')

    # sed logic:
    # 1. Look for the line: path = "THE_EXACT_PATTERN"
    # 2. Search down to SPDX-FileCopyrightText
    # 3. Update the year range (e.g. 2023 -> 2023-2026, or 2025 -> 2026)
    # 4. Fix 2026-2026 -> 2026
    
    sed -i "/path = .*[\"']${escaped_pattern}[\"']/,/SPDX-FileCopyrightText/ {
        /SPDX-FileCopyrightText/ {
            s/\([0-9]\{4\}\)\(-[0-9]\{4\}\)\?/\1-$current_year/
            s/$current_year-$current_year/$current_year/
        }
    }" "$REUSE_CONFIG"
}

# ------------------------------------------------------------
# DYNAMIC PATH EXTRACTION
# ------------------------------------------------------------
get_matching_reuse_pattern() {
    local file="$1"

    if [[ ! -f "$REUSE_CONFIG" ]]; then
        echo "WARNING: REUSE.toml not found at $REUSE_CONFIG" >&2
        return 1
    fi

    # Extract paths from TOML. 
    # Logic: Remove 'path = ', brackets, quotes, and convert commas to spaces.
    local patterns
    patterns=$(grep "^path =" "$REUSE_CONFIG" | sed -E 's/^path = [\[]?//;s/[\]]?$//;s/"//g;s/'"'"'//g;s/,/ /g')

    # DISABLE GLOB EXPANSION so `**` stays `**` and doesn't turn into filenames
    set -f
    
    local matched=""
    for pattern in $patterns; do
        # Temporarily re-enable globbing just for the check [[ $file == $pattern ]]
        # We need globbing to see if the file matches the pattern, 
        # but we need the loop variable $pattern to remain the raw string from TOML.
        
        # We use a subshell or temporary toggle to check the match
        if [[ "$file" == $pattern ]]; then
            matched="$pattern"
            break
        fi
    done
    
    # Re-enable glob expansion for the rest of the script
    set +f

    if [[ -n "$matched" ]]; then
        echo "$matched"
        return 0
    fi

    return 1
}

annotate() {
    local input_path="$1"
    
    # Normalize: Get absolute path, then remove the PROJECT_ROOT prefix
    local abs_path
    abs_path=$(realpath -m "$input_path")
    
    local file="${abs_path#"$PROJECT_ROOT/"}"

    # DEBUG: See exactly what the script thinks the file name is
    echo "DEBUG: Processing file: [$file]" >&2

    # Skip license folder or non-existent files
    if [[ "$file" == LICENSES/* ]]; then
        echo "skipping license files"
        return
    fi
    
    if [[ ! -e "$input_path" ]]; then
        echo "skipping non-existent: $input_path"
        return
    fi

    # 1. Check Dynamic List from REUSE.toml
    local matched_pattern
    matched_pattern=$(get_matching_reuse_pattern "$file" || true)
    
    if [[ -n "$matched_pattern" ]]; then
        echo "✓ $file is covered by REUSE.toml (aggregate annotation)"
        update_reuse_toml "$matched_pattern"
        return
    fi

    # 2. If not covered by TOML, run standard reuse annotation
    uv run reuse annotate \
        --copyright 'SECO Mind Srl' \
        --copyright-style string \
        --merge-copyrights \
        --license 'Apache-2.0' \
        --template apache \
        --skip-unrecognised \
        "$input_path"
}

if [[ $# != 0 ]]; then
    for arg in "$@"; do
        annotate "$arg"
    done
    exit
fi

# Read from stdin line by line
while read -r line; do
    [[ -z "$line" ]] && continue
    annotate "$line"
done