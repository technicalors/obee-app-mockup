const { chromium } = require(require.resolve('playwright', { paths: ['./web'] }));
const path = require('path');
const fs = require('fs');

const BASE_DIR = path.resolve(__dirname, '../screenshots/web/Personal_Task_List');

const GROUPS = {
  overview: path.join(BASE_DIR, '01_tong_quan_va_danh_sach'),
  filters: path.join(BASE_DIR, '02_bo_loc_cong_viec'),
  creation: path.join(BASE_DIR, '03_bieu_mau_tao_va_them_nhanh'),
  details: path.join(BASE_DIR, '04_chi_tiet_cong_viec'),
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
    console.log(`\n================== CAPTURING PERSONAL TASKS [${theme.toUpperCase()}] ==================`);

    // Fresh navigation
    await page.goto('http://localhost:5666/personal-tasks');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1500);

    await ensureTheme(theme);
    await page.waitForTimeout(500);

    // --- Group 1: Tổng quan & Danh sách ---
    console.log(`[${theme}] 1. Board View (All Tasks Multi-column)`);
    await page.locator('[data-testid="all-lists-option"]').first().click();
    await page.waitForTimeout(600);
    await snap(GROUPS.overview, 'board-all-tasks', theme);

    console.log(`[${theme}] 2. Single List View (Việc của tôi)`);
    await page.locator('[data-testid="task-list-option"]').first().click();
    await page.waitForTimeout(600);
    await snap(GROUPS.overview, 'single-list-view', theme);

    // --- Group 2: Bộ lọc công việc ---
    console.log(`[${theme}] 3. Filter: Hôm nay`);
    await page.locator('[data-testid="today-filter-button"]').click();
    await page.waitForTimeout(600);
    await snap(GROUPS.filters, 'filter-today', theme);
    // Reset today filter
    await page.locator('[data-testid="today-filter-button"]').click();
    await page.waitForTimeout(300);

    console.log(`[${theme}] 4. Filter: Gắn sao`);
    await page.locator('[data-testid="starred-filter-button"]').click();
    await page.waitForTimeout(600);
    await snap(GROUPS.filters, 'filter-starred', theme);
    // Reset starred filter
    await page.locator('[data-testid="starred-filter-button"]').click();
    await page.waitForTimeout(300);

    console.log(`[${theme}] 5. Completed Tasks Section`);
    const completedToggle = page.locator('[data-testid="completed-accordion-toggle"]').first();
    if (await completedToggle.isVisible()) {
      await completedToggle.click();
      await page.waitForTimeout(600);
      await snap(GROUPS.filters, 'completed-tasks', theme);
    }

    // --- Group 3: Biểu mẫu tạo & thêm nhanh ---
    console.log(`[${theme}] 6. Inline Add Task`);
    const inlineInput = page.locator('[data-testid="task-inline-add-input"]').first();
    if (await inlineInput.isVisible()) {
      await inlineInput.click();
      await inlineInput.fill('Thiết kế slide báo cáo tổng kết quý 4');
      await page.waitForTimeout(400);
      await snap(GROUPS.creation, 'inline-add-task', theme);
    }

    // Fresh reload for modal captures
    await page.goto('http://localhost:5666/personal-tasks');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(800);

    console.log(`[${theme}] 7. Create Task Modal`);
    await page.locator('[data-testid="create-task-trigger"]').click();
    await page.waitForTimeout(800);
    await snap(GROUPS.creation, 'create-task-modal', theme);

    // Fresh reload for create list modal
    await page.goto('http://localhost:5666/personal-tasks');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(800);

    console.log(`[${theme}] 8. Create List Modal`);
    await page.locator('[data-testid="create-list-trigger"]').click();
    await page.waitForTimeout(800);
    await snap(GROUPS.creation, 'create-list-modal', theme);

    // Fresh reload for detail drawer
    await page.goto('http://localhost:5666/personal-tasks');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(800);

    // --- Group 4: Chi tiết công việc (Drawer) ---
    console.log(`[${theme}] 9. Task Detail Drawer`);
    const taskDetailTrigger = page.locator('[data-testid="task-detail-trigger"]').first();
    if (await taskDetailTrigger.isVisible()) {
      await taskDetailTrigger.click();
      await page.waitForTimeout(800);
      await snap(GROUPS.details, 'task-detail-drawer', theme);
    }

    console.log(`Completed theme: ${theme}`);
  }

  await page.goto('http://localhost:5666/personal-tasks');
  await page.waitForLoadState('networkidle');
  await ensureTheme('light');

  console.log('\nAll Personal Tasks screenshots taken successfully!');
  await browser.close();
}

main().catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
