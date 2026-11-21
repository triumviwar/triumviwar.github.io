// PLAYTEST of the web build (job playtest-menus-online): the language and a setting chosen by clicks survive a reload,
// the music player downloads a piece when it is tapped. Serve build/web first (tools/web/build_web.sh, then
//   python3 -m http.server 8765 -d build/web &), then:
//   node tools/playtest/web_settings.cjs [url] [outdir]
// Coordinates: the game's own 1280x720 computer layout (read from tools/playtest runs); a page centred on screen sits
// 15 px higher on the web (the F11 line under the menu).
const { chromium } = require('playwright');
const fs = require('fs');
(async () => {
const url = process.argv[2] || 'http://127.0.0.1:8765/index.html';
const out = process.argv[3] || '/tmp/web_pt';
fs.mkdirSync(out, { recursive: true });
const browser = await chromium.launch({ args: ['--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader', '--ignore-gpu-blocklist'] });
const ctx = await browser.newContext({ viewport: { width: 1280, height: 720 }, deviceScaleFactor: 1 });
const page = await ctx.newPage();
const log = [];
let errors = 0;
page.on('console', (m) => { const t = m.text(); log.push(`[${m.type()}] ${t}`); if (/SCRIPT ERROR|Parse Error|^ERROR:/.test(t) && !/ReadPixels|GPU stall/.test(t)) errors++; });
page.on('pageerror', (e) => { log.push(`[pageerror] ${e.message}`); errors++; });
let music = [];
page.on('requestfinished', (r) => { if (r.url().includes('/music/')) music.push(r.url().split('/music/')[1]); });
const shot = (n) => page.screenshot({ path: `${out}/web_${n}.png` });
const click = async (x, y, wait = 1500) => { await page.mouse.click(x, y); await page.waitForTimeout(wait); };
const up = async () => { for (let i = 0; i < 120; i++) { await page.waitForTimeout(1000); if (log.some((l) => l.includes('[session]'))) return true; } return false; };
await page.goto(url, { waitUntil: 'load' });
console.log(`WEB-PT engine up: ${await up()}`);
await page.waitForTimeout(4000);
await click(505, 362, 3000);              // COMPUTER on the first page
await shot('1_menu_en');
await click(1196, 29, 3000);              // the Brazilian flag
await shot('2_menu_pt');
await click(402, 189, 2500);              // CONFIGURAÇÕES
await shot('3_settings_pt');
await click(632, 152 - 15, 2000);         // SOM
await shot('4_sound');
const before = music.length;
await click(828, 607 - 15, 3000);         // MUSIC PLAYER: ABRIR
await click(215, 276, 6000);              // The Orchard Minuet
await shot('5_music_player');
console.log(`WEB-PT music pieces fetched when the player tapped one: ${music.length - before} (${music.slice(before).join(', ')})`);
// a reload, as when the tab is closed and opened again: the language must still be Portuguese
const t = Date.now();
await page.waitForTimeout(2000);
await page.reload({ waitUntil: 'load' });
await up();
await page.waitForTimeout(6000);
await shot('6_after_reload');
const lang = await page.evaluate(() => new Promise((res) => {
	// the settings file lives in the browser's IndexedDB (user://): read it back the way the engine stores it
	const rq = indexedDB.open('/userfs');
	rq.onerror = () => res('no db');
	rq.onsuccess = () => {
		try {
			const db = rq.result, tx = db.transaction(db.objectStoreNames[0], 'readonly'), st = tx.objectStore(db.objectStoreNames[0]);
			const all = st.getAll(), keys = st.getAllKeys();
			tx.oncomplete = () => {
				const i = keys.result.findIndex((k) => String(k).endsWith('settings.cfg'));
				if (i < 0) return res('no settings.cfg in ' + keys.result.length + ' files');
				const c = all.result[i].contents; res(new TextDecoder().decode(c).match(/language="(\w+)"/)?.[1] || 'none');
			};
		} catch (e) { res('err ' + e); }
	};
}));
console.log(`WEB-PT language saved in the browser after the reload: ${lang}`);
fs.writeFileSync(`${out}/web_console.txt`, log.join('\n'));
console.log(`WEB-PT errors: ${errors}`);
await browser.close();
})();
