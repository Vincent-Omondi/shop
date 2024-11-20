// Configure your import map in config/importmap.rb
import "@hotwired/turbo-rails"
import "../controllers"

console.log('Application.js is loaded!'); 

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
// File upload initialization
// Initialize File Upload
const initializeFileUpload = () => {
  const fileInput = document.querySelector('.product-image');
  if (!fileInput) return;
  fileInput.addEventListener('change', (e) => {
    console.log("File input changed");
    const file = e.target.files[0];
    console.log('Selected file:', file);
    const filename = document.getElementById('filename');
    const imagePreview = document.getElementById('image-preview');

    if (imagePreview) {
      imagePreview.innerHTML = ''; // Clear previous preview
    }

    if (file) {
      if (filename) {
        filename.textContent = file.name;
      }

      const acceptedTypes = ['image/jpeg', 'image/png', 'image/jpg'];
      if (!acceptedTypes.includes(file.type)) {
        alert('Please select a JPEG or PNG image file');
        fileInput.value = '';
        if (filename) {
          filename.textContent = 'No file selected';
        }
        return;
      }

      const maxSize = 5 * 1024 * 1024;
      if (file.size > maxSize) {
        alert('File size must be less than 5MB');
        fileInput.value = '';
        if (filename) {
          filename.textContent = 'No file selected';
        }
        return;
      }

      if (imagePreview) {
        const reader = new FileReader();
        reader.onload = (e) => {
          const img = document.createElement('img');
          img.src = e.target.result;
          img.style.maxHeight = '200px';
          img.style.maxWidth = '100%';
          img.className = 'mt-2 rounded';
          imagePreview.appendChild(img);
        };
        reader.readAsDataURL(file);
      }
    } else {
      if (filename) {
        filename.textContent = 'No file selected';
      }
    }
  });
};

document.addEventListener('DOMContentLoaded', initializeFileUpload);
document.addEventListener('turbo:load', initializeFileUpload);
