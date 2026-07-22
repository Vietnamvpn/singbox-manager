#!/bin/bash
# File: node/start.sh

INSTALL_DIR="/usr/local/singbox-manager"
source "$INSTALL_DIR/lib/color.sh"

echo -e "${YELLOW}Đang khởi động Sing-box...${NC}"
systemctl start singbox

if systemctl is-active --quiet singbox; then
    echo -e "${GREEN}Sing-box đã khởi động thành công!${NC}"
else
    echo -e "${RED}Khởi động thất bại. Kiểm tra lỗi bằng lệnh: journalctl -u singbox -e${NC}"
fi