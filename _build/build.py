#!/usr/bin/env python3
"""Stamp the shared FETCH nav + footer into every page between markers."""
import re, pathlib, sys

NAV = """<nav class="nav">
  <a class="nav-logo" href="/" aria-label="FETCH home"><img src="/logo.svg" alt="Fetch"></a>
  <button class="nav-toggle" type="button" aria-label="Menu" aria-expanded="false" aria-controls="navLinks"><span></span></button>
  <div class="nav-links" id="navLinks">
    <a href="/creators.html">Creators</a>
    <a href="/properties.html">Properties</a>
    <a href="/network.html">Network</a>
    <a href="/proof.html">Proof</a>
    <a href="/pricing.html">Pricing</a>
    <a href="/about.html">About</a>
    <div class="nav-drop" data-open="false">
      <button type="button" aria-expanded="false" aria-haspopup="true">Demo <span class="car">▼</span></button>
      <div class="nav-drop-menu">
        <a href="/creator.html"><b>Creator dashboard</b><span>Taps, bookings and what you're owed</span></a>
        <a href="/property.html"><b>Property dashboard</b><span>Report stays, rank creators by proof</span></a>
        <a href="/app.html"><b>Tag &amp; Prove</b><span>The pilot tool that runs attribution</span></a>
        <p class="nav-drop-note">Demo data. Nothing here is a real booking.</p>
      </div>
    </div>
    <div class="nav-cta"><a class="btn" href="/#join">Join the pilot</a></div>
  </div>
</nav>"""

FOOT = """<footer class="site-foot">
  <div class="foot-grid">
    <div class="foot-brand">
      <a href="/" aria-label="FETCH home"><img src="/logo.svg" alt="Fetch"></a>
      <em>Travel content, made bookable. Creators earn cash on the direct bookings they drive — the property keeps the guest.</em>
    </div>
    <div>
      <h4>Platform</h4>
      <ul>
        <li><a href="/creators.html">For creators</a></li>
        <li><a href="/properties.html">For properties &amp; DMCs</a></li>
        <li><a href="/network.html">The network</a></li>
        <li><a href="/proof.html">How we prove it</a></li>
      </ul>
    </div>
    <div>
      <h4>Company</h4>
      <ul>
        <li><a href="/pricing.html">Pricing</a></li>
        <li><a href="/about.html">About FETCH</a></li>
        <li><a href="/#faq">FAQ</a></li>
        <li><a href="mailto:brian@brand-tastic.ca">Contact</a></li>
      </ul>
    </div>
    <div>
      <h4>Demo</h4>
      <ul>
        <li><a href="/creator.html">Creator dashboard</a></li>
        <li><a href="/property.html">Property dashboard</a></li>
        <li><a href="/app.html">Tag &amp; Prove</a></li>
        <li><a href="/#join">Join the pilot</a></li>
      </ul>
    </div>
  </div>
  <div class="foot-base">
    <span>&copy; 2026 FETCH — The best trip is the next one.</span>
    <span>Pilot build. Figures and profiles shown are illustrative. <a href="mailto:brian@brand-tastic.ca">brian@brand-tastic.ca</a></span>
  </div>
</footer>"""

def stamp(path):
    p = pathlib.Path(path)
    s = p.read_text(encoding="utf-8")
    orig = s
    s = re.sub(r"<!--NAV-->.*?<!--/NAV-->", "<!--NAV-->" + NAV + "<!--/NAV-->", s, flags=re.S)
    s = re.sub(r"<!--FOOT-->.*?<!--/FOOT-->", "<!--FOOT-->" + FOOT + "<!--/FOOT-->", s, flags=re.S)
    if s != orig:
        p.write_text(s, encoding="utf-8")
        return True
    return False

if __name__ == "__main__":
    files = sys.argv[1:] or [str(f) for f in pathlib.Path(".").glob("*.html")]
    for f in files:
        print(("updated " if stamp(f) else "no markers ") + f)
