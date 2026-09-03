import re, pathlib
p = pathlib.Path("index.html"); s = p.read_text(encoding="utf-8")

# 1. font link: add italic axis + preconnect; load shared stylesheet
s = s.replace(
 '<link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,500;9..144,600;9..144,700&family=Archivo:wght@400;500;600;700&family=Sacramento&display=swap" rel="stylesheet">',
 '<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>\n'
 '<link href="https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,500;0,9..144,600;0,9..144,700;1,9..144,600&family=Archivo:wght@400;500;600;700&family=Sacramento&display=swap" rel="stylesheet">\n'
 '<link rel="stylesheet" href="/site.css">')

# 2. strip the nav CSS block from the inline stylesheet (site.css owns it now)
s = re.sub(r"  /\* ---------- nav ---------- \*/.*?(?=  /\* ---------- hero ---------- \*/)",
           "", s, flags=re.S)

# 3. strip the footer CSS block
s = re.sub(r"  footer\{padding:3rem 5vw 4rem.*?footer a\{color:var\(--aqua-deep\);text-decoration:none;font-weight:600\}\n",
           "", s, flags=re.S)

# 4. drop the hero photo credit rule + markup
s = s.replace('  .hero-credit{position:absolute;right:1rem;bottom:.8rem;z-index:2;font-size:.7rem;color:rgba(11,52,70,.4)}\n','')
s = re.sub(r'\s*<span class="hero-credit">.*?</span>', '', s)

# 5. old mobile rule for the retired nav
s = s.replace('    .nav-links a.hide-sm{display:none}\n','')

# 6. swap nav markup for the shared marker
s = re.sub(r'<nav class="nav">.*?</nav>', '<!--NAV--><!--/NAV-->', s, flags=re.S)

# 7. swap footer markup for the shared marker
s = re.sub(r'<footer>.*?</footer>', '<!--FOOT--><!--/FOOT-->', s, flags=re.S)

# 8. load shared nav script
s = s.replace('<script>\nconst SB_URL', '<script src="/site.js"></script>\n<script>\nconst SB_URL')

p.write_text(s, encoding="utf-8")
print("nav marker:", s.count("<!--NAV-->"), "| foot marker:", s.count("<!--FOOT-->"),
      "| unsplash-credit:", s.count("hero-credit"), "| site.css:", s.count("site.css"),
      "| site.js:", s.count("site.js"))
