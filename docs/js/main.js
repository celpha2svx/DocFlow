// === Navbar scroll effect ===
const nav = document.querySelector('.nav');
const hero = document.querySelector('.hero');

function onScroll() {
  const scrollY = window.scrollY;
  const heroBottom = hero?.offsetHeight ?? 400;
  nav.classList.toggle('scrolled', scrollY > heroBottom * 0.6);
}

window.addEventListener('scroll', onScroll, { passive: true });

// === Mobile menu toggle ===
const toggle = document.querySelector('.mobile-toggle');
const navLinks = document.querySelector('.nav-links');

toggle?.addEventListener('click', () => {
  navLinks.classList.toggle('open');
});

// Close menu on link click
document.querySelectorAll('.nav-links a').forEach(link => {
  link.addEventListener('click', () => {
    navLinks.classList.remove('open');
  });
});

// === Intersection Observer for reveal animations ===
const observer = new IntersectionObserver(
  (entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.style.opacity = '1';
        entry.target.style.transform = 'translateY(0)';
      }
    });
  },
  { threshold: 0.1 }
);

document.querySelectorAll('.feature-card, .calc-card, .download-card').forEach(el => {
  el.style.opacity = '0';
  el.style.transform = 'translateY(24px)';
  el.style.transition = 'opacity 0.6s ease-out, transform 0.6s ease-out';
  observer.observe(el);
});

// === Smooth reveal for category sections ===
document.querySelectorAll('.calc-category').forEach((el, i) => {
  el.style.opacity = '0';
  el.style.transform = 'translateY(20px)';
  el.style.transition = `opacity 0.5s ease-out ${i * 0.1}s, transform 0.5s ease-out ${i * 0.1}s`;
  observer.observe(el);
});

// === Toggle collapsed calculators ===
const toggleBtn = document.getElementById('toggleCalculators');
const collapsed = document.querySelector('.calculators-collapsed');
if (toggleBtn && collapsed) {
  toggleBtn.addEventListener('click', () => {
    const isHidden = !collapsed.classList.contains('visible');
    collapsed.classList.toggle('visible');
    toggleBtn.innerHTML = isHidden ? 'Show fewer calculators ↑' : 'View all 155 calculators ↓';
  });
}

// === Copy APK download link ===
document.querySelectorAll('[data-copy]').forEach(btn => {
  btn.addEventListener('click', async () => {
    const text = btn.dataset.copy;
    try {
      await navigator.clipboard.writeText(text);
      const original = btn.innerHTML;
      btn.innerHTML = '<span style="font-size:0.8rem">✓ Copied!</span>';
      setTimeout(() => { btn.innerHTML = original; }, 2000);
    } catch {}
  });
});
