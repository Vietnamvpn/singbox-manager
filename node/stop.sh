#!/bin/bash
# File: node/stop.sh

INSTALL_DIR="/usr/local/singbox-manager"
source "$INSTALL_DIR/lib/color.sh"

echo -e "${YELLOW}Đang dừng tiến trình Sing-box...${NC}"
systemctl stop singbox

if ! systemctl is-active --quiet singbox; then
    echo -e "${GREEN}Sing-box đã được dừng lại!${NC}"
else
    echo -e "${RED}Không thể dừng Sing-box. Vui lòng kiểm tra lại hệ thống.${NC}"
fi