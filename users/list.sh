#!/bin/bash
# File: users/list.sh

INSTALL_DIR="/usr/local/singbox-manager"
source "$INSTALL_DIR/lib/color.sh"
CONFIG_FILE="$INSTALL_DIR/config/config.json"
KEYS_FILE="$INSTALL_DIR/config/public_keys.json"
DOMAINS_FILE="$INSTALL_DIR/config/domains.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Lỗi: Chưa tìm thấy file cấu hình config.json${NC}"
    exit 1
fi

# Lấy IP công khai của VPS
SERVER_IP=$(curl -s --max-time 5 https://api.ipify.org || curl -s --max-time 5 ifconfig.me)
if [ -z "$SERVER_IP" ]; then
    SERVER_IP="YOUR_VPS_IP"
fi

clear
echo -e "${BLUE}======================================================================${NC}"
echo -e "${GREEN}                     DANH SÁCH LINK NGƯỜI DÙNG                        ${NC}"
echo -e "${BLUE}======================================================================${NC}"

# Lấy danh sách tên người dùng duy nhất
USERNAMES=$(jq -r '[.inbounds[].users[0].name // "Node"] | unique | .[]' "$CONFIG_FILE")

if [ -z "$USERNAMES" ]; then
    echo -e "${YELLOW}Chưa có người dùng/node nào được tạo.${NC}"
    exit 0
fi

echo "$USERNAMES" | while read -r username; do
    [ -z "$username" ] && continue

    echo -e "${GREEN}User: ${YELLOW}${username}${NC}:"

    jq -c --arg uname "$username" '.inbounds[] | select((.users[0].name // "Node") == $uname)' "$CONFIG_FILE" | while read -r inbound; do
        type=$(echo "$inbound" | jq -r '.type')
        port=$(echo "$inbound" | jq -r '.listen_port')
        name=$(echo "$inbound" | jq -r '.users[0].name // "Node"')
        uuid=$(echo "$inbound" | jq -r '.users[0].uuid // ""')
        pass=$(echo "$inbound" | jq -r '.users[0].password // ""')
        sni=$(echo "$inbound" | jq -r '.tls.server_name // "yahoo.com"')
        sid=$(echo "$inbound" | jq -r '.tls.reality.short_id[0] // ""')

        # Đọc Public Key tương ứng với Port từ public_keys.json
        pbk=""
        if [ -f "$KEYS_FILE" ]; then
            pbk=$(jq -r --arg port "$port" '.[$port] // ""' "$KEYS_FILE" 2>/dev/null)
        fi

        # Đọc Domain hiển thị tương ứng với Port từ domains.json (nếu không có sẽ mặc định dùng SERVER_IP)
        HOST_ADDR="$SERVER_IP"
        if [ -f "$DOMAINS_FILE" ]; then
            custom_domain=$(jq -r --arg port "$port" '.[$port] // ""' "$DOMAINS_FILE" 2>/dev/null)
            [ -n "$custom_domain" ] && [ "$custom_domain" != "null" ] && HOST_ADDR="$custom_domain"
        fi

        case "$type" in
            vless)
                VLESS_LINK="vless://${uuid}@${HOST_ADDR}:${port}?type=grpc&security=reality&fp=chrome&sni=${sni}"
                [ -n "$pbk" ] && VLESS_LINK="${VLESS_LINK}&pbk=${pbk}"
                [ -n "$sid" ] && VLESS_LINK="${VLESS_LINK}&sid=${sid}"
                VLESS_LINK="${VLESS_LINK}&serviceName=vless-grpc#${name}"
                echo -e "${CYAN}${VLESS_LINK}${NC}"
                ;;
            hysteria2)
                echo -e "${CYAN}hysteria2://${pass}@${HOST_ADDR}:${port}?sni=${sni}&insecure=1#${name}${NC}"
                ;;
            tuic)
                echo -e "${CYAN}tuic://${uuid}:${pass}@${HOST_ADDR}:${port}?sni=${sni}&congestion_control=bbr&alpn=h3&allow_insecure=1#${name}${NC}"
                ;;
            *)
                echo -e "${YELLOW}Giao thức $type chưa hỗ trợ xuất link tự động.${NC}"
                ;;
        esac
    done
    echo -e "----------------------------------------------------------------------"
done