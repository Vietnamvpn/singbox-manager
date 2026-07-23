#!/bin/bash
# File: users/delete.sh

INSTALL_DIR="/usr/local/singbox-manager"
source "$INSTALL_DIR/lib/color.sh"
CONFIG_FILE="$INSTALL_DIR/config/config.json"
KEYS_FILE="$INSTALL_DIR/config/public_keys.json"
DOMAINS_FILE="$INSTALL_DIR/config/domains.json"

bash "$INSTALL_DIR/users/list.sh"

echo -e ""
read -p "Nhập số PORT của Node/Người dùng cần xóa (hoặc 0 để hủy): " DEL_PORT

if [ "$DEL_PORT" == "0" ] || [ -z "$DEL_PORT" ]; then
    exit 0
fi

# Kiểm tra xem Port có tồn tại không
EXISTS=$(jq "[.inbounds[] | select(.listen_port == $DEL_PORT)] | length" "$CONFIG_FILE")

if [ "$EXISTS" -gt 0 ]; then
    # Lọc bỏ inbound có listen_port trùng khớp
    jq "del(.inbounds[] | select(.listen_port == $DEL_PORT))" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"

    # Xóa Public Key tương ứng trong public_keys.json nếu có
    if [ -f "$KEYS_FILE" ]; then
        jq --arg port "$DEL_PORT" 'del(.[$port])' "$KEYS_FILE" > "${KEYS_FILE}.tmp" && mv "${KEYS_FILE}.tmp" "$KEYS_FILE"
    fi

    # Xóa Domain tương ứng trong domains.json nếu có
    if [ -f "$DOMAINS_FILE" ]; then
        jq --arg port "$DEL_PORT" 'del(.[$port])' "$DOMAINS_FILE" > "${DOMAINS_FILE}.tmp" && mv "${DOMAINS_FILE}.tmp" "$DOMAINS_FILE"
    fi

    echo -e "${GREEN}Đã xóa thành công Node/Người dùng sử dụng Port $DEL_PORT.${NC}"
    
    # Khởi động lại service
    bash "$INSTALL_DIR/node/restart.sh"
else
    echo -e "${RED}Lỗi: Không tìm thấy Port $DEL_PORT trong cấu hình.${NC}"
fi