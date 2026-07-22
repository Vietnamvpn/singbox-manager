#!/bin/bash
# File: lib/github.sh

# Hàm lấy tag release mới nhất từ bất kỳ repository nào trên Github
# Cách dùng: get_latest_release "SagerNet/sing-box"
function get_latest_release() {
    local repo=$1
    curl -s "https://api.github.com/repos/${repo}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}