#!/bin/bash
# File: menu.sh

INSTALL_DIR="/usr/local/singbox-manager"
source "$INSTALL_DIR/lib/color.sh"

function show_menu() {
    clear
    echo -e "${CYAN}====================================================${NC}"
    echo -e "${GREEN}          QUẢN LÝ SING-BOX - VIETNAMVPN           ${NC}"
    echo -e "${CYAN}====================================================${NC}"
    echo -e "${YELLOW} 1.${NC} Quản lý Người dùng (Thêm/Xóa/Danh sách)"
    echo -e "${YELLOW} 2.${NC} Quản lý Node (Bật/Tắt/Khởi động lại)"
    echo -e "${YELLOW} 3.${NC} Quản lý Cấu hình (Config)"
    echo -e "${YELLOW} 4.${NC} Cập nhật Sing-box core"
    echo -e "${YELLOW} 5.${NC} Gỡ cài đặt hệ thống"
    echo -e "${YELLOW} 0.${NC} Thoát"
    echo -e "${CYAN}====================================================${NC}"
    read -p "Vui lòng chọn chức năng (0-5): " choice

    case $choice in
        1)
            # Tạm thời dẫn tới add.sh (sẽ code sau khi bạn đẩy code này lên)
            bash "$INSTALL_DIR/users/add.sh" 2>/dev/null || echo -e "${YELLOW}Chức năng đang được hoàn thiện...${NC}"
            read -p "Nhấn Enter để quay lại..." && show_menu
            ;;
        2)
            bash "$INSTALL_DIR/node/status.sh" 2>/dev/null || echo -e "${YELLOW}Chức năng đang được hoàn thiện...${NC}"
            read -p "Nhấn Enter để quay lại..." && show_menu
            ;;
        3)
            echo -e "${YELLOW}Tính năng cấu hình đang được thiết lập...${NC}"
            read -p "Nhấn Enter để quay lại..." && show_menu
            ;;
        4)
            bash "$INSTALL_DIR/core/update.sh" 2>/dev/null || echo -e "${YELLOW}Chưa có file update.sh${NC}"
            read -p "Nhấn Enter để quay lại..." && show_menu
            ;;
        5)
            bash "$INSTALL_DIR/core/uninstall.sh" 2>/dev/null || echo -e "${YELLOW}Chưa có file uninstall.sh${NC}"
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