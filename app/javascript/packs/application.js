// Configure your import map in config/importmap.rb
import "@hotwired/turbo-rails"
import "controllers"

// Burger menu functionality
const initializeMenu = () => {
    console.log('Menu initialization running');
    const $navbarBurgers = Array.prototype.slice.call(document.querySelectorAll('.navbar-burger'), 0);
    console.log('Found burger elements:', $navbarBurgers.length);
    
  $navbarBurgers.forEach(el => {
    el.addEventListener('click', () => {
      const target = el.dataset.target;
      const $target = document.getElementById(target);

      el.classList.toggle('is-active');
      $target.classList.toggle('is-active');
    });
  });
};

// Initialize on both turbo:load and DOMContentLoaded
document.addEventListener('DOMContentLoaded', initializeMenu);
document.addEventListener('turbo:load', initializeMenu);

// Auto-hide notifications
const initializeNotifications = () => {
  const notifications = document.querySelectorAll('.global-notification');
  notifications.forEach(notification => {
    setTimeout(() => {
      notification.style.display = 'none';
    }, 5000);
  });
};

document.addEventListener('DOMContentLoaded', initializeNotifications);
document.addEventListener('turbo:load', initializeNotifications);