#!/bin/bash
# File: menu.sh

INSTALL_DIR="/usr/local/singbox-manager"
source "$INSTALL_DIR/lib/color.sh"

function show_user_menu() {
    clear
    echo -e "${CYAN}====================================================${NC}"
    echo -e "${GREEN}             QUẢN LÝ NGƯỜI DÙNG / NODE             ${NC}"
    echo -e "${CYAN}====================================================${NC}"
    echo -e "${YELLOW} 1.${NC} Thêm Người dùng / Node mới"
    echo -e "${YELLOW} 2.${NC} Xem Danh sách Người dùng / Node"
    echo -e "${YELLOW} 3.${NC} Xóa Người dùng / Node"
    echo -e "${YELLOW} 4.${NC} Xóa toàn bộ Người dùng / Node (Reset)"
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
    echo -e "${YELLOW} 1.${NC} Cập nhật Mã nguồn Script (Tải từ GitHub)"
    echo -e "${YELLOW} 2.${NC} Cập nhật Sing-box Core (Bản mới nhất)"
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
    clear
    echo -e "${CYAN}====================================================${NC}"
    echo -e "${GREEN}          QUẢN LÝ SING-BOX - VIETNAMVPN           ${NC}"
    echo -e "${CYAN}====================================================${NC}"
    echo -e "${YELLOW} 1.${NC} Quản lý Người dùng (Thêm/Xóa/Danh sách)"
    echo -e "${YELLOW} 2.${NC} Quản lý Node (Bật/Tắt/Khởi động lại)"
    echo -e "${YELLOW} 3.${NC} Quản lý Cấu hình (Config)"
    echo -e "${YELLOW} 4.${NC} Cập nhật Hệ thống (Script & Core)"
    echo -e "${YELLOW} 5.${NC} Gỡ cài đặt hệ thống"
    echo -e "${YELLOW} 0.${NC} Thoát"
    echo -e "${CYAN}====================================================${NC}"
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
            echo -e "${YELLOW}Tính năng cấu hình đang được thiết lập...${NC}"
            read -p "Nhấn Enter để quay lại..." && show_menu
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