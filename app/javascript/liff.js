import liff from '@line/liff';

document.addEventListener('DOMContentLoaded', function() {
  
  // URLにliffパラメータが存在する場合のみLIFFの初期化を実行
  const urlParams = new URLSearchParams(window.location.search);
  if (urlParams.has('liff')) {
      const redirectUrl = window.location.href; // URLを保存
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
        fetch('/get_id_token')
            .then(response => response.json())
            .then(data => {
                if (data.id_token) {
                    handleLoggedInUser(data.id_token, redirectUrl);
                } else if (data.logged_in) {
                    window.location.href = '/';
                } else {
                    console.error('No ID token available and user not logged in');
                }
            }).catch((err) => {
                console.error('Failed to fetch ID token', err);
            });
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
              window.location.href = redirectUrl; // 保存したURLにリダイレクト
          } else {
              console.error('User authentication failed');
          }
      }).catch(error => {
          console.error('Error sending ID token to server:', error);
      });
}
