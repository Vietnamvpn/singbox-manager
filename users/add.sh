#!/bin/bash
# File: users/add.sh

INSTALL_DIR="/usr/local/singbox-manager"
source "$INSTALL_DIR/lib/color.sh"
CONFIG_FILE="$INSTALL_DIR/config/config.json"
KEYS_FILE="$INSTALL_DIR/config/public_keys.json"
DOMAINS_FILE="$INSTALL_DIR/config/domains.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${YELLOW}Khởi tạo config.json cơ bản...${NC}"
    echo '{"log": {"level": "info"}, "inbounds": [], "outbounds": [{"type": "direct", "tag": "direct"}], "route": {"rules": [], "final": "direct"}}' > "$CONFIG_FILE"
fi

if [ ! -f "$KEYS_FILE" ]; then
    echo '{}' > "$KEYS_FILE"
fi

if [ ! -f "$DOMAINS_FILE" ]; then
    echo '{}' > "$DOMAINS_FILE"
fi

clear
echo -e "${BLUE}====================================================${NC}"
echo -e "${GREEN}             THÊM NGƯỜI DÙNG & NODE MỚI             ${NC}"
echo -e "${BLUE}====================================================${NC}"
echo -e "${YELLOW} 1.${NC} VLESS (Reality + gRPC)"
echo -e "${YELLOW} 2.${NC} Hysteria2"
echo -e "${YELLOW} 3.${NC} TUIC"
echo -e "${RED} 0.${NC} Hủy bỏ"
echo -e "${BLUE}====================================================${NC}"
read -p "Chọn giao thức (0-3): " proto_choice

case $proto_choice in
    1) PROTO="vless" ;;
    2) PROTO="hysteria2" ;;
    3) PROTO="tuic" ;;
    0) exit 0 ;;
    *) echo -e "${RED}Lỗi: Lựa chọn không hợp lệ!${NC}"; exit 1 ;;
esac

TEMPLATE_FILE="$INSTALL_DIR/config/templates/${PROTO}.json"
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo -e "${RED}Lỗi: Không tìm thấy file mẫu $TEMPLATE_FILE tại VPS.${NC}"
    read -p "Nhấn Enter để thoát..."
    exit 1
fi

read -p "Nhập Port ($PROTO) (để trống để tạo ngẫu nhiên 2000-6000): " PORT

if [ -z "$PORT" ]; then
    while true; do
        PORT=$((RANDOM % 4001 + 2000))
        if ! jq -e --arg port "$PORT" '.inbounds[] | select(.listen_port == ($port|tonumber) or .listen_port == $port)' "$CONFIG_FILE" > /dev/null 2>&1; then
            break
        fi
    done
    echo -e "${YELLOW}-> Tự động chọn Port ngẫu nhiên: ${GREEN}$PORT${NC}"
else
    if jq -e --arg port "$PORT" '.inbounds[] | select(.listen_port == ($port|tonumber) or .listen_port == $port)' "$CONFIG_FILE" > /dev/null; then
        echo -e "${RED}Lỗi: Port $PORT đã tồn tại trong cấu hình! Vui lòng chọn Port khác.${NC}"
        exit 1
    fi
fi

USERNAME="admin"
read -p "Nhập Domain hiển thị hoặc để trống: " NODE_DOMAIN
read -p "Nhập SNI nếu có: " SNI

echo -e "\n${YELLOW}Cấu hình Routing / Chain Node, nhập link (vless://, vmess://, trojan://) để trống sẽ kết nối trực tiếp qua VPS. ${NC}"
read -p "Nhập link Outbound : " OUTBOUND_LINK

if [ -n "$NODE_DOMAIN" ]; then
    if ! jq --arg port "$PORT" --arg domain "$NODE_DOMAIN" '.[$port] = $domain' "$DOMAINS_FILE" > "${DOMAINS_FILE}.tmp"; then
         echo -e "${RED}Lỗi: Không thể cập nhật $DOMAINS_FILE.${NC}"; exit 1
    fi
    mv "${DOMAINS_FILE}.tmp" "$DOMAINS_FILE"
fi

if [ -z "$SNI" ]; then
    SNI_LIST=("apple.com" "microsoft.com" "dl.google.com" "www.cloudflare.com" "gateway.icloud.com" "aws.amazon.com" "www.lovelive-anime.jp")
    SNI=${SNI_LIST[$RANDOM % ${#SNI_LIST[@]}]}
    echo -e "${YELLOW}-> Tự động chọn SNI ngẫu nhiên: ${GREEN}$SNI${NC}"
fi

UUID=$(cat /proc/sys/kernel/random/uuid)
PASSWORD=$(cat /proc/sys/kernel/random/uuid)
PRIVATE_KEY=""
PUBLIC_KEY=""
SHORT_ID=""

if [ "$PROTO" == "vless" ]; then
    echo -e "${YELLOW}Đang tạo Reality Keypair và Short ID ngẫu nhiên cho VLESS...${NC}"
    KEYPAIR=$(/usr/local/bin/sing-box generate reality-keypair)
    PRIVATE_KEY=$(echo "$KEYPAIR" | grep "PrivateKey" | awk '{print $2}')
    PUBLIC_KEY=$(echo "$KEYPAIR" | grep "PublicKey" | awk '{print $2}')
    SHORT_ID=$(openssl rand -hex 4 2>/dev/null || tr -dc 'a-f0-9' </dev/urandom | head -c 8)

    if ! jq --arg port "$PORT" --arg pbk "$PUBLIC_KEY" '.[$port] = $pbk' "$KEYS_FILE" > "${KEYS_FILE}.tmp"; then
         echo -e "${RED}Lỗi: Không thể ghi vào $KEYS_FILE.${NC}"; exit 1
    fi
    mv "${KEYS_FILE}.tmp" "$KEYS_FILE"
fi

NEW_INBOUND=$(cat "$TEMPLATE_FILE" | \
    sed "s/\"listen_port\": \"PORT\"/\"listen_port\": $PORT/g" | \
    sed "s/PORT/$PORT/g" | \
    sed "s/USERNAME/$USERNAME/g" | \
    sed "s/PASSWORD/$PASSWORD/g" | \
    sed "s/SNI/$SNI/g" | \
    sed "s/UUID/$UUID/g" | \
    sed "s/PRIVATE_KEY/$PRIVATE_KEY/g" | \
    sed "s/0123456789abcdef/$SHORT_ID/g" | \
    sed "s/SHORT_ID/$SHORT_ID/g")

OUTBOUND_TAG="outbound_$PORT"
INBOUND_TAG=$(echo "$NEW_INBOUND" | jq -r '.tag')

NEW_OUTBOUND="null"
NEW_ROUTE_RULE="null"

if [ -n "$OUTBOUND_LINK" ]; then
    echo -e "${YELLOW}Đang phân tích link Outbound và tạo cấu hình Node xuất...${NC}"
    cat << 'EOF' > /tmp/parse_link.py
import sys, json, urllib.parse, base64

link = sys.argv[1].strip()
tag = sys.argv[2]

out = {"tag": tag}

try:
    if link.startswith("vless://") or link.startswith("trojan://"):
        parsed = urllib.parse.urlparse(link)
        qs = urllib.parse.parse_qs(parsed.query)
        out["type"] = parsed.scheme
        out["server"] = parsed.hostname
        out["server_port"] = int(parsed.port)
        if parsed.scheme == "vless":
            out["uuid"] = parsed.username
        else:
            out["password"] = parsed.username
        
        sec = qs.get("security", [""])[0]
        fp = qs.get("fp", ["chrome"])[0] # Lấy fingerprint từ link, mặc định chrome nếu không có
        
        if sec == "tls":
            out["tls"] = {
                "enabled": True, 
                "server_name": qs.get("sni", [parsed.hostname])[0], 
                "insecure": False,
                "utls": {"enabled": True, "fingerprint": fp}
            }
        elif sec == "reality":
            out["tls"] = {
                "enabled": True, 
                "server_name": qs.get("sni", [parsed.hostname])[0],
                "utls": {"enabled": True, "fingerprint": fp},
                "reality": {
                    "enabled": True,
                    "public_key": qs.get("pbk", [""])[0],
                    "short_id": qs.get("sid", [""])[0]
                }
            }
        
        net = qs.get("type", ["tcp"])[0]
        if net == "ws":
            out["transport"] = {"type": "ws", "path": qs.get("path", ["/"])[0], "headers": {"Host": qs.get("host", [parsed.hostname])[0]}}
        elif net == "grpc":
            out["transport"] = {"type": "grpc", "service_name": qs.get("serviceName", [""])[0]}

    elif link.startswith("vmess://"):
        b64 = link[8:]
        b64 += "=" * ((4 - len(b64) % 4) % 4)
        v = json.loads(base64.urlsafe_b64decode(b64).decode("utf-8"))
        out["type"] = "vmess"
        out["server"] = v.get("add")
        out["server_port"] = int(v.get("port"))
        out["uuid"] = v.get("id")
        out["security"] = "auto"
        out["alter_id"] = int(v.get("aid", 0))
        
        if str(v.get("tls")) == "tls":
            out["tls"] = {
                "enabled": True, 
                "server_name": str(v.get("sni", [v.get("add")])[0]), 
                "insecure": False,
                "utls": {"enabled": True, "fingerprint": "chrome"}
            }
            
        net = str(v.get("net", "tcp"))
        if net == "ws":
            out["transport"] = {"type": "ws", "path": v.get("path", "/"), "headers": {"Host": v.get("host", v.get("add"))}}
        elif net == "grpc":
            out["transport"] = {"type": "grpc", "service_name": v.get("path", "")}
    else:
        out = None
except Exception as e:
    out = None

if out:
    print(json.dumps(out))
else:
    print("null")
EOF
    NEW_OUTBOUND=$(python3 /tmp/parse_link.py "$OUTBOUND_LINK" "$OUTBOUND_TAG")
    rm -f /tmp/parse_link.py

    if [ "$NEW_OUTBOUND" != "null" ] && [ -n "$NEW_OUTBOUND" ]; then
        NEW_ROUTE_RULE="{\"inbound\": [\"$INBOUND_TAG\"], \"outbound\": \"$OUTBOUND_TAG\"}"
    fi
fi

if ! jq --argjson new_inbound "$NEW_INBOUND" \
   --argjson new_outbound "$NEW_OUTBOUND" \
   --argjson new_rule "$NEW_ROUTE_RULE" \
   '.inbounds += [$new_inbound] | 
    if $new_outbound != null then .outbounds += [$new_outbound] else . end | 
    if .route == null then .route = {"rules":[]} else . end | 
    if .route.rules == null then .route.rules = [] else . end | 
    if $new_rule != null then .route.rules = [$new_rule] + .route.rules else . end' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp"; then
    echo -e "${RED}Lỗi: Cập nhật config.json thất bại. Kiểm tra lại cú pháp JSON của tệp mẫu.${NC}"
    exit 1
fi
mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"

echo -e "${YELLOW}Kiểm tra tính hợp lệ của cấu hình Sing-box...${NC}"
if ! /usr/local/bin/sing-box check -c "$CONFIG_FILE"; then
    echo -e "${RED}Lỗi cú pháp JSON: Sing-box từ chối cấu hình! Đã dừng tiến trình.${NC}"
    exit 1
fi

echo -e "${GREEN}Cấu hình hợp lệ. Đang khởi động lại...${NC}"
bash "$INSTALL_DIR/node/restart.sh"

sleep 2
if systemctl is-active --quiet singbox; then
    echo -e "${GREEN}Thành công: Đã thêm node và Sing-box đang hoạt động bình thường!${NC}"
else
    echo -e "${RED}Lỗi nghiêm trọng: Sing-box không thể chạy. Dùng lệnh 'journalctl -u singbox -e' để kiểm tra.${NC}"
fi

echo -e "${BLUE}====================================================${NC}"
echo -e "Giao thức : $PROTO"
echo -e "Port      : $PORT"
echo -e "Username  : $USERNAME"
[ -n "$NODE_DOMAIN" ] && echo -e "Domain    : $NODE_DOMAIN"
echo -e "SNI       : $SNI"
if [ -n "$OUTBOUND_LINK" ] && [ "$NEW_OUTBOUND" != "null" ]; then
    echo -e "Outbound  : Đã kích hoạt Proxy (Chain)"
else
    echo -e "Outbound  : Trực tiếp (Direct)"
fi
[[ "$PROTO" == "vless" || "$PROTO" == "tuic" ]] && echo -e "UUID      : $UUID"
[[ "$PROTO" == "hysteria2" || "$PROTO" == "tuic" ]] && echo -e "Password  : $PASSWORD"
if [ "$PROTO" == "vless" ]; then
    echo -e "Public Key: $PUBLIC_KEY"
    echo -e "Short ID  : $SHORT_ID"
fi
echo -e "${BLUE}====================================================${NC}"