document.addEventListener('DOMContentLoaded', function() {
  // LIFFの初期化
  liff.init({
      liffId: '2003779201-OwqpG72P'
  }).then(() => {

      if (liff.isLoggedIn()) {
          
          liff.getProfile().then(profile => {
              const userId = profile.userId;
              const displayName = profile.displayName;
              console.log('User ID:', userId);
              console.log('Display Name:', displayName);
              

              initializeCalendar(userId);
          }).catch((err) => {
              console.error('Error getting profile:', err);
          });
      } else {

          liff.login();
      }
  }).catch((err) => {
      console.error('LIFF Initialization failed', err);
  });
});
