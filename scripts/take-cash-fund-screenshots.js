const { chromium } = require(require.resolve('playwright', { paths: ['./web'] }));
const path = require('path');
const fs = require('fs');

const BASE_DIR = path.resolve(__dirname, '../screenshots/web/Cash_Fund');

const GROUPS = {
  proposals: path.join(BASE_DIR, '01_de_xuat_thu_chi'),
  approvals: path.join(BASE_DIR, '02_phe_duyet_de_xuat'),
  transactions: path.join(BASE_DIR, '03_so_quy_va_but_toan'),
  adjustments: path.join(BASE_DIR, '04_dieu_chuyen_quy'),
  reports: path.join(BASE_DIR, '05_bao_cao_va_so_quy'),
  masterData: path.join(BASE_DIR, '06_thiet_lap_nguon_quy_va_danh_muc'),
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
    // Captured full-screen viewport (1600x960 @ 1.5x) - modals shown in full page context
    await page.screenshot({ path: filePath });
    console.log(`Saved: ${filePath}`);
  }

  const themes = ['light', 'dark'];

  for (const theme of themes) {
    console.log(`\n================== CAPTURING CASH FUND [${theme.toUpperCase()}] ==================`);

    // -----------------------------------------------------------------------------------------
    // GROUP 1: Đề xuất thu / chi / tạm ứng / hoàn ứng (/cash-fund/proposals)
    // -----------------------------------------------------------------------------------------
    console.log(`[${theme}] Group 1.1: Danh sách đề xuất thu chi`);
    await page.goto('http://localhost:5666/cash-fund/proposals');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1000);
    await ensureTheme(theme);
    await page.waitForTimeout(600);
    await snap(GROUPS.proposals, '01-danh-sach-de-xuat', theme);

    console.log(`[${theme}] Group 1.2: Modal tạo đề xuất mới (Full screen)`);
    await page.goto('http://localhost:5666/cash-fund/proposals');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(800);
    const createPropBtn = page.locator('button:has-text("Tạo đề xuất mới")').first();
    await createPropBtn.click();
    await page.waitForTimeout(800);
    await snap(GROUPS.proposals, '02-modal-tao-de-xuat-moi', theme);

    console.log(`[${theme}] Group 1.3: Modal chi tiết đề xuất (Full screen)`);
    await page.goto('http://localhost:5666/cash-fund/proposals');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(800);
    const firstCodeLink = page.locator('.ant-table-cell span.font-mono.cursor-pointer').first();
    await firstCodeLink.click();
    await page.waitForTimeout(800);
    await snap(GROUPS.proposals, '03-modal-chi-tiet-de-xuat', theme);

    console.log(`[${theme}] Group 1.4: Modal chỉnh sửa đề xuất trả về (Full screen)`);
    await page.goto('http://localhost:5666/cash-fund/proposals');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(800);
    const returnEditBtn = page.locator('button.text-amber-600').first();
    if (await returnEditBtn.isVisible()) {
      await returnEditBtn.click();
      await page.waitForTimeout(800);
      await snap(GROUPS.proposals, '04-modal-sua-de-xuat-tra-ve', theme);
    }

    // -----------------------------------------------------------------------------------------
    // GROUP 2: Phê duyệt đề xuất (/cash-fund/approvals)
    // -----------------------------------------------------------------------------------------
    console.log(`[${theme}] Group 2.1: Danh sách chờ phê duyệt`);
    await page.goto('http://localhost:5666/cash-fund/approvals');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1000);
    await ensureTheme(theme);
    await page.waitForTimeout(500);
    await snap(GROUPS.approvals, '01-danh-sach-cho-phe-duyet', theme);

    console.log(`[${theme}] Group 2.2: Modal thực hiện phê duyệt / từ chối / trả về (Full screen)`);
    await page.goto('http://localhost:5666/cash-fund/approvals');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(800);
    const approveActionBtn = page.locator('button.text-primary:not([disabled])').first();
    if (await approveActionBtn.isVisible()) {
      await approveActionBtn.click();
      await page.waitForTimeout(800);
      await snap(GROUPS.approvals, '02-modal-thuc-hien-phe-duyet', theme);
    }

    // -----------------------------------------------------------------------------------------
    // GROUP 3: Sổ quỹ & Bút toán thu / chi (/cash-fund/transactions)
    // -----------------------------------------------------------------------------------------
    console.log(`[${theme}] Group 3.1: Sổ quỹ và danh sách bút toán PT/PC`);
    await page.goto('http://localhost:5666/cash-fund/transactions');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1000);
    await ensureTheme(theme);
    await page.waitForTimeout(500);
    await snap(GROUPS.transactions, '01-danh-sach-but-toan-so-quy', theme);

    console.log(`[${theme}] Group 3.2: Modal chi tiết chứng từ thu chi (Full screen)`);
    await page.goto('http://localhost:5666/cash-fund/transactions');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(800);
    const txCodeLink = page.locator('.ant-table-cell span.font-mono.cursor-pointer').first();
    await txCodeLink.click();
    await page.waitForTimeout(800);
    await snap(GROUPS.transactions, '02-modal-chi-tiet-chung-tu', theme);

    console.log(`[${theme}] Group 3.3: Modal xác nhận giao dịch tiền mặt (Full screen)`);
    await page.goto('http://localhost:5666/cash-fund/transactions');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(800);
    const confirmBtn = page.locator('button.text-emerald-600:not([disabled])').first();
    if (await confirmBtn.isVisible()) {
      await confirmBtn.click();
      await page.waitForTimeout(800);
      await snap(GROUPS.transactions, '03-modal-xac-nhan-giao-dich-tien-mat', theme);
    }

    // -----------------------------------------------------------------------------------------
    // GROUP 4: Điều chuyển quỹ (/cash-fund/adjustments)
    // -----------------------------------------------------------------------------------------
    console.log(`[${theme}] Group 4.1: Danh sách điều chuyển quỹ`);
    await page.goto('http://localhost:5666/cash-fund/adjustments');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1000);
    await ensureTheme(theme);
    await page.waitForTimeout(500);
    await snap(GROUPS.adjustments, '01-danh-sach-dieu-chuyen-quy', theme);

    console.log(`[${theme}] Group 4.2: Modal tạo điều chỉnh quỹ mới (Full screen)`);
    await page.goto('http://localhost:5666/cash-fund/adjustments');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(800);
    const createAdjBtn = page.locator('button:has-text("Tạo điều chỉnh quỹ")').first();
    if (await createAdjBtn.isVisible()) {
      await createAdjBtn.click();
      await page.waitForTimeout(800);
      await snap(GROUPS.adjustments, '02-modal-tao-dieu-chuyen-quy', theme);
    }

    console.log(`[${theme}] Group 4.3: Modal chi tiết điều chuyển quỹ (Full screen)`);
    await page.goto('http://localhost:5666/cash-fund/adjustments');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(800);
    const adjCodeLink = page.locator('.ant-table-cell span.font-mono.cursor-pointer').first();
    if (await adjCodeLink.isVisible()) {
      await adjCodeLink.click();
      await page.waitForTimeout(800);
      await snap(GROUPS.adjustments, '03-modal-chi-tiet-dieu-chuyen', theme);
    }

    console.log(`[${theme}] Group 4.4: Modal phê duyệt điều chuyển quỹ (Full screen)`);
    await page.goto('http://localhost:5666/cash-fund/adjustments');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(800);
    const approveAdjBtn = page.locator('button.text-primary:not([disabled])').first();
    if (await approveAdjBtn.isVisible()) {
      await approveAdjBtn.click();
      await page.waitForTimeout(800);
      await snap(GROUPS.adjustments, '04-modal-phe-duyet-dieu-chuyen', theme);
    }

    // -----------------------------------------------------------------------------------------
    // GROUP 5: Báo cáo & Thống kê quỹ tiền mặt (/cash-fund/reports)
    // -----------------------------------------------------------------------------------------
    console.log(`[${theme}] Group 5.1: Báo cáo - Tổng quan số dư nguồn quỹ`);
    await page.goto('http://localhost:5666/cash-fund/reports');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1000);
    await ensureTheme(theme);
    await page.waitForTimeout(600);
    await snap(GROUPS.reports, '01-bao-cao-tong-quan-so-du', theme);

    console.log(`[${theme}] Group 5.2: Báo cáo - Thống kê Thu - Chi & Tần suất`);
    const analyticsTab = page.locator('.ant-tabs-tab:has-text("Thống kê Thu - Chi")').first();
    await analyticsTab.click();
    await page.waitForTimeout(800);
    await snap(GROUPS.reports, '02-bao-cao-phan-tich-tan-suat', theme);

    console.log(`[${theme}] Group 5.3: Báo cáo - Sổ chi tiết khoản Thu - Chi`);
    const itemTab = page.locator('.ant-tabs-tab:has-text("Sổ chi tiết")').first();
    await itemTab.click();
    await page.waitForTimeout(800);
    await snap(GROUPS.reports, '03-bao-cao-theo-khoan-muc', theme);

    console.log(`[${theme}] Group 5.4: Báo cáo - Sổ quỹ tiền mặt`);
    const movementTab = page.locator('.ant-tabs-tab:has-text("Sổ quỹ tiền mặt")').first();
    await movementTab.click();
    await page.waitForTimeout(800);
    await snap(GROUPS.reports, '04-bao-cao-so-quy-tien-mat', theme);

    // -----------------------------------------------------------------------------------------
    // GROUP 6: Thiết lập danh mục & Nguồn quỹ (/master-data/cash-fund)
    // -----------------------------------------------------------------------------------------
    console.log(`[${theme}] Group 6.1: Danh mục khoản mục thu chi`);
    await page.goto('http://localhost:5666/master-data/cash-fund');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1000);
    await ensureTheme(theme);
    await page.waitForTimeout(600);
    await snap(GROUPS.masterData, '01-danh-muc-khoan-muc', theme);

    console.log(`[${theme}] Group 6.2: Modal thêm khoản mục mới (Full screen)`);
    await page.goto('http://localhost:5666/master-data/cash-fund');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(800);
    const addCatBtn = page.locator('button:has-text("Thêm khoản mục")').first();
    if (await addCatBtn.isVisible()) {
      await addCatBtn.click();
      await page.waitForTimeout(800);
      await snap(GROUPS.masterData, '02-modal-them-khoan-muc', theme);
    }

    console.log(`[${theme}] Group 6.3: Thiết lập nguồn quỹ tiền mặt`);
    await page.goto('http://localhost:5666/master-data/cash-fund');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(800);
    const sourcesTab = page.locator('.ant-tabs-tab:has-text("Nguồn tiền quỹ")').first();
    await sourcesTab.click();
    await page.waitForTimeout(800);
    await snap(GROUPS.masterData, '03-thiet-lap-nguon-quy', theme);

    console.log(`[${theme}] Group 6.4: Modal thêm nguồn quỹ mới (Full screen)`);
    const addSourceBtn = page.locator('button:has-text("Thêm nguồn tiền")').first();
    if (await addSourceBtn.isVisible()) {
      await addSourceBtn.click();
      await page.waitForTimeout(800);
      await snap(GROUPS.masterData, '04-modal-them-nguon-quy', theme);
    }

    console.log(`[${theme}] Group 6.5: Tab Loại tiền tệ`);
    await page.goto('http://localhost:5666/master-data/cash-fund');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(800);
    const currTab = page.locator('.ant-tabs-tab:has-text("Loại tiền tệ")').first();
    await currTab.click();
    await page.waitForTimeout(800);
    await snap(GROUPS.masterData, '05-danh-sach-loai-tien-te', theme);

    console.log(`[${theme}] Group 6.6: Cấu hình quy trình duyệt chuẩn`);
    await page.goto('http://localhost:5666/master-data/cash-fund');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(800);
    const workflowsTab = page.locator('.ant-tabs-tab:has-text("Tuyến phê duyệt")').first();
    await workflowsTab.click();
    await page.waitForTimeout(800);
    await snap(GROUPS.masterData, '06-cau-hinh-quy-trinh-duyet', theme);

    console.log(`Completed theme: ${theme}`);
  }

  await page.goto('http://localhost:5666/cash-fund/proposals');
  await page.waitForLoadState('networkidle');
  await ensureTheme('light');

  console.log('\nAll Cash Fund screenshots captured successfully!');
  await browser.close();
}

main().catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
