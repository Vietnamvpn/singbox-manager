#!/bin/bash
# File: users/reset.sh

INSTALL_DIR="/usr/local/singbox-manager"
source "$INSTALL_DIR/lib/color.sh"
CONFIG_FILE="$INSTALL_DIR/config/config.json"
KEYS_FILE="$INSTALL_DIR/config/public_keys.json"

echo -e "${RED}CẢNH BÁO: Thao tác này sẽ XÓA TOÀN BỘ danh sách người dùng và các Node hiện có!${NC}"
read -p "Bạn có chắc chắn muốn tiếp tục không? (y/n): " confirm

if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    # Reset mảng inbounds về rỗng
    jq '.inbounds = []' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
    
    # Reset file public_keys.json về JSON rỗng
    echo '{}' > "$KEYS_FILE"

    echo -e "${GREEN}Đã xóa toàn bộ người dùng/Node. File cấu hình đã được làm sạch.${NC}"
    
    # Khởi động lại service
    bash "$INSTALL_DIR/node/restart.sh"
else
    echo -e "${YELLOW}Đã hủy thao tác.${NC}"
fi