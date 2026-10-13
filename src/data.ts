export type Employee = {
  id: number;
  code: string;
  name: string;
  email: string;
  phone: string;
  department: string;
  position: string;
  status: 'Đang làm việc' | 'Thử việc' | 'Nghỉ phép';
  joined: string;
  avatar: string;
};

export const employees: Employee[] = [
  { id: 1, code: 'OBE-001', name: 'Nguyễn Minh Anh', email: 'minhanh@obee.vn', phone: '090 312 4587', department: 'Sản phẩm', position: 'Product Manager', status: 'Đang làm việc', joined: '12/03/2022', avatar: '/avatars/avatar-1.svg' },
  { id: 2, code: 'OBE-002', name: 'Trần Quốc Bảo', email: 'quocbao@obee.vn', phone: '091 885 2201', department: 'Công nghệ', position: 'Frontend Developer', status: 'Đang làm việc', joined: '22/08/2022', avatar: '/avatars/avatar-2.svg' },
  { id: 3, code: 'OBE-003', name: 'Lê Hoàng Yến', email: 'hoangyen@obee.vn', phone: '098 164 3742', department: 'Nhân sự', position: 'HR Specialist', status: 'Đang làm việc', joined: '04/01/2023', avatar: '/avatars/avatar-3.svg' },
  { id: 4, code: 'OBE-004', name: 'Phạm Gia Huy', email: 'giahuy@obee.vn', phone: '093 660 1824', department: 'Công nghệ', position: 'Backend Developer', status: 'Thử việc', joined: '02/09/2026', avatar: '/avatars/avatar-4.svg' },
  { id: 5, code: 'OBE-005', name: 'Võ Thanh Trúc', email: 'thanhtruc@obee.vn', phone: '097 532 4490', department: 'Kinh doanh', position: 'Account Executive', status: 'Nghỉ phép', joined: '17/05/2023', avatar: '/avatars/avatar-5.svg' },
  { id: 6, code: 'OBE-006', name: 'Đỗ Nhật Nam', email: 'nhatnam@obee.vn', phone: '090 781 9203', department: 'Thiết kế', position: 'UI/UX Designer', status: 'Đang làm việc', joined: '15/11/2023', avatar: '/avatars/avatar-6.svg' },
  { id: 7, code: 'OBE-007', name: 'Bùi Khánh Linh', email: 'khanhlinh@obee.vn', phone: '092 406 8315', department: 'Tài chính', position: 'Kế toán tổng hợp', status: 'Đang làm việc', joined: '09/02/2024', avatar: '/avatars/avatar-7.svg' },
  { id: 8, code: 'OBE-008', name: 'Huỳnh Đức Long', email: 'duclong@obee.vn', phone: '096 218 0073', department: 'Công nghệ', position: 'QA Engineer', status: 'Thử việc', joined: '18/09/2026', avatar: '/avatars/avatar-8.svg' },
];

export const attendanceRows = [
  { date: '13/10/2026', weekday: 'Thứ Ba', checkIn: '08:27', checkOut: '--:--', hours: 'Đang làm việc', status: 'Đúng giờ' },
  { date: '12/10/2026', weekday: 'Thứ Hai', checkIn: '08:31', checkOut: '17:42', hours: '8h 11m', status: 'Đúng giờ' },
  { date: '09/10/2026', weekday: 'Thứ Sáu', checkIn: '08:48', checkOut: '17:38', hours: '7h 50m', status: 'Đi muộn' },
  { date: '08/10/2026', weekday: 'Thứ Năm', checkIn: '08:25', checkOut: '17:55', hours: '8h 30m', status: 'Đúng giờ' },
  { date: '07/10/2026', weekday: 'Thứ Tư', checkIn: '08:29', checkOut: '17:34', hours: '8h 05m', status: 'Đúng giờ' },
  { date: '06/10/2026', weekday: 'Thứ Ba', checkIn: '--:--', checkOut: '--:--', hours: 'Nghỉ phép', status: 'Nghỉ phép' },
];

export type Notice = {
  id: number;
  title: string;
  content: string;
  type: 'Thông báo' | 'Công việc' | 'Hệ thống';
  sender: string;
  time: string;
  unread: boolean;
};

export const notices: Notice[] = [
  { id: 1, title: 'Cập nhật chính sách làm việc linh hoạt', content: 'Từ ngày 20/10, nhân viên có thể đăng ký làm việc từ xa tối đa 2 ngày mỗi tuần. Vui lòng gửi đăng ký trước 17:00 thứ Sáu tuần liền trước.', type: 'Thông báo', sender: 'Phòng Nhân sự', time: '10 phút trước', unread: true },
  { id: 2, title: 'Bạn có lịch đánh giá quý III', content: 'Buổi đánh giá hiệu suất quý III của bạn được lên lịch vào 14:30 ngày 16/10/2026 tại phòng Lotus.', type: 'Công việc', sender: 'Nguyễn Minh Anh', time: '1 giờ trước', unread: true },
  { id: 3, title: 'Bảo trì hệ thống tối 15/10', content: 'Hệ thống Obee sẽ tạm ngưng trong khoảng 22:00–23:00 để nâng cấp hạ tầng. Dữ liệu của bạn được bảo toàn.', type: 'Hệ thống', sender: 'Obee System', time: 'Hôm qua', unread: false },
  { id: 4, title: 'Chào mừng thành viên mới', content: 'Chào mừng Gia Huy và Đức Long gia nhập đại gia đình Obee. Chúc các bạn có một hành trình thật nhiều cảm hứng.', type: 'Thông báo', sender: 'Phòng Nhân sự', time: '12/10/2026', unread: false },
  { id: 5, title: 'Đề nghị cập nhật hồ sơ cá nhân', content: 'Bạn vui lòng kiểm tra và bổ sung thông tin liên hệ khẩn cấp trong hồ sơ trước ngày 18/10.', type: 'Công việc', sender: 'Phòng Nhân sự', time: '11/10/2026', unread: false },
];

export const departments = [
  { name: 'Ban Giám đốc', manager: 'Nguyễn Quang Vinh', members: 3, color: '#6d5dfc' },
  { name: 'Công nghệ', manager: 'Trần Anh Tuấn', members: 18, color: '#2779ff' },
  { name: 'Sản phẩm', manager: 'Nguyễn Minh Anh', members: 9, color: '#f4a100' },
  { name: 'Thiết kế', manager: 'Đỗ Nhật Nam', members: 6, color: '#ec4899' },
  { name: 'Kinh doanh', manager: 'Lê Thành Công', members: 12, color: '#18a66a' },
  { name: 'Nhân sự', manager: 'Trần Thu Hà', members: 5, color: '#e85d3f' },
  { name: 'Tài chính', manager: 'Phạm Mỹ Duyên', members: 4, color: '#0ea5a8' },
];

export const equipment = [
  { code: 'OB-MBP-023', name: 'MacBook Pro 14 M3', type: 'Laptop', assignee: 'Trần Quốc Bảo', state: 'Đang sử dụng', issued: '20/01/2025' },
  { code: 'OB-MON-041', name: 'Dell UltraSharp U2723QE', type: 'Màn hình', assignee: 'Đỗ Nhật Nam', state: 'Đang sử dụng', issued: '12/03/2025' },
  { code: 'OB-IP15-008', name: 'iPhone 15 128GB', type: 'Điện thoại', assignee: 'Nguyễn Minh Anh', state: 'Đang sử dụng', issued: '09/12/2024' },
  { code: 'OB-DELL-017', name: 'Dell Latitude 7440', type: 'Laptop', assignee: 'Chưa cấp phát', state: 'Sẵn sàng', issued: '--' },
  { code: 'OB-KEY-032', name: 'Logitech MX Keys S', type: 'Phụ kiện', assignee: 'Lê Hoàng Yến', state: 'Bảo trì', issued: '14/06/2025' },
];

export const positions = [
  { name: 'Frontend Developer', code: 'FE', department: 'Công nghệ', level: 'Middle', members: 5 },
  { name: 'Backend Developer', code: 'BE', department: 'Công nghệ', level: 'Middle', members: 6 },
  { name: 'Product Manager', code: 'PM', department: 'Sản phẩm', level: 'Lead', members: 2 },
  { name: 'UI/UX Designer', code: 'UX', department: 'Thiết kế', level: 'Senior', members: 4 },
  { name: 'HR Specialist', code: 'HR', department: 'Nhân sự', level: 'Middle', members: 3 },
];

export const locations = [
  { name: 'Obee HQ — Quận 1', address: '72 Nguyễn Huệ, Phường Sài Gòn, TP.HCM', mode: 'GPS và IP', radius: '150 m', people: 47, active: true },
  { name: 'Chi nhánh Hà Nội', address: '28 Trần Hưng Đạo, Hoàn Kiếm, Hà Nội', mode: 'GPS hoặc IP', radius: '120 m', people: 16, active: true },
  { name: 'Co-working Đà Nẵng', address: '35 Thái Phiên, Hải Châu, Đà Nẵng', mode: 'Chỉ GPS', radius: '80 m', people: 7, active: true },
  { name: 'Văn phòng cũ', address: '18A Cộng Hòa, Tân Bình, TP.HCM', mode: 'GPS và IP', radius: '100 m', people: 0, active: false },
];

export const weekSchedule = [
  { date: 12, day: 'T2', events: [{ title: 'Daily Product', time: '09:00', color: 'blue' }] },
  { date: 13, day: 'T3', events: [{ title: 'Sprint Planning', time: '09:30', color: 'purple' }, { title: 'Review UI', time: '14:00', color: 'amber' }] },
  { date: 14, day: 'T4', events: [{ title: 'Workshop nội bộ', time: '10:00', color: 'green' }] },
  { date: 15, day: 'T5', events: [{ title: 'Sync Engineering', time: '09:00', color: 'blue' }, { title: '1:1 Manager', time: '16:00', color: 'red' }] },
  { date: 16, day: 'T6', events: [{ title: 'Đánh giá Q3', time: '14:30', color: 'purple' }] },
  { date: 17, day: 'T7', events: [] },
  { date: 18, day: 'CN', events: [] },
];

