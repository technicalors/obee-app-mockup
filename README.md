# Obee App Mockup

Mockup giao diện Obee gồm bản **web** (Vue + Vite) và bản **mobile** (Flutter, hiển thị trong khung điện thoại tại `/mobile/`).

## Chạy local

Yêu cầu Node.js `22.18+` hoặc `24.x` và pnpm `11+` (xem `.node-version`, `package.json`).

```bash
corepack enable
pnpm install   # tự cài workspace trong web/, không cần cd web
pnpm dev
```

| Giao diện | URL |
| --- | --- |
| Web | http://localhost:5666/ |
| Mobile | http://localhost:5666/mobile/ |

**Đăng nhập:** dữ liệu được mock ở tầng request, nhập mật khẩu bất kỳ để vào bằng tài khoản quản trị mặc định.

## Cấu trúc

| Thư mục | Nội dung |
| --- | --- |
| `web/` | Mockup web (pnpm workspace) |
| `mobile/` | Mã nguồn app Flutter — xem [mobile/README.md](mobile/README.md) |
| `web/apps/workspace/public/mobile/app/` | Bản build Flutter web dùng cho `/mobile/` |
| `screenshots/` | Ảnh chụp màn hình |

## Cập nhật bản mobile preview

Trang `/mobile/` dùng bản build có sẵn, không tự build lại. Sau khi sửa code trong `mobile/`, chạy:

```bash
cd mobile
rm -rf ../web/apps/workspace/public/mobile/app   # Flutter không tự xoá file cũ
fvm flutter build web --release --base-href /mobile/app/ \
  --dart-define=OBEE_ENV=dev \
  --dart-define=OBEE_API_BASE_URL=https://mock.obee.local/api \
  --dart-define=OBEE_APP_BASE_URL=https://mock.obee.local \
  --dart-define=OBEE_MOCK_API=true \
  --output ../web/apps/workspace/public/mobile/app
```

## Deploy

Vercel build theo [vercel.json](vercel.json): preset **Other**, Root Directory `./`, biến môi trường `ENABLE_EXPERIMENTAL_COREPACK=1`
