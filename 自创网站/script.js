const universe = document.querySelector('.universe');
const starCount = 120;

for (let i = 0; i < starCount; i += 1) {
  const star = document.createElement('div');
  star.className = 'star';
  const size = Math.random() * 2 + 1;
  star.style.width = `${size}px`;
  star.style.height = `${size}px`;
  star.style.top = `${Math.random() * 100}%`;
  star.style.left = `${Math.random() * 100}%`;
  star.style.animationDuration = `${4 + Math.random() * 4}s`;
  star.style.opacity = `${0.4 + Math.random() * 0.7}`;
  universe.appendChild(star);
}
