# Quy tắc viết tài liệu đặc tả dev (As-is → To-be)

Áp dụng cho mọi tài liệu đặc tả chức năng của Obee dùng để dev đọc, nắm việc cần làm ở To-be và chia task. Bố cục bám theo mẫu `Đặc tả OI Thiết bị Setting máy` (Nhóm giao diện → Activity Flow), có thêm các phần dev cần: As-is, API, chia task. Bản tham chiếu đã áp dụng: "Đặc tả Dev – Lịch trình cá nhân (Personal Scheduler)".

## 1. Nguồn và nguyên tắc nội dung

- **As-is**: repo `technicalors/obee`. Đọc `AGENTS.md` của từng subtree (`server`, `web`, `mobile`) trước khi khảo sát.
- **To-be**: repo `technicalors/obee-app-mockup` (repo này). Web mockup ở `web/apps/workspace/src/views/<chức năng>`, mobile ở `mobile/`.
- **Ảnh mockup**: `screenshots/web/<Chức_năng>/` (dùng bản `-light`); mobile ở `screenshots/*.png`.
- **Hợp đồng API của Obee là chuẩn** (`docs/DATA_CONTRACT_INTEGRITY_RULE.md` trong repo obee). Mockup chỉ là thiết kế UI: ghi rõ chỗ mockup khác hợp đồng, không thêm alias hay trường trùng nghĩa để khớp mockup.
- **Ngôn ngữ**: Obee chỉ có tiếng Việt và tiếng Anh. Không thêm cột hay nhãn tiếng Hàn (mẫu OI có cột Tên KO vì là dự án khác).
- **Điểm chưa chốt**: ghi "(đề xuất)" hoặc "chờ PO chốt" ngay tại chỗ, và đưa vào chương Câu hỏi mở.

## 2. Định dạng

- Viết bằng tiếng Việt, một tài liệu một tab.
- Heading:
  - Title: `#`
  - Chương: `## N. TÊN CHƯƠNG VIẾT HOA`
  - Mục: `### N.x Tên mục`
  - Activity Flow: `### <ID>. Tên luồng`
  - Mục con của Activity Flow: `#### <ID>.0 …`

## 3. Thứ tự chương

1. **TỔNG QUAN MODULE**
   - 1.1 Mục tiêu chức năng: đoạn văn + bảng `Nhóm giao diện | Vai trò chính | Kết quả nghiệp vụ`
   - 1.2 Phạm vi nghiệp vụ: `STT | Nhóm chức năng | Tóm tắt xử lý | Giao diện thực hiện`
   - 1.3 Đối tượng sử dụng: `Đối tượng | Phạm vi sử dụng | Giao diện liên quan`
   - 1.4 Luồng nghiệp vụ tổng thể: `Bước | Actor / User Action | System Processing | Kết quả / Dữ liệu liên quan` + một dòng "Luồng dạng ngắn: A -> B -> …"
   - 1.5 Nguyên tắc dữ liệu chính: danh sách gạch đầu dòng
   - 1.6 Cấu trúc đặc tả chi tiết: `Nhóm tài liệu | Activity Flow | Nội dung` + nguồn repo
2. **HIỆN TRẠNG AS-IS**: dữ liệu, nghiệp vụ, API, web, mobile, lỗi và hạn chế đã biết.
3. **…N. NHÓM GIAO DIỆN** (mỗi nhóm một chương: web, modal/màn phụ, mobile, nhóm xử lý hệ thống)
   - N.1 Tổng quan giao diện: đoạn văn + bảng `Nội dung | Mô tả` gồm Tên giao diện, Mục tiêu giao diện, Phạm vi nghiệp vụ, Đối tượng sử dụng, Nguồn dữ liệu liên quan, Dữ liệu đầu vào, Dữ liệu đầu ra, Nguyên tắc dữ liệu quan trọng
   - N.2 Tóm tắt luồng tổng thể: `STT | Nhóm chức năng | Tóm tắt xử lý | Giao diện / Dữ liệu liên quan`
   - N.3 Danh sách Activity Flow: `STT | Activity Flow | Tên luồng | Nhóm nghiệp vụ tổng thể | Bản chất luồng | Ghi chú`
   - Sau đó là từng Activity Flow (mục 4)
4. **DỮ LIỆU VÀ API TỔNG HỢP**: khác biệt hợp đồng mockup/Obee, thay đổi DB, endpoint sửa và mới.
5. **CHIA TASK DEV**: bảng `ID | Task | Phụ thuộc | Ước lượng (ngày)` + sơ đồ thứ tự triển khai theo đợt (BE / Web / Mobile).
6. **CÂU HỎI MỞ VÀ RỦI RO**: checklist câu hỏi chờ PO + bảng `Rủi ro | Ảnh hưởng | Cách giảm`.

## 4. Cấu trúc một Activity Flow

Mã Activity Flow: `<MODULE>-<NHÓM>-AF-NNN`, ví dụ `SCHED-WEB-AF-004`.

| Phần | Nội dung |
| --- | --- |
| Bảng mô tả | `Nội dung \| Mô tả`: Description, Actors, Trigger, Pre-conditions, Post-conditions |
| `<ID>.0 Activity Flow` | Sơ đồ swimlane như mẫu OI (chi tiết bên dưới) + chú thích "Hình `<ID>`.0 – Sơ đồ Activity Flow: …" |
| `<ID>.1 Wireframe / Mockup giao diện` | Ảnh mockup thật, mỗi ảnh có dòng "Hình `<ID>`.1a - Mockup …: … (`đường/dẫn.png`)". Không có màn hình mới thì ghi rõ |
| `<ID>.2 Screen Attributes` | 9 cột: `STT \| Tên VN \| Tên EN \| Data Type \| Editable? \| Mandatory \| Value/Options \| Default Value \| Remark / Validation` |
| `<ID>.3 Business Rules` | `Rule ID \| Rule Description`, mã `BR-<MODULE>-<NHÓM>-AFNNN-NN` |
| `<ID>.4 API và dữ liệu` | Phần dev thêm: request/response, bảng DB mới |

Sơ đồ swimlane:

- Dải tiêu đề ghi mã `<ID>.0`, dòng dưới ghi tên luồng.
- Hai làn: **Actor** ở trên, **System** ở dưới. Với luồng hệ thống, làn trên là "Người nhận".
- Có chấm bắt đầu, ô bo góc cho từng bước, hình thoi quyết định có nhãn Có/Không, nhánh lỗi, và điểm kết thúc.
- Sau khi vẽ, kiểm tra hình hiển thị và sửa chữ đè hoặc tràn khỏi ô.

## 5. Độ rộng bảng

Mọi bảng cùng tổng rộng 760px. Bảng cùng loại dùng cùng độ rộng cột:

| Loại bảng | Độ rộng cột (px) |
| --- | --- |
| Nội dung \| Mô tả | 160 \| 600 |
| Rule ID \| Rule Description | 200 \| 560 |
| Screen Attributes (9 cột) | 36 \| 100 \| 100 \| 80 \| 64 \| 64 \| 100 \| 80 \| 136 |
| Danh sách Activity Flow (6 cột) | 40 \| 130 \| 180 \| 140 \| 110 \| 160 |
| Tóm tắt luồng / Phạm vi nghiệp vụ (4 cột) | 40 \| 140 \| 360 \| 220 |
| Luồng nghiệp vụ tổng thể (4 cột) | 50 \| 230 \| 260 \| 220 |
| Kiểu dữ liệu (Trường \| Kiểu \| Bắt buộc \| Ràng buộc) | 160 \| 220 \| 100 \| 280 |
| API (Method \| URI \| Response) | 90 \| 250 \| 420 |
| Phần \| Trường \| Kiểu | 100 \| 260 \| 400 |
| Mục \| Nội dung | 160 \| 600 |
| Bảng \| Cột chính \| Ghi chú | 200 \| 380 \| 180 |
| Bảng 3 cột khác (so sánh, rủi ro, đối tượng) | 140 \| 310 \| 310 |
| Chia task (ID \| Task \| Phụ thuộc \| Ước lượng) | 80 \| 440 \| 140 \| 100 |
| Bảng ảnh mobile 2 / 3 cột | 380 \| 380 / 254 \| 253 \| 253 |
