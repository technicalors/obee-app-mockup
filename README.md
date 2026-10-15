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

## Danh sách màn hình & tính năng demo

### 1. Quản lý thời gian (Time Set)
- **Lịch công việc (`/schedules`)**: Xem dạng Ngày, Tuần (time grid), Tháng, Năm (12 tháng); Kéo thả dời lịch & co giãn thời lượng; Họp trực tuyến (Google Meet/Zoom 1-click join); Đặt phòng họp & thiết bị với phát hiện trùng lịch; Dòng thời gian tài nguyên (Facility Schedule Timeline).
- **Chấm công (`/attendance`)**: Điểm danh vân tay điện tử, xác thực vị trí GPS & mạng IP văn phòng, thống kê tổng giờ làm và ngày thiếu công theo tháng, lịch sử chấm công chi tiết theo ngày.
- **Phân ca làm việc (`/employee-records/work-user-shifts`)**: Bảng chấm ca làm việc theo tuần/tháng, cấu hình mẫu ca (Hành chính, Ca sáng, Ca chiều, Ca đêm), phân ca hàng loạt cho nhân sự.
- **Nghỉ phép (`/employee-records/absence-requests`)**: Quản lý đơn xin nghỉ (Phép năm, Không lương, Công tác), tạo đơn mới, xem trước ngày công bị ảnh hưởng (Coverage table), kiểm tra số dư phép còn lại, duyệt và từ chối đơn.

### 2. Công việc cá nhân (`/personal-tasks`)
- Danh sách công việc theo danh mục (Việc của tôi, Sprint 42, Quản trị...).
- Bộ lọc thông minh: Hôm nay, Đã gắn sao, Việc đã hoàn thành.
- Tạo việc nhanh dạng inline hoặc modal chi tiết hỗ trợ thiết lập lặp lại (hàng ngày, hàng tuần, hàng tháng, quy tắc lặp lại).
- Quản lý công việc con (subtasks), đánh dấu sao ưu tiên, chuyển danh sách, chi tiết drawer.

### 3. Trò chuyện nội bộ (`/chat`)
- Kênh trò chuyện nhóm (Thông báo chung, Khối Công nghệ...).
- Nhắn tin trực tiếp 1-1 giữa các đồng nghiệp.
- Gửi tin nhắn tức thời, thả reaction emoji, trích dẫn trả lời, danh sách thành viên nhóm.

### 4. Hồ sơ nhân sự (`/employee-records`)
- **Lịch sử nhân sự (`/employee-records/history`)**: Danh sách nhân viên, thông tin mã nhân sự, phòng ban, vị trí, ngày gia nhập.
- **Chi tiết nhân sự (`/employee-records/history/:user`)**: Hồ sơ lý lịch, hợp đồng, chức vụ, bảo hiểm.
- **Đánh giá (`/employee-records/evaluation`)**: Đánh giá hiệu suất nhân viên định kỳ.
- **Kỹ năng (`/employee-records/skills`)**: Quản lý ma trận năng lực và kỹ năng chuyên môn.

### 5. Dữ liệu nền tảng (`/master-data`)
- **Cơ cấu tổ chức (`/master-data/organizations`)**: Quản lý các cấp tổ chức (Công ty, Khối, Phòng ban, Đội nhóm), sơ đồ cây phân cấp và biểu đồ tương tác D3 Organization Graph.
- **Người dùng (`/master-data/users`)**: Quản trị tài khoản, phân bổ tổ chức, vị trí công tác, vai trò và trạng thái tài khoản.
- **Vị trí công tác (`/master-data/positions`)**: Danh mục chức danh chuyên môn trong doanh nghiệp.
- **Vai trò & Phân quyền (`/master-data/roles`)**: Ma trận phân quyền chi tiết cho từng nhóm vai trò.
- **Tài nguyên cơ sở vật chất (`/master-data/facility-resources`)**: Quản lý phòng họp và trang thiết bị dùng chung (máy chiếu, mic, thiết bị hội nghị).
- **Điểm chấm công (`/master-data/attendance-locations`)**: Thiết lập vị trí chấm công với bản đồ Mapbox, vòng tròn bán kính GPS, dải IP cho phép.

### 6. Quản trị hệ thống (`/system`)
- **Nhật ký thao tác (`/system/http-mutation-logs`)**: Audit log ghi nhận mọi thay đổi dữ liệu của hệ thống, mã lỗi, người thực hiện, thời gian và xem chi tiết Markdown.

### 7. Trung tâm thông báo (`/notifications`)
- Danh sách thông báo hệ thống, chi tiết thông báo dạng drawer, đánh dấu đã đọc.

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
