#!/bin/bash
# File: install.sh
# Lệnh cài đặt: bash <(curl -Ls https://raw.githubusercontent.com/Vietnamvpn/singbox-manager/main/install.sh)

REPO_URL="https://raw.githubusercontent.com/Vietnamvpn/singbox-manager/main"
INSTALL_DIR="/usr/local/singbox-manager"

# 1. Kiểm tra quyền root
if [[ $EUID -ne 0 ]]; then
    echo -e "\033[0;31mLỗi: Vui lòng chạy script bằng quyền root (sudo -i).\033[0m"
    exit 1
fi

# 2. Kiểm tra và cài đặt gói phụ thuộc theo Hệ điều hành (Đã bổ sung openssl)
echo "Đang kiểm tra hệ điều hành và cài đặt các gói cơ bản..."
if [ -x "$(command -v apt)" ]; then
    apt update -y && apt install -y curl wget unzip jq tar tzdata openssl
elif [ -x "$(command -v yum)" ]; then
    yum update -y && yum install -y curl wget unzip jq tar tzdata openssl
else
    echo -e "\033[0;31mLỗi: Hệ điều hành không được hỗ trợ (chỉ hỗ trợ Debian/Ubuntu hoặc CentOS/AlmaLinux).\033[0m"
    exit 1
fi

# 3. Tạo cấu trúc thư mục
echo "Đang khởi tạo cấu trúc thư mục..."
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR" || exit
mkdir -p core config/templates users node lib

# 3.1. Khởi tạo chứng chỉ tự ký cho Hysteria2 và TUIC
CERT_DIR="/usr/local/etc/sing-box"
if [ ! -f "$CERT_DIR/cert.pem" ] || [ ! -f "$CERT_DIR/private.key" ]; then
    echo "Đang khởi tạo chứng chỉ tự ký cho Hysteria2 và TUIC..."
    mkdir -p "$CERT_DIR"
    openssl req -x509 -nodes -newkey rsa:2048 \
        -keyout "$CERT_DIR/private.key" \
        -out "$CERT_DIR/cert.pem" \
        -days 3650 \
        -subj "/CN=bing.com" >/dev/null 2>&1
fi

# 4. Danh sách toàn bộ file cần tải từ Github
FILES=(
    "menu.sh"
    "config.conf"
    "core/install.sh"
    "core/update.sh"
    "core/uninstall.sh"
    "core/service.sh"
    "config/config.json"
    "config/templates/hysteria2.json"
    "config/templates/tuic.json"
    "config/templates/vless.json"
    "users/add.sh"
    "users/delete.sh"
    "users/list.sh"
    "users/reset.sh"
    "node/start.sh"
    "node/stop.sh"
    "node/restart.sh"
    "node/status.sh"
    "lib/color.sh"
    "lib/system.sh"
    "lib/github.sh"
    "lib/json.sh"
)

# 5. Tải file
echo "Đang tải mã nguồn từ Github (Vietnamvpn)..."
for file in "${FILES[@]}"; do
    curl -sL "${REPO_URL}/${file}" -o "$INSTALL_DIR/${file}"
done

# 6. Phân quyền thực thi
chmod +x $INSTALL_DIR/*.sh
chmod +x $INSTALL_DIR/core/*.sh 2>/dev/null
chmod +x $INSTALL_DIR/users/*.sh 2>/dev/null
chmod +x $INSTALL_DIR/node/*.sh 2>/dev/null
chmod +x $INSTALL_DIR/lib/*.sh 2>/dev/null

# 7. Tạo lệnh tắt vvc
ln -sf "$INSTALL_DIR/menu.sh" /usr/bin/vvc
chmod +x /usr/bin/vvc

# 8. Gọi core/install.sh để tải Sing-box
echo "Đang cài đặt Sing-box core..."
if [ -f "$INSTALL_DIR/core/install.sh" ]; then
    bash "$INSTALL_DIR/core/install.sh"
else
    echo -e "\033[0;31mLỗi: Không tìm thấy core/install.sh. Vui lòng kiểm tra lại Github Repository.\033[0m"
    exit 1
fi

echo -e "\033[0;32m====================================================\033[0m"
echo -e "\033[0;32m Cài đặt hoàn tất! Hãy gõ lệnh 'vvc' để vào menu.\033[0m"
echo -e "\033[0;32m====================================================\033[0m"