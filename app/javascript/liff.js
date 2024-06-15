import liff from '@line/liff';

document.addEventListener('DOMContentLoaded', function() {
  
  // URLにliffパラメータが存在する場合のみLIFFの初期化を実行
  const urlParams = new URLSearchParams(window.location.search);
  if (urlParams.has('liff')) {
      const redirectUrl = window.location.href;
      initializeLiff(redirectUrl);
  } else {
      const loginButton = document.getElementById('login-button');
      if (loginButton) {
          loginButton.addEventListener('click', function(event) {
              event.preventDefault();
              initializeLiff(window.location.href);
          });
      }
  }
});

function initializeLiff(redirectUrl) {
    liff.init({
        liffId: '2003779201-OwqpG72P',
        withLoginOnExternalBrowser: true
    }).then(() => {
        if (liff.isLoggedIn()) {
            liff.getProfile().then(profile => {
                const idToken = liff.getIDToken();
                handleLoggedInUser(idToken, redirectUrl);
            }).catch((err) => {
                console.error('Failed to get profile', err);
            });
        } else {
            liff.login({ redirectUri: redirectUrl });
        }
    }).catch((err) => {
        console.error('LIFF Initialization failed', err);
    });
}

function handleLoggedInUser(idToken, redirectUrl) {
    fetch('/auth/line/callback', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ id_token: idToken })
    }).then(response => response.json())
      .then(data => {
          if (data.success) {
              console.log('User authenticated with Sorcery');
              window.location.href = redirectUrl;
          } else {
              console.error('User authentication failed');
          }
      }).catch(error => {
          console.error('Error sending ID token to server:', error);
      });
}
