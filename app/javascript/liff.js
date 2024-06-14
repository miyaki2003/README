import liff from '@line/liff';

document.addEventListener('DOMContentLoaded', function() {
  document.getElementById('login-button').addEventListener('click', function(event) {
      event.preventDefault();
      initializeLiff();
  });
});

function initializeLiff() {
    liff.init({
        liffId: '2003779201-OwqpG72P',
        withLoginOnExternalBrowser: true
    }).then(() => {
        fetch('/get_id_token')
            .then(response => response.json())
            .then(data => {
                if (data.id_token) {
                    handleLoggedInUser(data.id_token);
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

function handleLoggedInUser(idToken) {
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
              window.location.href = '/events';
          } else {
              console.error('User authentication failed');
          }
      }).catch(error => {
          console.error('Error sending ID token to server:', error);
      });
}
