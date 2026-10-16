const { chromium } = require(require.resolve('playwright', { paths: ['./web'] }));
const path = require('path');
const fs = require('fs');

const BASE_DIR = path.resolve(__dirname, '../screenshots/web/Personal_Scheduler');

const GROUPS = {
  viewModes: path.join(BASE_DIR, '01_che_do_xem'),
  filtersAndSplit: path.join(BASE_DIR, '02_bo_loc_va_chia_cot'),
  details: path.join(BASE_DIR, '03_chi_tiet_su_kien'),
  forms: path.join(BASE_DIR, '04_bieu_mau_tao_va_sua'),
  facility: path.join(BASE_DIR, '05_phong_hop_va_thiet_bi'),
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
      await page.waitForTimeout(500);
    }
  }

  async function snap(groupDir, name, theme) {
    const fileName = `${name}-${theme}.png`;
    const filePath = path.join(groupDir, fileName);
    await page.screenshot({ path: filePath });
    console.log(`Saved: ${filePath}`);
  }

  const themes = ['light', 'dark'];

  for (const theme of themes) {
    console.log(`\n================== CAPTURING THEME: ${theme.toUpperCase()} ==================`);

    await page.goto('http://localhost:5666/schedules');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1500);

    await ensureTheme(theme);
    await page.waitForTimeout(600);

    // --- 1. Chế độ xem ---
    console.log(`[${theme}] 1. Month View`);
    await page.click('[data-testid="schedule-view-mode-month"]');
    await page.waitForTimeout(500);
    await snap(GROUPS.viewModes, 'month', theme);

    console.log(`[${theme}] 2. Week View`);
    await page.click('[data-testid="schedule-view-mode-week"]');
    await page.waitForTimeout(600);
    await snap(GROUPS.viewModes, 'week', theme);

    console.log(`[${theme}] 3. Day View`);
    await page.click('[data-testid="schedule-view-mode-day"]');
    await page.waitForTimeout(600);
    await snap(GROUPS.viewModes, 'day', theme);

    console.log(`[${theme}] 4. Year View`);
    await page.click('[data-testid="schedule-view-mode-year"]');
    await page.waitForTimeout(600);
    await snap(GROUPS.viewModes, 'year', theme);

    await page.click('[data-testid="schedule-view-mode-month"]');
    await page.waitForTimeout(500);

    // --- 2. Bộ lọc & Chia cột so sánh ---
    console.log(`[${theme}] 5. User Tree Select`);
    const treeSelect = page.locator('[data-testid="calendar-user-tree-select"]');
    await treeSelect.click();
    await page.waitForTimeout(500);
    await snap(GROUPS.filtersAndSplit, 'filter-user-tree', theme);
    await page.keyboard.press('Escape');
    await page.waitForTimeout(400);

    console.log(`[${theme}] 6. Visibility Filter`);
    const visSelect = page.locator('.ant-select:has-text("Tất cả")');
    await visSelect.click();
    await page.waitForTimeout(500);
    await snap(GROUPS.filtersAndSplit, 'filter-visibility', theme);
    await page.keyboard.press('Escape');
    await page.waitForTimeout(400);

    console.log(`[${theme}] 7. Split Section (Multi-User)`);
    await treeSelect.click();
    await page.waitForTimeout(400);
    const checkboxes = page.locator('.ant-select-tree-checkbox');
    const cbCount = await checkboxes.count();
    if (cbCount >= 3) {
      await checkboxes.nth(1).click();
      await page.waitForTimeout(200);
      await checkboxes.nth(2).click();
      await page.waitForTimeout(200);
    }
    await page.keyboard.press('Escape');
    await page.waitForTimeout(800);
    await snap(GROUPS.filtersAndSplit, 'split-view', theme);

    const clearBtn = page.locator('[data-testid="calendar-user-tree-select"] .ant-select-clear');
    if (await clearBtn.isVisible()) {
      await clearBtn.click();
      await page.waitForTimeout(400);
    }
    await treeSelect.click();
    await page.waitForTimeout(300);
    const firstCb = page.locator('.ant-select-tree-checkbox').first();
    if (await firstCb.isVisible()) {
      await firstCb.click();
    }
    await page.keyboard.press('Escape');
    await page.waitForTimeout(600);

    // --- 3. Chi tiết lịch trình & Xác nhận xóa ---
    console.log(`[${theme}] 8. Detail Drawer`);
    const eventCard = page.locator('button[aria-label="Hội nghị Khách hàng & Đối tác Doanh nghiệp"], button[aria-label="Họp Kế hoạch & Chiến lược Sản phẩm Q4"]').first();
    await eventCard.click();
    await page.waitForTimeout(800);
    await snap(GROUPS.details, 'detail-drawer', theme);

    console.log(`[${theme}] 9. Delete Confirmation`);
    const deleteBtn = page.locator('.ant-drawer button:has-text("Xóa")').first();
    if (await deleteBtn.isVisible()) {
      await deleteBtn.click();
      await page.waitForTimeout(500);
      await snap(GROUPS.details, 'delete-confirm', theme);

      const cancelBtn = page.locator('.ant-modal button:has-text("Hủy")').first();
      await cancelBtn.click();
      await page.waitForTimeout(500);
    }

    // --- 4. Chỉnh sửa lịch trình ---
    console.log(`[${theme}] 10. Edit Drawer`);
    const editBtn = page.locator('.ant-drawer button:has-text("Chỉnh sửa")').first();
    if (await editBtn.isVisible()) {
      await editBtn.click();
      await page.waitForTimeout(800);
      await snap(GROUPS.forms, 'edit-drawer', theme);
    }

    await page.goto('http://localhost:5666/schedules');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1000);

    // --- 5. Tạo mới & Timeline phòng họp/thiết bị từ thanh công cụ ---
    console.log(`[${theme}] 11. Create Drawer`);
    const createBtn = page.locator('[data-testid="schedule-create-day"]').first();
    await createBtn.click();
    await page.waitForTimeout(800);
    await snap(GROUPS.forms, 'create-drawer', theme);

    // Close create drawer
    const createClose = page.locator('.ant-drawer-header .ant-drawer-close').last();
    if (await createClose.isVisible()) {
      await createClose.click();
      await page.waitForTimeout(500);
    }

    console.log(`[${theme}] 12. Facility & Equipment Timeline Modal (from Toolbar)`);
    const facilityToolbarBtn = page.locator('[data-testid="schedule-facility-schedule-btn"]');
    await facilityToolbarBtn.click();
    await page.waitForTimeout(800);
    await snap(GROUPS.facility, 'facility-timeline', theme);

    // Close modal
    const modalClose = page.locator('.ant-modal-close').first();
    if (await modalClose.isVisible()) {
      await modalClose.click();
      await page.waitForTimeout(500);
    }

    console.log(`Completed theme: ${theme}`);
  }

  await page.goto('http://localhost:5666/schedules');
  await page.waitForLoadState('networkidle');
  await ensureTheme('light');

  console.log('\nAll screenshots organized into functional groups successfully!');
  await browser.close();
}

main().catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
