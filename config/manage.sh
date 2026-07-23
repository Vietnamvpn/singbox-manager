#!/bin/bash
# File: config/manage.sh

INSTALL_DIR="/usr/local/singbox-manager"
source "$INSTALL_DIR/lib/color.sh"
CONFIG_FILE="$INSTALL_DIR/config/config.json"
KEYS_FILE="$INSTALL_DIR/config/public_keys.json"
BACKUP_DIR="$INSTALL_DIR/config/backups"

mkdir -p "$BACKUP_DIR"

function check_and_restart() {
    echo -e "${YELLOW}Đang kiểm tra cú pháp cấu hình Sing-box...${NC}"
    if /usr/local/bin/sing-box check -c "$CONFIG_FILE" >/dev/null 2>&1; then
        echo -e "${GREEN}Cấu hình hợp lệ! Đang khởi động lại Sing-box...${NC}"
        bash "$INSTALL_DIR/node/restart.sh"
    else
        echo -e "${RED}Lỗi: Cấu hình không hợp lệ! Chi tiết lỗi:${NC}"
        /usr/local/bin/sing-box check -c "$CONFIG_FILE"
    fi
}

function show_config_menu() {
    clear
    echo -e "${BLUE}====================================================${NC}"
    echo -e "${GREEN}               QUẢN LÝ CẤU HÌNH CONFIG              ${NC}"
    echo -e "${BLUE}====================================================${NC}"
    echo -e "${YELLOW} 1.${NC} Sửa file config.json trực tiếp (nano)"
    echo -e "${YELLOW} 2.${NC} Thay đổi Log Level (info, warn, error, debug)"
    echo -e "${YELLOW} 3.${NC} Tối ưu mạng NAT VPS (Prefer IPv6)"
    echo -e "${YELLOW} 4.${NC} Sao lưu Cấu hình (Backup)"
    echo -e "${YELLOW} 5.${NC} Khôi phục Cấu hình (Restore)"
    echo -e "${RED} 0.${NC} Quay lại Menu chính"
    echo -e "${BLUE}====================================================${NC}"
    read -p "Vui lòng chọn chức năng (0-5): " cchoice

    case $cchoice in
        1)
            if command -v nano >/dev/null 2>&1; then
                nano "$CONFIG_FILE"
            else
                vi "$CONFIG_FILE"
            fi
            check_and_restart
            read -p "Nhấn Enter để tiếp tục..." && show_config_menu
            ;;
        2)
            echo -e "${BLUE}====================================================${NC}"
            echo -e "Chọn Mức độ Log (Log Level):"
            echo -e " 1. info (Mặc định)"
            echo -e " 2. warn (Chỉ cảnh báo)"
            echo -e " 3. error (Chỉ báo lỗi)"
            echo -e " 4. debug (Chi tiết để soi lỗi)"
            read -p "Chọn (1-4): " log_choice
            case $log_choice in
                1) LOG_LV="info" ;;
                2) LOG_LV="warn" ;;
                3) LOG_LV="error" ;;
                4) LOG_LV="debug" ;;
                *) LOG_LV="info" ;;
            esac
            jq --arg lv "$LOG_LV" '.log.level = $lv' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
            echo -e "${GREEN}Đã chuyển Log Level sang: $LOG_LV${NC}"
            check_and_restart
            read -p "Nhấn Enter để tiếp tục..." && show_config_menu
            ;;
        3)
            echo -e "${YELLOW}Đang tối ưu cấu hình cho NAT VPS (Ưu tiên IPv6 / NAT64)...${NC}"
            # Sử dụng chuẩn DNS mới type: local của Sing-box 1.12+
            jq 'del(.outbounds[]?.domain_strategy) | .dns = {"servers": [{"type": "local", "tag": "default-dns", "strategy": "prefer_ipv6"}]}' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
            echo -e "${GREEN}Đã tối ưu cấu hình DNS ưu tiên IPv6 theo chuẩn Sing-box 1.12+.${NC}"
            check_and_restart
            read -p "Nhấn Enter để tiếp tục..." && show_config_menu
            ;;
        4)
            TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
            cp "$CONFIG_FILE" "$BACKUP_DIR/config_${TIMESTAMP}.json"
            [ -f "$KEYS_FILE" ] && cp "$KEYS_FILE" "$BACKUP_DIR/public_keys_${TIMESTAMP}.json"
            echo -e "${GREEN}Đã sao lưu thành công tại:${NC}"
            echo -e " - $BACKUP_DIR/config_${TIMESTAMP}.json"
            [ -f "$KEYS_FILE" ] && echo -e " - $BACKUP_DIR/public_keys_${TIMESTAMP}.json"
            read -p "Nhấn Enter để tiếp tục..." && show_config_menu
            ;;
        5)
            echo -e "${BLUE}====================================================${NC}"
            echo -e "${YELLOW}Danh sách các bản sao lưu:${NC}"
            FILES=("$BACKUP_DIR"/config_*.json)
            if [ ! -e "${FILES[0]}" ]; then
                echo -e "${RED}Chưa có bản sao lưu nào!${NC}"
            else
                i=1
                for file in "${FILES[@]}"; do
                    fname=$(basename "$file")
                    echo -e " ${i}. $fname"
                    ((i++))
                done
                read -p "Chọn bản sao lưu cần khôi phục (1-$((i-1))) hoặc 0 để hủy: " bchoice
                if [ "$bchoice" -ge 1 ] && [ "$bchoice" -lt "$i" ]; then
                    SELECTED_FILE="${FILES[$((bchoice-1))]}"
                    cp "$SELECTED_FILE" "$CONFIG_FILE"
                    
                    KEY_BACKUP=$(echo "$SELECTED_FILE" | sed 's/config_/public_keys_/')
                    if [ -f "$KEY_BACKUP" ]; then
                        cp "$KEY_BACKUP" "$KEYS_FILE"
                    fi

                    echo -e "${GREEN}Khôi phục thành công từ $(basename "$SELECTED_FILE")!${NC}"
                    check_and_restart
                fi
            fi
            read -p "Nhấn Enter để tiếp tục..." && show_config_menu
            ;;
        0)
            return 0
            ;;
        *)
            echo -e "${RED}Lựa chọn không hợp lệ!${NC}"
            sleep 1
            show_config_menu
            ;;
    esac
}

show_config_menu