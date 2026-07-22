#!/bin/bash
# File: users/add.sh

INSTALL_DIR="/usr/local/singbox-manager"
source "$INSTALL_DIR/lib/color.sh"
CONFIG_FILE="$INSTALL_DIR/config/config.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${YELLOW}Khởi tạo config.json cơ bản...${NC}"
    echo '{"log": {"level": "info"}, "inbounds": [], "outbounds": [{"type": "direct", "tag": "direct"}]}' > "$CONFIG_FILE"
fi

clear
echo -e "${CYAN}====================================================${NC}"
echo -e "${GREEN}             THÊM NGƯỜI DÙNG / NODE MỚI             ${NC}"
echo -e "${CYAN}====================================================${NC}"
echo -e "${YELLOW} 1.${NC} VLESS (Reality + gRPC)"
echo -e "${YELLOW} 2.${NC} Hysteria2"
echo -e "${YELLOW} 3.${NC} TUIC"
echo -e "${YELLOW} 0.${NC} Hủy bỏ"
echo -e "${CYAN}====================================================${NC}"
read -p "Chọn giao thức (0-3): " proto_choice

case $proto_choice in
    1) PROTO="vless" ;;
    2) PROTO="hysteria2" ;;
    3) PROTO="tuic" ;;
    0) exit 0 ;;
    *) echo -e "${RED}Lựa chọn không hợp lệ!${NC}"; exit 1 ;;
esac

TEMPLATE_FILE="$INSTALL_DIR/config/templates/${PROTO}.json"
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo -e "${RED}Lỗi: Không tìm thấy file mẫu $TEMPLATE_FILE tại VPS.${NC}"
    read -p "Nhấn Enter để thoát..."
    exit 1
fi

read -p "Nhập Port ($PROTO): " PORT
read -p "Nhập Tên người dùng (Username/Ghi chú): " USERNAME
read -p "Nhập SNI (vd: yahoo.com): " SNI

UUID=$(cat /proc/sys/kernel/random/uuid)
PASSWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | head -c 12)
PRIVATE_KEY=""
PUBLIC_KEY=""

if [ "$PROTO" == "vless" ]; then
    echo -e "${YELLOW}Đang tạo Reality Keypair cho VLESS...${NC}"
    KEYPAIR=$(/usr/local/bin/sing-box generate reality-keypair)
    PRIVATE_KEY=$(echo "$KEYPAIR" | grep "PrivateKey" | awk '{print $2}')
    PUBLIC_KEY=$(echo "$KEYPAIR" | grep "PublicKey" | awk '{print $2}')
fi

NEW_INBOUND=$(cat "$TEMPLATE_FILE" | \
    sed "s/\"listen_port\": \"PORT\"/\"listen_port\": $PORT/g" | \
    sed "s/PORT/$PORT/g" | \
    sed "s/USERNAME/$USERNAME/g" | \
    sed "s/PASSWORD/$PASSWORD/g" | \
    sed "s/SNI/$SNI/g" | \
    sed "s/UUID/$UUID/g" | \
    sed "s/PRIVATE_KEY/$PRIVATE_KEY/g" | \
    sed "s/PUBLIC_KEY/$PUBLIC_KEY/g")

jq --argjson new_inbound "$NEW_INBOUND" '.inbounds += [$new_inbound]' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"

echo -e "${GREEN}Đã thêm thành công!${NC}"
echo -e "${CYAN}====================================================${NC}"
echo -e "Giao thức : $PROTO"
echo -e "Port      : $PORT"
echo -e "Username  : $USERNAME"
[[ "$PROTO" == "vless" || "$PROTO" == "tuic" ]] && echo -e "UUID      : $UUID"
[[ "$PROTO" == "hysteria2" || "$PROTO" == "tuic" ]] && echo -e "Password  : $PASSWORD"
[[ "$PROTO" == "vless" ]] && echo -e "Public Key: $PUBLIC_KEY"
echo -e "${CYAN}====================================================${NC}"

bash "$INSTALL_DIR/node/restart.sh"