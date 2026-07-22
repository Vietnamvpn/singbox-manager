#!/bin/bash
# File: core/update_script.sh

INSTALL_DIR="/usr/local/singbox-manager"
REPO_URL="https://raw.githubusercontent.com/Vietnamvpn/singbox-manager/main"

if [ -f "$INSTALL_DIR/lib/color.sh" ]; then
    source "$INSTALL_DIR/lib/color.sh"
else
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    YELLOW='\033[0;33m'
    NC='\033[0m'
fi

echo -e "${YELLOW}Đang kiểm tra và tải mã nguồn mới nhất từ GitHub...${NC}"

# Danh sách các file script cần tải đè (GIỮ NGUYÊN config/config.json)
FILES=(
    "menu.sh"
    "config.conf"
    "core/install.sh"
    "core/update.sh"
    "core/update_script.sh"
    "core/uninstall.sh"
    "core/service.sh"
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

# Tải đè từng file script
for file in "${FILES[@]}"; do
    curl -sL "${REPO_URL}/${file}" -o "$INSTALL_DIR/${file}"
done

# Cấp lại quyền thực thi
chmod +x $INSTALL_DIR/*.sh
chmod +x $INSTALL_DIR/core/*.sh 2>/dev/null
chmod +x $INSTALL_DIR/users/*.sh 2>/dev/null
chmod +x $INSTALL_DIR/node/*.sh 2>/dev/null
chmod +x $INSTALL_DIR/lib/*.sh 2>/dev/null

# Lĩnh vực liên kết lệnh tắt vvc
ln -sf "$INSTALL_DIR/menu.sh" /usr/bin/vvc
chmod +x /usr/bin/vvc

echo -e "${GREEN}Cập nhật mã nguồn Script thành công! Dữ liệu Node/User của bạn được giữ nguyên hoàn toàn.${NC}"