document.addEventListener('DOMContentLoaded', function() {
  liff.init({ liffId: 'YOUR_LIFF_ID' }).then(() => {
    if (!liff.isLoggedIn()) {
      liff.login();
    } else {
    }
  }).catch((err) => {
    console.log('LIFF Initialization failed ', err);
  });
});
