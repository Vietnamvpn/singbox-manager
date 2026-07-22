# Sing-box Manager (Vietnamvpn)

Hệ thống quản lý **Sing-box** tự động, nhẹ và tối ưu dành cho VPS Linux. Hỗ trợ tạo và quản lý đa giao thức (**VLESS Reality**, **Hysteria2**, **TUIC v5**) thông qua menu lệnh tắt gọn nhẹ.

---

## 🌟 Tính năng nổi bật

* **Cài đặt 1 bước:** Tự động nhận diện hệ điều hành và kiến trúc CPU (amd64, arm64).
* **Tự động hóa SSL:** Tự sinh chứng chỉ tự ký cho Hysteria2 & TUIC ngay khi cài đặt.
* **Lệnh tắt tiện lợi:** Truy cập menu quản lý cực nhanh bằng lệnh `vvc`.
* **Quản lý linh hoạt:** Thêm, xóa, xem danh sách và làm sạch người dùng/Node an toàn bằng `jq`.
* **Quản lý tiến trình:** Bật, tắt, khởi động lại service Sing-box dễ dàng.
* **Cập nhật & Gỡ bỏ:** Tự động lấy bản Sing-box Core mới nhất từ SagerNet hoặc gỡ cài đặt sạch sẻ 100%.

---

## 📋 Yêu cầu hệ thống

* **Hệ điều hành:** Ubuntu / Debian / CentOS / AlmaLinux / Rocky Linux
* **Quyền hạn:** Root (`sudo -i`)
* **Kiến trúc CPU:** x86_64 (amd64) hoặc aarch64 (arm64)

---

## 🚀 Lệnh cài đặt nhanh

Mở Terminal trên VPS và chạy duy nhất lệnh sau:

```bash
bash <(curl -Ls [https://raw.githubusercontent.com/Vietnamvpn/singbox-manager/main/install.sh](https://raw.githubusercontent.com/Vietnamvpn/singbox-manager/main/install.sh))
```

---

## 🛠️ Hướng dẫn sử dụng

Sau khi cài đặt thành công, bạn chỉ cần gõ lệnh sau ở bất kỳ đâu để mở bảng điều khiển:

```bash
vvc
```

### Bảng menu chính:

```text
====================================================
          QUẢN LÝ SING-BOX - VIETNAMVPN           
====================================================
 1. Quản lý Người dùng (Thêm/Xóa/Danh sách)
 2. Quản lý Node (Bật/Tắt/Khởi động lại)
 3. Quản lý Cấu hình (Config)
 4. Cập nhật Sing-box core
 5. Gỡ cài đặt hệ thống
 0. Thoát
====================================================
```

---

## 📖 Chi tiết chức năng

### 1. Thêm Node / Người dùng mới
* Vào **Menu 1** -> **Thêm người dùng / Node mới**.
* Chọn giao thức muốn khởi tạo:
  * **VLESS (Reality + gRPC):** Tự động tạo UUID và cặp khóa `Public Key` / `Private Key`.
  * **Hysteria2:** Tạo mật khẩu ngẫu nhiên, sử dụng chứng chỉ tự ký hệ thống.
  * **TUIC:** Tạo UUID & Password ngẫu nhiên, cấu hình BBR & ALPN h3.
* Nhập Port và SNI (Domain ngụy trang) theo yêu cầu.

### 2. Xem danh sách Node
* Vào **Menu 1** -> **Danh sách người dùng**.
* Hệ thống sẽ liệt kê dạng bảng gồm: `STT`, `Giao thức`, `Port`, `Username`, `UUID/Password`.

### 3. Xóa Node
* Vào **Menu 1** -> **Xóa người dùng**.
* Nhập số **Port** của Node cần xóa. Hệ thống sẽ tự động lọc và xóa đúng Node đó mà không ảnh hưởng đến các Node khác.

### 4. Quản lý tiến trình (Node)
* Trong **Menu 2**, bạn có thể:
  * **Start:** Khởi động Sing-box.
  * **Stop:** Dừng Sing-box.
  * **Restart:** Khởi động lại Sing-box (Tự động chạy sau khi thêm/xóa user).

---

## 📁 Cấu trúc thư mục hệ thống

```text
/usr/local/singbox-manager/
├── install.sh                  # Script cài đặt chính
├── menu.sh                     # Giao diện menu lệnh vvc
├── config.conf                 # File cấu hình biến môi trường
├── core/
│   ├── install.sh              # Tải Sing-box core từ Github
│   ├── update.sh               # Kiểm tra & cập nhật Core
│   ├── uninstall.sh            # Gỡ cài đặt sạch sẽ
│   └── service.sh              # Cấu hình systemd service
├── config/
│   ├── config.json             # File cấu hình hoạt động của Sing-box
│   └── templates/              # File mẫu JSON (VLESS, Hy2, TUIC)
├── users/
│   ├── add.sh                  # Thêm Node/User
│   ├── delete.sh               # Xóa Node/User theo Port
│   ├── list.sh                 # Hiển thị danh sách Node/User
│   └── reset.sh                # Xóa sạch toàn bộ Node
├── node/
│   ├── start.sh / stop.sh / restart.sh / status.sh
└── lib/                        # Các thư viện màu sắc, JSON, System
```

---

## 🗑️ Gỡ cài đặt

Nếu không còn nhu cầu sử dụng, bạn có thể gỡ bỏ hoàn toàn dự án bằng cách chọn **Mục 5** trong menu `vvc` hoặc chạy lệnh:

```bash
bash /usr/local/singbox-manager/core/uninstall.sh
```