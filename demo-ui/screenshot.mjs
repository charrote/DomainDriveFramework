import { chromium } from 'playwright';

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({
    viewport: { width: 1440, height: 900 },
  });
  
  // Wait for the Vite dev server to be ready
  await page.goto('http://localhost:5173/', { waitUntil: 'networkidle' });
  
  // Take screenshot of the full page
  await page.screenshot({ 
    path: '/Users/Yoo/SVN/00.GITHUB/DomainDriveFramework/demo-ui/screenshot.png',
    fullPage: true 
  });
  
  console.log('Screenshot saved to demo-ui/screenshot.png');
  
  await browser.close();
})();