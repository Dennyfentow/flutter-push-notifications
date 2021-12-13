importScripts("https://www.gstatic.com/firebasejs/8.6.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.6.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyDqh_P0XISW7QJ1a0di4NTgT0icmy1EQeA",
  authDomain: "dev-meetups-78c19.firebaseapp.com",
  projectId: "dev-meetups-78c19",
  storageBucket: "dev-meetups-78c19.appspot.com",
  messagingSenderId: "818484536144",
  appId: "1:818484536144:web:43887e986bbfcabea28255",
  measurementId: "G-7HM6N6FXBB",
});
// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessage", m);
});