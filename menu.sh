#!/bin/bash
# File: menu.sh

INSTALL_DIR="/usr/local/singbox-manager"
source "$INSTALL_DIR/lib/color.sh"

function show_user_menu() {
    clear
    echo -e "${CYAN}====================================================${NC}"
    echo -e "${GREEN}             QUẢN LÝ NGƯỜI DÙNG & NODE             ${NC}"
    echo -e "${CYAN}====================================================${NC}"
    echo -e "${YELLOW} 1.${NC} Thêm User / Node mới"
    echo -e "${YELLOW} 2.${NC} Xem Danh sách User / Node"
    echo -e "${YELLOW} 3.${NC} Xóa User / Node"
    echo -e "${YELLOW} 4.${NC} Xóa toàn bộ User / Node"
    echo -e "${YELLOW} 0.${NC} Quay lại Menu chính"
    echo -e "${CYAN}====================================================${NC}"
    read -p "Vui lòng chọn chức năng (0-4): " uchoice

    case $uchoice in
        1)
            bash "$INSTALL_DIR/users/add.sh"
            read -p "Nhấn Enter để quay lại..." && show_user_menu
            ;;
        2)
            bash "$INSTALL_DIR/users/list.sh"
            read -p "Nhấn Enter để quay lại..." && show_user_menu
            ;;
        3)
            bash "$INSTALL_DIR/users/delete.sh"
            read -p "Nhấn Enter để quay lại..." && show_user_menu
            ;;
        4)
            bash "$INSTALL_DIR/users/reset.sh"
            read -p "Nhấn Enter để quay lại..." && show_user_menu
            ;;
        0)
            return 0
            ;;
        *)
            echo -e "${RED}Lựa chọn không hợp lệ!${NC}"
            sleep 1
            show_user_menu
            ;;
    esac
}

function show_update_menu() {
    clear
    echo -e "${CYAN}====================================================${NC}"
    echo -e "${GREEN}                 TÙY CHỌN CẬP NHẬT                  ${NC}"
    echo -e "${CYAN}====================================================${NC}"
    echo -e "${YELLOW} 1.${NC} Cập nhật Mã nguồn Script"
    echo -e "${YELLOW} 2.${NC} Cập nhật Sing-box Core"
    echo -e "${YELLOW} 0.${NC} Quay lại Menu chính"
    echo -e "${CYAN}====================================================${NC}"
    read -p "Vui lòng chọn chức năng (0-2): " upchoice

    case $upchoice in
        1)
            bash "$INSTALL_DIR/core/update_script.sh"
            read -p "Nhấn Enter để quay lại..." && show_update_menu
            ;;
        2)
            bash "$INSTALL_DIR/core/update.sh"
            read -p "Nhấn Enter để quay lại..." && show_update_menu
            ;;
        0)
            return 0
            ;;
        *)
            echo -e "${RED}Lựa chọn không hợp lệ!${NC}"
            sleep 1
            show_update_menu
            ;;
    esac
}

function show_menu() {
    # Lấy phiên bản Sing-box Core
    if [ -f "/usr/local/bin/sing-box" ]; then
        singbox_ver=$(/usr/local/bin/sing-box version 2>/dev/null | head -n 1 | awk '{print $3}')
        [ -z "$singbox_ver" ] && singbox_ver="Unknown"
    else
        singbox_ver="Chưa cài đặt"
    fi

    # Lấy trạng thái hoạt động của dịch vụ Sing-box
    if systemctl is-active --quiet singbox 2>/dev/null; then
        singbox_status="Online"
        status_color="${GREEN}"
    else
        singbox_status="Offline"
        status_color="${RED}"
    fi

    clear
    echo -e "${CYAN}======================================================${NC}"
    echo -e "${CYAN}||${NC}              ${YELLOW}CHÀO MỪNG BẠN ĐẾN VỚI${NC}               ${CYAN}||${NC}"
    echo -e "${CYAN}||${NC}       ${YELLOW}MENU QUẢN LÝ SING-BOX - VIETNAMVPN${NC}         ${CYAN}||${NC}"
    echo -e "${CYAN}======================================================${NC}"
    echo -e "${CYAN}Tác giả:${NC} Vietnamvpn | ${CYAN}Website:${NC} https://linksub24h.com"
    echo -e "Phiên bản Sing-box Core: ${YELLOW}${singbox_ver}${NC} | Trạng thái: ${status_color}${singbox_status^^}${NC}"
    echo -e "${CYAN}======================================================${NC}"
    echo -e "${YELLOW} 1.${NC} Quản lý Người dùng"
    echo -e "${YELLOW} 2.${NC} Quản lý Node"
    echo -e "${YELLOW} 3.${NC} Quản lý Cấu hình Config"
    echo -e "${YELLOW} 4.${NC} Cập nhật Hệ thống"
    echo -e "${YELLOW} 5.${NC} Gỡ cài đặt hệ thống"
    echo -e "${YELLOW} 0.${NC} Thoát"
    echo -e "${CYAN}======================================================${NC}"
    read -p "Vui lòng chọn chức năng (0-5): " choice

    case $choice in
        1)
            show_user_menu
            show_menu
            ;;
        2)
            bash "$INSTALL_DIR/node/status.sh"
            read -p "Nhấn Enter để quay lại..." && show_menu
            ;;
        3)
            bash "$INSTALL_DIR/config/manage.sh"
            show_menu
            ;;
        4)
            show_update_menu
            show_menu
            ;;
        5)
            bash "$INSTALL_DIR/core/uninstall.sh"
            ;;
        0)
            exit 0
            ;;
        *)
            echo -e "${RED}Lựa chọn không hợp lệ!${NC}"
            sleep 1
            show_menu
            ;;
    esac
}

show_menu