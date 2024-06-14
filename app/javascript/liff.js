import liff from '@line/liff';

document.addEventListener('DOMContentLoaded', function() {
    initializeLiff();
});

function initializeLiff() {
    liff.init({
        liffId: '2003779201-OwqpG72P',
        withLoginOnExternalBrowser: true
    }).then(() => {
        if (!liff.isLoggedIn()) {
            liff.login();
        } else {
            handleLoggedInUser();
        }
    }).catch((err) => {
        console.error('LIFF Initialization failed', err);
    });
}

function handleLoggedInUser() {
    const idToken = liff.getIDToken();
    sendIdTokenToServer(idToken);
}

function sendIdTokenToServer(idToken) {
    fetch('/liff_login', {
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
              window.location.href = `/auth/line/callback?id_token=${idToken}`;
          } else {
              console.error('User authentication failed');
          }
      }).catch(error => {
          console.error('Error sending ID token to server:', error);
      });
}

