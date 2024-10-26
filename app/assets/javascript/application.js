// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

// import Rails from "@rails/ujs"
// import Turbolinks from "turbolinks"
// import * as ActiveStorage from "@rails/activestorage"
// import "channels"

// Rails.start()
// Turbolinks.start()
// ActiveStorage.start()

document.addEventListener('turbolinks:load', () => {
    // Auto-hide flash messages
    const flashMessages = document.querySelectorAll('.notification');
    flashMessages.forEach(flash => {
        setTimeout(() => {
            flash.style.display = 'none';
        }, 3000);
    });

    // Get all "navbar-burger" elements
    const $navbarBurgers = Array.from(document.querySelectorAll('.navbar-burger'));

    // Check if there are any navbar burgers
    if ($navbarBurgers.length > 0) {
        // Add a click event on each of them
        $navbarBurgers.forEach(el => {
            el.addEventListener('click', () => {
                // Get the target from the "data-target" attribute
                const target = el.dataset.target;
                const $target = document.getElementById(target);

                // Toggle the "is-active" class on both the "navbar-burger" and the "navbar-menu"
                el.classList.toggle('is-active');
                $target.classList.toggle('is-active');
            });
        });
    }

    // Auto-hide global notifications
    const notifications = document.querySelectorAll('.global-notification');
    notifications.forEach(notification => {
        setTimeout(() => {
            notification.style.display = 'none';
        }, 5000);
    });
});
