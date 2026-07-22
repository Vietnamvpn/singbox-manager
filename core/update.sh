#!/bin/bash
# File: core/update.sh

INSTALL_DIR="/usr/local/singbox-manager"
source "$INSTALL_DIR/lib/color.sh"

echo -e "${YELLOW}Đang kiểm tra bản cập nhật Sing-box core...${NC}"
LATEST_VERSION=$(curl -s "https://api.github.com/repos/SagerNet/sing-box/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [[ -z "$LATEST_VERSION" ]]; then
    echo -e "${RED}Lỗi: Không thể lấy thông tin phiên bản mới nhất từ Github.${NC}"
    exit 1
fi

# Lấy phiên bản hiện tại đang cài đặt
CURRENT_VERSION=$(/usr/local/bin/sing-box version 2>/dev/null | grep 'sing-box version' | awk '{print $3}')

if [[ "v$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
    echo -e "${GREEN}Bạn đang sử dụng phiên bản Sing-box mới nhất (v$CURRENT_VERSION).${NC}"
else
    echo -e "${YELLOW}Phát hiện phiên bản mới: $LATEST_VERSION (Hiện tại: v$CURRENT_VERSION)${NC}"
    echo -e "${YELLOW}Tiến hành cập nhật...${NC}"
    
    # Tái sử dụng core/install.sh để tải bản mới
    bash "$INSTALL_DIR/core/install.sh"
    
    # Khởi động lại tiến trình để nhận core mới
    systemctl restart singbox
    echo -e "${GREEN}Cập nhật hoàn tất!${NC}"
fi