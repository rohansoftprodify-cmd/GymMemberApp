#!/usr/bin/env node
/**
 * Renders MEMBER_APP_UI_CATALOG.html to PDF using Chrome headless.
 */

import { execFileSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const INPUT = path.join(__dirname, 'MEMBER_APP_UI_CATALOG.html');
const OUTPUT = path.join(__dirname, 'MEMBER_APP_UI_CATALOG.pdf');

const CHROME_CANDIDATES = [
  '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
  '/Applications/Chromium.app/Contents/MacOS/Chromium',
  '/usr/bin/google-chrome',
  '/usr/bin/chromium-browser',
];

function findChrome() {
  for (const candidate of CHROME_CANDIDATES) {
    if (fs.existsSync(candidate)) return candidate;
  }
  return null;
}

function main() {
  if (!fs.existsSync(INPUT)) {
    console.error(`Error: ${INPUT} not found`);
    process.exit(1);
  }

  const chrome = findChrome();
  if (!chrome) {
    console.error('Error: Google Chrome not found. Install Chrome to generate PDF.');
    process.exit(1);
  }

  const fileUrl = `file://${INPUT}`;

  console.log('Rendering PDF with Chrome headless...');

  execFileSync(
    chrome,
    [
      '--headless=new',
      '--disable-gpu',
      '--no-sandbox',
      '--run-all-compositor-stages-before-draw',
      '--virtual-time-budget=15000',
      `--print-to-pdf=${OUTPUT}`,
      fileUrl,
    ],
    { stdio: 'inherit' },
  );

  if (!fs.existsSync(OUTPUT)) {
    console.error('Error: PDF was not created.');
    process.exit(1);
  }

  const stats = fs.statSync(OUTPUT);
  console.log(`Done: ${OUTPUT} (${Math.round(stats.size / 1024)} KB)`);
}

main();
