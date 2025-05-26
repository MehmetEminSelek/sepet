// Import and configure the Firebase SDK
importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging-compat.js');

// Initialize the Firebase app in the service worker
firebase.initializeApp({
    apiKey: "AIzaSyAiKXOKhvdVzm1I5rg0yGhRIHOzJjGvLDk",
    authDomain: "ortaksepet.firebaseapp.com",
    projectId: "ortaksepet",
    storageBucket: "ortaksepet.firebasestorage.app",
    messagingSenderId: "653158228076",
    appId: "1:653158228076:web:fc04d24c5f9a14dafa9dd6",
    measurementId: "G-Z9VZXJQTYH"
});

// Retrieve an instance of Firebase Messaging so that it can handle background
// messages.
const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage(function (payload) {
    console.log('[firebase-messaging-sw.js] Received background message ', payload);
    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
        icon: '/icons/Icon-192.png'
    };

    self.registration.showNotification(notificationTitle, notificationOptions);
}); 