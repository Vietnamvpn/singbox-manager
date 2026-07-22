#!/bin/bash
# File: users/add.sh

INSTALL_DIR="/usr/local/singbox-manager"
source "$INSTALL_DIR/lib/color.sh"
CONFIG_FILE="$INSTALL_DIR/config/config.json"

# Kiểm tra config.json
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
    echo -e "${RED}Lỗi: Không tìm thấy file mẫu $TEMPLATE_FILE.${NC}"
    exit 1
fi

read -p "Nhập Port ($PROTO): " PORT
read -p "Nhập Tên người dùng (Username/Ghi chú): " USERNAME
read -p "Nhập SNI (vd: yahoo.com): " SNI

# Khởi tạo các biến mặc định
UUID=$(cat /proc/sys/kernel/random/uuid)
PASSWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | head -c 12)
PRIVATE_KEY=""

if [ "$PROTO" == "vless" ]; then
    # VLESS yêu cầu UUID, Tên và Private Key cho Reality[cite: 1]
    echo -e "${YELLOW}Đang tạo Reality Keypair cho VLESS...${NC}"
    KEYPAIR=$(/usr/local/bin/sing-box generate reality-keypair)
    PRIVATE_KEY=$(echo "$KEYPAIR" | grep "PrivateKey" | awk '{print $2}')
    PUBLIC_KEY=$(echo "$KEYPAIR" | grep "PublicKey" | awk '{print $2}')
    echo -e "Public Key của bạn (Dùng để cấp cho Client): ${GREEN}$PUBLIC_KEY${NC}"
fi

# Thay thế các tham số trong file template
# Lưu ý: "PORT" trong mẫu là chuỗi, ta chuyển thành số nguyên trong config thực tế.
NEW_INBOUND=$(cat "$TEMPLATE_FILE" | sed "s/\"PORT\"/$PORT/g; s/\"UUID\"/\"$UUID\"/g; s/\"USERNAME\"/\"$USERNAME\"/g; s/\"PASSWORD\"/\"$PASSWORD\"/g; s/\"SNI\"/\"$SNI\"/g; s/\"PRIVATE_KEY\"/\"$PRIVATE_KEY\"/g")

# Cập nhật vào config.json bằng jq
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

# Khởi động lại service
bash "$INSTALL_DIR/node/restart.sh"