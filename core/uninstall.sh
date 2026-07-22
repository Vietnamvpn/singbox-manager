#!/bin/bash
# File: core/uninstall.sh

INSTALL_DIR="/usr/local/singbox-manager"
source "$INSTALL_DIR/lib/color.sh"

echo -e "${RED}CẢNH BÁO: Thao tác này sẽ gỡ cài đặt hoàn toàn Sing-box và xóa toàn bộ dữ liệu người dùng!${NC}"
read -p "Bạn có chắc chắn muốn gỡ cài đặt không? (y/n): " confirm

if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    echo -e "${YELLOW}Đang dừng và xóa service...${NC}"
    systemctl stop singbox >/dev/null 2>&1
    systemctl disable singbox >/dev/null 2>&1
    rm -f /etc/systemd/system/singbox.service
    systemctl daemon-reload

    echo -e "${YELLOW}Đang xóa tệp thực thi và mã nguồn...${NC}"
    rm -f /usr/local/bin/sing-box
    rm -f /usr/bin/vvc
    rm -rf "$INSTALL_DIR"

    echo -e "${GREEN}Đã gỡ cài đặt thành công! Tạm biệt.${NC}"
else
    echo -e "${YELLOW}Đã hủy thao tác gỡ cài đặt.${NC}"
fi