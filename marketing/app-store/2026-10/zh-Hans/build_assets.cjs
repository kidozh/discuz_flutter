/* Rebuild editable SVG artboards and opaque PNG exports from native captures.
 * Requires Node.js and sharp (resolve it with NODE_PATH if it is not local).
 * Native screenshots are embedded without altering their UI or proportions.
 */
const fs = require('node:fs/promises');
const path = require('node:path');
const crypto = require('node:crypto');
const sharp = require('sharp');

const root = __dirname;
const escape = (s) => String(s).replace(/[&<>"']/g, (c) => ({'&':'&amp;', '<':'&lt;', '>':'&gt;', '"':'&quot;', "'":'&apos;'}[c]));
const uri = (bytes) => `data:image/png;base64,${bytes.toString('base64')}`;
const themes = {
  mint: ['#ECF6F2', '#F9FCF7', '#0C3540', '#45696C', '#C1E6DA'],
  sand: ['#F8F1E7', '#FFFCF7', '#313D3D', '#68716B', '#E5D9BE'],
  lilac: ['#F0ECFA', '#FBF9FF', '#303852', '#666B84', '#D9CDEC'],
  night: ['#082E38', '#124C51', '#F2FBF8', '#BCDFD7', '#397E80'],
};
const sizes = {
  'duo-inner': [[2853,2007],[2007,2853]],
  'duo-outer': [[1398,2034],[2034,1398]],
  'iphone': [[1206,2622],[1179,2556],[2622,1206],[2556,1179]],
  'iphone-large': [[1320,2868],[1290,2796],[1260,2736],[2868,1320],[2796,1290],[2736,1260]],
  'ipad-13': [[2064,2752],[2752,2064],[2048,2732],[2732,2048]],
  'ipad-11': [[1668,2420],[2420,1668],[1668,2388],[2388,1668],[1640,2360],[2360,1640],[1488,2266],[2266,1488]],
};

function artboard(shot, bytes, w, h, icon) {
  const [bg, end, ink, secondary, motif] = themes[shot.theme];
  const landscape = w > h;
  const tall = h / w > 1.85;
  const left = landscape ? 156 : 86;
  const titleSize = landscape ? 110 : (tall ? 100 : 94);
  const titleY = landscape ? 148 : (tall ? 192 : 164);
  const titleStep = titleSize * 1.2;
  const title = shot.title.map((line, i) => `<text x="${left}" y="${titleY + i * titleStep}" font-size="${titleSize}" font-weight="700" fill="${ink}">${escape(line)}</text>`).join('');
  const subtitleY = titleY + (shot.title.length - 1) * titleStep + (landscape ? 88 : 84);
  const imageTop = Math.max(landscape ? 316 : (tall ? 500 : 350), subtitleY + 76);
  const maxWidth = landscape ? w - 520 : w - 190;
  const bottom = shot.footnote ? 118 : 80;
  const scale = Math.min(maxWidth / w, (h - imageTop - bottom) / h);
  const iw = w * scale, ih = h * scale;
  const ix = (w - iw) / 2, iy = imageTop;
  const radius = landscape ? 44 : 58;
  const pad = landscape ? 13 : 11;
  const brandX = landscape ? w - 370 : left;
  const brandY = landscape ? 75 : 69;
  const brandSize = landscape ? 52 : 43;
  const footnote = shot.footnote ? `<text x="${w / 2}" y="${h - 42}" font-size="${landscape ? 28 : 25}" text-anchor="middle" fill="${secondary}">${escape(shot.footnote)}</text>` : '';
  return `<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}">
  <title>${escape(shot.title.join(''))} — 谈坛</title>
  <desc>Actual app screenshot, with editable marketing text. UI content and aspect ratio are preserved.</desc>
  <defs>
    <linearGradient id="background" x2="1" y2="1"><stop stop-color="${bg}"/><stop offset="1" stop-color="${end}"/></linearGradient>
    <clipPath id="screen"><rect x="${ix}" y="${iy}" width="${iw}" height="${ih}" rx="${radius}"/></clipPath>
  </defs>
  <rect width="${w}" height="${h}" fill="url(#background)"/>
  <circle cx="${w * 0.92}" cy="${h * 0.60}" r="${w * 0.40}" fill="${motif}" opacity="0.20"/>
  <circle cx="${w * 0.04}" cy="${h * 0.98}" r="${w * 0.34}" fill="${motif}" opacity="0.35"/>
  <g font-family="Hiragino Sans GB, PingFang SC, sans-serif">
    <image x="${brandX}" y="${brandY - brandSize + 4}" width="${brandSize}" height="${brandSize}" href="${icon}"/>
    <text x="${brandX + brandSize + 14}" y="${brandY}" fill="${secondary}" font-size="${landscape ? 38 : 32}" font-weight="600">谈坛</text>
    ${title}
    <text x="${left}" y="${subtitleY}" font-size="${landscape ? 46 : 34}" fill="${secondary}">${escape(shot.subtitle)}</text>
    <rect x="${ix - pad - 6}" y="${iy - pad + 22}" width="${iw + 2 * pad + 12}" height="${ih + 2 * pad}" rx="${radius + pad}" fill="#001D27" opacity="0.05"/>
    <rect x="${ix - pad}" y="${iy - pad}" width="${iw + 2 * pad}" height="${ih + 2 * pad}" rx="${radius + pad}" fill="#FFFFFF"/>
    <image x="${ix}" y="${iy}" width="${iw}" height="${ih}" href="${uri(bytes)}" clip-path="url(#screen)"/>
    ${footnote}
  </g>
</svg>`;
}

async function main() {
  const manifest = JSON.parse(await fs.readFile(path.join(root, 'manifest.json'), 'utf8'));
  const icon = uri(await fs.readFile(path.join(root, 'brand/app-icon.png')));
  const galleryOnly = process.argv.includes('--gallery-only');
  const report = galleryOnly ? JSON.parse(await fs.readFile(path.join(root, 'validation.json'), 'utf8')).shots : [];
  for (const shot of galleryOnly ? [] : manifest.shots) {
    const source = path.join(root, shot.source);
    const bytes = await fs.readFile(source);
    const metadata = await sharp(bytes).metadata();
    const {width:w, height:h} = metadata;
    if (!sizes[shot.group]?.some(([x,y]) => x === w && y === h)) throw new Error(`Unexpected capture size: ${shot.source} ${w}×${h}`);
    for (const dir of ['sources', 'previews', `store/${shot.group}`, `upload-originals/${shot.group}`]) await fs.mkdir(path.join(root, dir), {recursive:true});
    const svg = artboard(shot, bytes, w, h, icon);
    await fs.writeFile(path.join(root, `sources/${shot.id}.svg`), svg);
    const filename = `${shot.id}-${w}x${h}.png`;
    const store = `store/${shot.group}/${filename}`;
    const original = `upload-originals/${shot.group}/${filename}`;
    await sharp(Buffer.from(svg)).flatten({background:'#ffffff'}).removeAlpha().png().toFile(path.join(root, store));
    await sharp(bytes).flatten({background:'#ffffff'}).removeAlpha().png().toFile(path.join(root, original));
    // Retain a lightweight preview for external uses. The gallery itself loads
    // the full native PNG, never a thumbnail enlarged on a Retina display.
    await sharp(path.join(root, store)).resize({width:960, withoutEnlargement:true}).png().toFile(path.join(root, `previews/${shot.id}.png`));
    const output = await sharp(path.join(root,store)).metadata();
    if (output.hasAlpha || output.width !== w || output.height !== h) throw new Error(`Invalid store export: ${filename}`);
    const sourcePixels = await sharp(bytes).flatten({background:'#ffffff'}).removeAlpha().raw().toBuffer();
    const exportedPixels = await sharp(path.join(root,original)).raw().toBuffer();
    if (!sourcePixels.equals(exportedPixels)) throw new Error(`Original pixels changed: ${shot.id}`);
    report.push({...shot, width:w, height:h, store, original, sha256:crypto.createHash('sha256').update(bytes).digest('hex'), alpha:false, originalPixelsMatchSource:true});
    console.log(`${shot.id}: ${w}×${h}, RGB PNG`);
  }
  await fs.writeFile(path.join(root,'validation.json'), JSON.stringify({generated_at:new Date().toISOString(), app:manifest.app, version:manifest.version, specification:manifest.specification, shots:report},null,2)+'\n');
  const groups = [...new Set(report.map(s=>s.group))];
  const labels = {'duo-inner':'iPhone Duo · 内屏', 'duo-outer':'iPhone Duo · 外屏', iphone:'iPhone · 标准屏幕', 'iphone-large':'iPhone Pro Max · 大屏幕', 'ipad-13':'iPad Pro · 13 英寸', 'ipad-11':'iPad Pro · 11 英寸'};
  const sections = groups.map(group => `<section><h2>${labels[group]}</h2><div class="grid ${group === 'duo-inner' || group.startsWith('ipad') ? 'wide' : ''}">${report.filter(s=>s.group===group).map(s=>`<article><a href="viewer.html?id=${s.id}"><img src="${s.store}" width="${s.width}" height="${s.height}" loading="lazy" decoding="async" alt="${escape(s.title.join(''))}"/></a><div class="info"><b>${escape(s.title.join(''))}</b><span>${s.width} × ${s.height} · RGB PNG${s.recommended ? ' · 优先推荐' : ''}</span><br><a class="inspect" href="viewer.html?id=${s.id}&zoom=actual">100% 像素查看 ↗</a><nav><a href="${s.store}" download>展示图 PNG</a><a href="${s.original}" download>原图 PNG</a><a href="sources/${s.id}.svg" download>可编辑 SVG</a></nav></div></article>`).join('')}</div></section>`).join('');
  const template = await fs.readFile(path.join(root,'gallery_template.html'),'utf8');
  const values = {COUNT:report.length, VERSION:escape(manifest.version), SECTIONS:sections, SPECIFICATION:escape(manifest.specification), PENDING:escape(manifest.pendingNote || '')};
  const html = template.replace(/\{\{(\w+)\}\}/g, (_,key)=>String(values[key] ?? ''));
  await fs.writeFile(path.join(root,'index.html'),html);
  await fs.writeFile(path.join(root,'README.txt'), `谈坛 App Store 素材 · ${manifest.locale}\n\n共 ${report.length} 张原生截图、${report.length} 张带标题展示图。\n\nstore/：带标题 RGB PNG\nupload-originals/：无标题 RGB PNG，源图逐像素一致\nraw/：模拟器原生捕获\nsources/：可编辑 SVG\nvalidation.json：尺寸、SHA-256、像素一致性\n\n预览：在本目录运行 python3 -m http.server 8765，然后打开 http://127.0.0.1:8765/\n画廊直接加载完整 PNG；100% 像素模式按屏幕实际像素显示，不放大缩略图。\n\n${manifest.pendingNote || ''}\n\n尚未上传或发布到 App Store Connect。\n`);
}
main().catch(e=>{console.error(e);process.exit(1)});
