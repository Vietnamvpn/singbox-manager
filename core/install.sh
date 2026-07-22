#!/bin/bash
# File: core/install.sh

INSTALL_DIR="/usr/local/singbox-manager"
source "$INSTALL_DIR/lib/color.sh"

# Lấy phiên bản sing-box mới nhất từ Github Release
LATEST_VERSION=$(curl -s "https://api.github.com/repos/SagerNet/sing-box/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
if [[ -z "$LATEST_VERSION" ]]; then
    echo -e "${RED}Lỗi: Không thể lấy phiên bản Sing-box mới nhất từ Github.${NC}"
    exit 1
fi

# Kiểm tra kiến trúc CPU
ARCH=$(uname -m)
case "$ARCH" in
    x86_64) SB_ARCH="amd64" ;;
    aarch64) SB_ARCH="arm64" ;;
    armv7l) SB_ARCH="armv7" ;;
    *) echo -e "${RED}Lỗi: Kiến trúc $ARCH không được hỗ trợ.${NC}"; exit 1 ;;
esac

echo -e "${YELLOW}Phát hiện kiến trúc: ${SB_ARCH}. Đang tải Sing-box ${LATEST_VERSION}...${NC}"

# Link tải
DOWNLOAD_URL="https://github.com/SagerNet/sing-box/releases/download/${LATEST_VERSION}/sing-box-${LATEST_VERSION#v}-linux-${SB_ARCH}.tar.gz"

cd /tmp || exit
curl -sL "$DOWNLOAD_URL" -o "sing-box.tar.gz"

# Giải nén và cài đặt
tar -xzf sing-box.tar.gz
cd "sing-box-${LATEST_VERSION#v}-linux-${SB_ARCH}" || exit
mv sing-box /usr/local/bin/
chmod +x /usr/local/bin/sing-box

# Dọn dẹp
rm -rf /tmp/sing-box*

echo -e "${GREEN}Tải và cài đặt Sing-box core thành công!${NC}"