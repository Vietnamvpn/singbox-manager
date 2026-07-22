#!/bin/bash
# File: node/restart.sh

INSTALL_DIR="/usr/local/singbox-manager"
source "$INSTALL_DIR/lib/color.sh"

echo -e "${YELLOW}Đang khởi động lại Sing-box...${NC}"
systemctl restart singbox

if systemctl is-active --quiet singbox; then
    echo -e "${GREEN}Sing-box đã khởi động lại thành công!${NC}"
else
    echo -e "${RED}Khởi động lại thất bại. Hệ thống có thể đang bị lỗi cấu hình config.json.${NC}"
fi