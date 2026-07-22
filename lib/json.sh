#!/bin/bash
# File: lib/json.sh

# Hàm đọc giá trị bất kỳ từ file cấu hình JSON
# Cách dùng: read_json_value ".inbounds[0].type" "/path/to/config.json"
function read_json_value() {
    local key=$1
    local file=$2
    if [ -f "$file" ]; then
        jq -r "${key}" "$file" 2>/dev/null
    else
        echo "null"
    fi
}

# Hàm kiểm tra tính hợp lệ của file JSON
function check_json_valid() {
    local file=$1
    if jq -e . >/dev/null 2>&1 <<< "$(cat "$file")"; then
        return 0 # Hợp lệ
    else
        return 1 # Lỗi JSON
    fi
}