const { chromium } = require(require.resolve('playwright', { paths: ['./web'] }));
const path = require('path');
const fs = require('fs');

const BASE_DIR = path.resolve(__dirname, '../screenshots/web/Internal_Chat');

const GROUPS = {
  conversations: path.join(BASE_DIR, '01_danh_sach_hoi_thoai'),
  directChat: path.join(BASE_DIR, '02_tin_nhan_ca_nhan'),
  groupChat: path.join(BASE_DIR, '03_tin_nhan_nhom'),
  infoPanel: path.join(BASE_DIR, '04_thong_tin_va_tep_dinh_kem'),
  modals: path.join(BASE_DIR, '05_bieu_mau_modal'),
};

async function main() {
  for (const dir of Object.values(GROUPS)) {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
  }

  const browser = await chromium.launch({
    executablePath: 'C:/Program Files/Google/Chrome/Application/chrome.exe',
    headless: true,
  });

  const context = await browser.newContext({
    viewport: { width: 1600, height: 960 },
    deviceScaleFactor: 1.5,
  });

  const page = await context.newPage();

  console.log('Logging in...');
  await page.goto('http://localhost:5666/auth/login');
  await page.waitForLoadState('networkidle');
  await page.fill('input[name="email"]', 'admin');
  await page.fill('input[name="password"]', 'admin123');
  await page.click('button[aria-label="login"]');
  await page.waitForTimeout(2000);

  async function ensureTheme(desiredTheme) {
    const isDark = await page.evaluate(() =>
      document.documentElement.classList.contains('dark')
    );
    if ((desiredTheme === 'dark' && !isDark) || (desiredTheme === 'light' && isDark)) {
      const toggleBtn = page.locator('button[aria-label="dark"], button[aria-label="light"]').first();
      await toggleBtn.click();
      await page.waitForTimeout(600);
    }
  }

  async function snap(groupDir, name, theme) {
    const fileName = `${name}-${theme}.png`;
    const filePath = path.join(groupDir, fileName);
    // Full screen capture - modals shown in full page context
    await page.screenshot({ path: filePath });
    console.log(`Saved: ${filePath}`);
  }

  const themes = ['light', 'dark'];

  for (const theme of themes) {
    console.log(`\n================== CAPTURING INTERNAL CHAT [${theme.toUpperCase()}] ==================`);

    // -----------------------------------------------------------------------------------------
    // GROUP 1: Danh sách hội thoại & Điều hướng (/chat)
    // -----------------------------------------------------------------------------------------
    console.log(`[${theme}] Group 1.1: Danh sách tất cả hội thoại`);
    await page.goto('http://localhost:5666/chat');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1200);
    await ensureTheme(theme);
    await page.waitForTimeout(600);
    // Click conversation "Trần Quốc Bảo" to show active chat area
    await page.locator('aside div[role="button"]:has-text("Trần Quốc Bảo")').first().click();
    await page.waitForTimeout(800);
    await snap(GROUPS.conversations, '01-danh-sach-tat-ca-hoi-thoai', theme);

    console.log(`[${theme}] Group 1.2: Lọc tin nhắn riêng (Direct messages)`);
    const directTab = page.locator('.ant-segmented-item:has-text("Tin nhắn riêng")').first();
    await directTab.click();
    await page.waitForTimeout(600);
    await snap(GROUPS.conversations, '02-loc-tin-nhan-rieng', theme);

    console.log(`[${theme}] Group 1.3: Lọc nhóm (Group channels)`);
    const groupTab = page.locator('.ant-segmented-item:has-text("Nhóm")').first();
    await groupTab.click();
    await page.waitForTimeout(600);
    await snap(GROUPS.conversations, '03-loc-nhom', theme);

    console.log(`[${theme}] Group 1.4: Tìm kiếm hội thoại`);
    const allTab = page.locator('.ant-segmented-item:has-text("Tất cả")').first();
    await allTab.click();
    await page.waitForTimeout(400);
    const searchConvInput = page.locator('aside input[placeholder*="Tìm kiếm"]').first();
    await searchConvInput.fill('Quốc Bảo');
    await page.waitForTimeout(500);
    await snap(GROUPS.conversations, '04-tim-kiem-hoi-thoai', theme);

    // -----------------------------------------------------------------------------------------
    // GROUP 2: Tin nhắn cá nhân 1-1 (Direct Chat)
    // -----------------------------------------------------------------------------------------
    console.log(`[${theme}] Group 2.1: Màn hình trò chuyện cá nhân`);
    await page.goto('http://localhost:5666/chat');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1000);
    await page.locator('aside div[role="button"]:has-text("Trần Quốc Bảo")').first().click();
    await page.waitForTimeout(800);
    await snap(GROUPS.directChat, '01-tro-chuyen-ca-nhan', theme);

    console.log(`[${theme}] Group 2.2: Soạn tin nhắn văn bản`);
    const composerTextarea = page.locator('textarea[placeholder*="Nhập tin nhắn"]').first();
    await composerTextarea.click();
    await composerTextarea.fill('Chào Bảo, anh đã xem tài liệu đặc tả rồi, giao diện đang hoàn thiện rất tốt!');
    await page.waitForTimeout(500);
    await snap(GROUPS.directChat, '02-soan-tin-nhan-van-ban', theme);

    console.log(`[${theme}] Group 2.3: Thanh hành động nhanh khi hover tin nhắn`);
    await composerTextarea.fill('');
    const firstMsg = page.locator('[class*="group/message"]').first();
    await firstMsg.hover();
    await page.waitForTimeout(500);
    await snap(GROUPS.directChat, '03-hanh-dong-tin-nhan-hover', theme);

    console.log(`[${theme}] Group 2.4: Popover chọn nhanh cảm xúc emoji`);
    const reactBtn = firstMsg.locator('button[aria-label="Bày tỏ cảm xúc"]').first();
    if (await reactBtn.isVisible()) {
      await reactBtn.click();
      await page.waitForTimeout(500);
      await snap(GROUPS.directChat, '04-menu-cam-xuc-emoji', theme);
      // Close popover
      await page.keyboard.press('Escape');
      await page.waitForTimeout(300);
    }

    console.log(`[${theme}] Group 2.5: Trả lời trích dẫn tin nhắn (Quoted reply)`);
    await firstMsg.hover();
    await page.waitForTimeout(300);
    const replyBtn = firstMsg.locator('button[aria-label="Trả lời"]').first();
    if (await replyBtn.isVisible()) {
      await replyBtn.click();
      await page.waitForTimeout(500);
      await composerTextarea.fill('Cảm ơn em, để anh đối chiếu lại với bản vẽ kỹ thuật.');
      await page.waitForTimeout(400);
      await snap(GROUPS.directChat, '05-tra-loi-trich-dan-quote', theme);
    }

    // -----------------------------------------------------------------------------------------
    // GROUP 3: Tin nhắn nhóm & Tính năng tương tác (Group Chat)
    // -----------------------------------------------------------------------------------------
    console.log(`[${theme}] Group 3.1: Màn hình trò chuyện nhóm`);
    await page.goto('http://localhost:5666/chat');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1000);
    await page.locator('aside div[role="button"]:has-text("Khối Công nghệ")').first().click();
    await page.waitForTimeout(800);
    await snap(GROUPS.groupChat, '01-tro-chuyen-nhom', theme);

    console.log(`[${theme}] Group 3.2: Tìm kiếm nội dung trong cuộc trò chuyện`);
    const chatHeader = page.locator('[data-testid="chat-dropzone"] header');
    const searchInRoomBtn = chatHeader.locator('button[aria-label*="Tìm trong cuộc trò chuyện"]').first();
    if (await searchInRoomBtn.isVisible()) {
      await searchInRoomBtn.click();
      await page.waitForTimeout(500);
      const inRoomSearchInput = chatHeader.locator('input').first();
      await inRoomSearchInput.fill('kiểm thử');
      await page.waitForTimeout(600);
      await snap(GROUPS.groupChat, '02-tim-kiem-trong-tin-nhan', theme);
      // Close search
      const closeSearchBtn = chatHeader.locator('button:has([data-icon*="x"])').first();
      if (await closeSearchBtn.isVisible()) {
        await closeSearchBtn.click();
        await page.waitForTimeout(400);
      }
    }

    console.log(`[${theme}] Group 3.3: Kéo thả tệp tin vào cuộc trò chuyện (Drag & drop overlay)`);
    await page.evaluate(() => {
      const dropzone = document.querySelector('[data-testid="chat-dropzone"]');
      if (dropzone) {
        const dataTransfer = new DataTransfer();
        dataTransfer.items.add(new File(['dummy'], 'tai_lieu_ky_thuat.pdf', { type: 'application/pdf' }));
        const event = new DragEvent('dragenter', { dataTransfer, bubbles: true, cancelable: true });
        dropzone.dispatchEvent(event);
      }
    });
    await page.waitForTimeout(500);
    await snap(GROUPS.groupChat, '03-keo-tha-tep-dinh-kem', theme);
    // Cancel drag
    await page.evaluate(() => {
      const dropzone = document.querySelector('[data-testid="chat-dropzone"]');
      if (dropzone) {
        const event = new DragEvent('dragleave', { bubbles: true, cancelable: true });
        dropzone.dispatchEvent(event);
      }
    });
    await page.waitForTimeout(400);

    console.log(`[${theme}] Group 3.4: Thu gọn sidebar (Chế độ tập trung)`);
    const collapseSidebarBtn = chatHeader.locator('button[aria-label*="Thu gọn danh sách"]').first();
    if (await collapseSidebarBtn.isVisible()) {
      await collapseSidebarBtn.click();
      await page.waitForTimeout(600);
      await snap(GROUPS.groupChat, '04-thu-gon-sidebar-tap-trung', theme);
      // Re-expand sidebar
      const expandSidebarBtn = chatHeader.locator('button[aria-label*="Mở danh sách"]').first();
      if (await expandSidebarBtn.isVisible()) {
        await expandSidebarBtn.click();
        await page.waitForTimeout(500);
      }
    }

    // -----------------------------------------------------------------------------------------
    // GROUP 4: Panel thông tin hội thoại & Tệp chia sẻ (Info Panel)
    // -----------------------------------------------------------------------------------------
    console.log(`[${theme}] Group 4.1: Panel thông tin nhóm chi tiết`);
    await page.goto('http://localhost:5666/chat');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1000);
    await page.locator('aside div[role="button"]:has-text("Khối Công nghệ")').first().click();
    await page.waitForTimeout(800);
    await snap(GROUPS.infoPanel, '01-panel-thong-tin-nhom', theme);

    console.log(`[${theme}] Group 4.2: Panel thông tin cuộc trò chuyện cá nhân`);
    await page.locator('aside div[role="button"]:has-text("Trần Quốc Bảo")').first().click();
    await page.waitForTimeout(800);
    await snap(GROUPS.infoPanel, '02-panel-thong-tin-ca-nhan', theme);

    console.log(`[${theme}] Group 4.3: Đóng panel thông tin để tối đa không gian chat`);
    const toggleInfoBtn = page.locator('[data-testid="chat-dropzone"] header button[aria-label="Thông tin hội thoại"]').first();
    if (await toggleInfoBtn.isVisible()) {
      await toggleInfoBtn.click();
      await page.waitForTimeout(600);
      await snap(GROUPS.infoPanel, '03-dong-panel-thong-tin', theme);
      // Re-open info panel
      await toggleInfoBtn.click();
      await page.waitForTimeout(500);
    }

    // -----------------------------------------------------------------------------------------
    // GROUP 5: Các Modal chức năng (Full Screen - Không crop)
    // -----------------------------------------------------------------------------------------
    console.log(`[${theme}] Group 5.1: Modal tạo nhóm trò chuyện mới (Full screen)`);
    await page.goto('http://localhost:5666/chat');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1000);
    const leftAside = page.locator('aside').first();
    await leftAside.locator('button').first().click();
    await page.waitForTimeout(800);
    const createModal = page.locator('.ant-modal');
    if (await createModal.isVisible()) {
      await createModal.locator('input').first().fill('Dự án Triển khai Hệ thống Obee 2026');
      await createModal.locator('.ant-select').click();
      await page.waitForTimeout(400);
      const option = page.locator('.ant-select-item-option').first();
      if (await option.isVisible()) {
        await option.click();
      }
      await page.waitForTimeout(300);
      await createModal.locator('.ant-modal-title').click();
      await page.waitForTimeout(400);
      await snap(GROUPS.modals, '01-modal-tao-nhom-moi', theme);
      await page.keyboard.press('Escape');
      await page.waitForTimeout(500);
    }

    console.log(`[${theme}] Group 5.2: Modal quản lý danh sách thành viên nhóm (Full screen)`);
    await page.goto('http://localhost:5666/chat');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1000);
    await page.locator('aside div[role="button"]:has-text("Khối Công nghệ")').first().click();
    await page.waitForTimeout(800);
    const memberHeaderBtn = page.locator('[data-testid="chat-dropzone"] header span:has-text("thành viên")').first();
    if (await memberHeaderBtn.isVisible()) {
      await memberHeaderBtn.click();
      await page.waitForTimeout(800);
      await snap(GROUPS.modals, '02-modal-danh-sach-thanh-vien', theme);
      await page.keyboard.press('Escape');
      await page.waitForTimeout(500);
    }

    console.log(`Completed theme: ${theme}`);
  }

  await page.goto('http://localhost:5666/chat');
  await page.waitForLoadState('networkidle');
  await ensureTheme('light');

  console.log('\nAll Internal Chat screenshots captured successfully!');
  await browser.close();
}

main().catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
