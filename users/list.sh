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
echo -e "${GREEN}                     DANH SÁCH NGƯỜI DÙNG / NODE                      ${NC}"
echo -e "${CYAN}======================================================================${NC}"
printf "%-5s | %-10s | %-6s | %-12s | %-20s\n" "STT" "Giao Thức" "Port" "Username" "Thông Tin (UUID/Pass)"
echo -e "----------------------------------------------------------------------"

# 1. Bảng tổng quan thông số
INDEX=1
jq -r '.inbounds[] | [.type, .listen_port, (.users[0].name // "N/A"), (.users[0].uuid // .users[0].password // "N/A")] | @tsv' "$CONFIG_FILE" | while IFS=$'\t' read -r type port name cred; do
    printf "%-5s | %-10s | %-6s | %-12s | %-20s\n" "$INDEX" "$type" "$port" "$name" "$cred"
    ((INDEX++))
done

echo -e "${CYAN}======================================================================${NC}"
echo -e "${YELLOW}                    LINK CẤU HÌNH ĐỂ THÊM VÀO APP                     ${NC}"
echo -e "${CYAN}======================================================================${NC}"

# 2. Tự động tạo Link chia sẻ cho từng Node
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

    echo -e "${GREEN}[Node $COUNT] $name ($type - Port: $port):${NC}"

    case "$type" in
        vless)
            VLESS_LINK="vless://${uuid}@${SERVER_IP}:${port}?type=grpc&security=reality&fp=chrome&sni=${sni}"
            if [ -n "$pbk" ]; then
                VLESS_LINK="${VLESS_LINK}&pbk=${pbk}"
            fi
            if [ -n "$sid" ]; then
                VLESS_LINK="${VLESS_LINK}&sid=${sid}"
            fi
            VLESS_LINK="${VLESS_LINK}&serviceName=vless-grpc#${name}"
            echo -e "${CYAN}${VLESS_LINK}${NC}"
            ;;
        hysteria2)
            echo -e "${CYAN}hysteria2://${pass}@${SERVER_IP}:${port}?sni=${sni}&insecure=1#${name}${NC}"
            ;;
        tuic)
            echo -e "${CYAN}tuic://${uuid}:${pass}@${SERVER_IP}:${port}?sni=${sni}&congestion_control=bbr&alpn=h3&allow_insecure=1#${name}${NC}"
            ;;
        *)
            echo -e "${YELLOW}Giao thức $type chưa hỗ trợ xuất link tự động.${NC}"
            ;;
    esac
    echo -e "----------------------------------------------------------------------"
    ((COUNT++))
done