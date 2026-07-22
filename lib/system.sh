#!/bin/bash
# File: lib/system.sh

# Hàm kiểm tra quyền root
function check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "\033[0;31mLỗi: Vui lòng chạy script bằng quyền root (sudo -i).\033[0m"
        exit 1
    fi
}

# Hàm kiểm tra hệ điều hành
function check_os() {
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        OS=$ID
    else
        echo -e "\033[0;31mKhông thể xác định hệ điều hành. Chỉ hỗ trợ Linux.\033[0m"
        exit 1
    fi
}