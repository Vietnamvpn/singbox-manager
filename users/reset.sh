#!/bin/bash
# File: users/reset.sh

INSTALL_DIR="/usr/local/singbox-manager"
source "$INSTALL_DIR/lib/color.sh"
CONFIG_FILE="$INSTALL_DIR/config/config.json"
KEYS_FILE="$INSTALL_DIR/config/public_keys.json"
DOMAINS_FILE="$INSTALL_DIR/config/domains.json"

echo -e "${RED}CẢNH BÁO: Thao tác này sẽ XÓA TOÀN BỘ danh sách người dùng và các Node hiện có!${NC}"
read -p "Bạn có chắc chắn muốn tiếp tục không? (y/n): " confirm

if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    # Lọc bỏ các inbound, outbound và route rule liên quan đến Node (có chứa prefix inbound_ hoặc outbound_)
    jq 'del(.inbounds[]? | select(.tag? and (.tag | startswith("inbound_")))) |
        del(.outbounds[]? | select(.tag? and (.tag | startswith("outbound_")))) |
        del(.route.rules[]? | select((.outbound? and (.outbound | startswith("outbound_"))) or (.inbound? and (type == "array" and ([.inbound[] | select(startswith("inbound_"))] | length > 0)))))' \
       "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
    
    # Reset file public_keys.json về JSON rỗng
    echo '{}' > "$KEYS_FILE"

    # Reset file domains.json về JSON rỗng
    echo '{}' > "$DOMAINS_FILE"

    echo -e "${GREEN}Đã xóa toàn bộ người dùng/Node. File cấu hình đã được làm sạch.${NC}"
    
    # Khởi động lại service
    bash "$INSTALL_DIR/node/restart.sh"
else
    echo -e "${YELLOW}Đã hủy thao tác.${NC}"
fi