#!/bin/bash
# File: node/status.sh

INSTALL_DIR="/usr/local/singbox-manager"
source "$INSTALL_DIR/lib/color.sh"

function show_node_menu() {
    clear
    echo -e "${CYAN}====================================================${NC}"
    echo -e "${GREEN}             QUẢN LÝ NODE SING-BOX                  ${NC}"
    echo -e "${CYAN}====================================================${NC}"

    if systemctl is-active --quiet singbox; then
        echo -e "Trạng thái hiện tại: ${GREEN}Đang hoạt động (Running)${NC}"
    else
        echo -e "Trạng thái hiện tại: ${RED}Đã dừng (Stopped)${NC}"
    fi

    echo -e "${CYAN}====================================================${NC}"
    echo -e "${YELLOW} 1.${NC} Khởi động (Start)"
    echo -e "${YELLOW} 2.${NC} Dừng (Stop)"
    echo -e "${YELLOW} 3.${NC} Khởi động lại (Restart)"
    echo -e "${YELLOW} 0.${NC} Quay lại menu chính"
    echo -e "${CYAN}====================================================${NC}"
    read -p "Vui lòng chọn chức năng (0-3): " choice

    case $choice in
        1)
            bash "$INSTALL_DIR/node/start.sh"
            read -p "Nhấn Enter để tiếp tục..." && show_node_menu
            ;;
        2)
            bash "$INSTALL_DIR/node/stop.sh"
            read -p "Nhấn Enter để tiếp tục..." && show_node_menu
            ;;
        3)
            bash "$INSTALL_DIR/node/restart.sh"
            read -p "Nhấn Enter để tiếp tục..." && show_node_menu
            ;;
        0)
            return 0
            ;;
        *)
            echo -e "${RED}Lựa chọn không hợp lệ!${NC}"
            sleep 1
            show_node_menu
            ;;
    esac
}

show_node_menu