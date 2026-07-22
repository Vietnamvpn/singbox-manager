#!/bin/bash
# File: users/list.sh

INSTALL_DIR="/usr/local/singbox-manager"
source "$INSTALL_DIR/lib/color.sh"
CONFIG_FILE="$INSTALL_DIR/config/config.json"

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
echo -e "${CYAN}======================================================================${NC}"
echo -e "${GREEN}                     DANH SÁCH LINK NGƯỜI DÙNG                        ${NC}"
echo -e "${CYAN}======================================================================${NC}"

COUNT=1
jq -c '.inbounds[]' "$CONFIG_FILE" | while read -r inbound; do
    type=$(echo "$inbound" | jq -r '.type')
    port=$(echo "$inbound" | jq -r '.listen_port')
    name=$(echo "$inbound" | jq -r '.users[0].name // "Node"')
    uuid=$(echo "$inbound" | jq -r '.users[0].uuid // ""')
    pass=$(echo "$inbound" | jq -r '.users[0].password // ""')
    sni=$(echo "$inbound" | jq -r '.tls.server_name // "yahoo.com"')
    pbk=$(echo "$inbound" | jq -r '.users[0].public_key // .tls.reality.public_key // ""')
    sid=$(echo "$inbound" | jq -r '.tls.reality.short_id[0] // ""')

    echo -e "${YELLOW}${COUNT}. User: ${GREEN}${name}${NC} | Giao thức: ${CYAN}${type^^}${NC} | Port: ${CYAN}${port}${NC}"

    case "$type" in
        vless)
            VLESS_LINK="vless://${uuid}@${SERVER_IP}:${port}?type=grpc&security=reality&fp=chrome&sni=${sni}"
            [ -n "$pbk" ] && VLESS_LINK="${VLESS_LINK}&pbk=${pbk}"
            [ -n "$sid" ] && VLESS_LINK="${VLESS_LINK}&sid=${sid}"
            VLESS_LINK="${VLESS_LINK}&serviceName=vless-grpc#${name}"
            echo -e "   Link: ${CYAN}${VLESS_LINK}${NC}"
            ;;
        hysteria2)
            echo -e "   Link: ${CYAN}hysteria2://${pass}@${SERVER_IP}:${port}?sni=${sni}&insecure=1#${name}${NC}"
            ;;
        tuic)
            echo -e "   Link: ${CYAN}tuic://${uuid}:${pass}@${SERVER_IP}:${port}?sni=${sni}&congestion_control=bbr&alpn=h3&allow_insecure=1#${name}${NC}"
            ;;
        *)
            echo -e "   ${YELLOW}Giao thức $type chưa hỗ trợ xuất link tự động.${NC}"
            ;;
    esac
    echo -e "----------------------------------------------------------------------"
    ((COUNT++))
done