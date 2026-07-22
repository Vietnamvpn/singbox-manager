#!/bin/bash
# File: users/list.sh

INSTALL_DIR="/usr/local/singbox-manager"
source "$INSTALL_DIR/lib/color.sh"
CONFIG_FILE="$INSTALL_DIR/config/config.json"

clear
echo -e "${CYAN}======================================================================${NC}"
echo -e "${GREEN}                     DANH SÁCH NGƯỜI DÙNG / NODE                      ${NC}"
echo -e "${CYAN}======================================================================${NC}"
printf "%-5s | %-10s | %-6s | %-12s | %-20s\n" "STT" "Giao Thức" "Port" "Username" "Thông Tin (UUID/Pass)"
echo -e "----------------------------------------------------------------------"

# Sử dụng jq để lọc data từ các config[cite: 1, 2, 3]
INDEX=1
jq -r '.inbounds[] | [.type, .listen_port, (.users[0].name // "N/A"), (.users[0].uuid // .users[0].password // "N/A")] | @tsv' "$CONFIG_FILE" | while IFS=$'\t' read -r type port name cred; do
    printf "%-5s | %-10s | %-6s | %-12s | %-20s\n" "$INDEX" "$type" "$port" "$name" "$cred"
    ((INDEX++))
done
echo -e "${CYAN}======================================================================${NC}"