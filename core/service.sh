#!/bin/bash
# File: core/service.sh

INSTALL_DIR="/usr/local/singbox-manager"
source "$INSTALL_DIR/lib/color.sh"

SERVICE_FILE="/etc/systemd/system/singbox.service"

echo -e "${YELLOW}Đang cấu hình tiến trình systemd cho Sing-box...${NC}"

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Sing-box Service (Vietnamvpn)
Documentation=https://sing-box.sagernet.org/
After=network.target nss-lookup.target

[Service]
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_SYS_PTRACE CAP_DAC_READ_SEARCH
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_SYS_PTRACE CAP_DAC_READ_SEARCH
ExecStart=/usr/local/bin/sing-box run -c $INSTALL_DIR/config/config.json
Restart=on-failure
RestartSec=10s
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable singbox >/dev/null 2>&1
echo -e "${GREEN}Đã tạo và kích hoạt service 'singbox' thành công!${NC}"