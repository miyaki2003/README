document.addEventListener('DOMContentLoaded', function() {
  const modalContent = document.querySelector('#modal-content');
  const settingEventModal = document.querySelector('#settingEventModal');
  const originalContent = modalContent.innerHTML;

  function attachPrivacyPolicyListener() {
    const termsLink = document.getElementById('terms-link');
    const privacyPolicyLink = document.getElementById('privacy-policy-link');

    if (termsLink) {
      termsLink.addEventListener('click', function(event) {
        event.preventDefault();
        fetch('/terms', {
          method: 'GET',
          headers: {
            'X-Requested-With': 'XMLHttpRequest'
          }
        })
        .then(response => {
          if (response.ok) {
            return response.text();
          } else {
            throw new Error('Network response was not ok.');
          }
        })
        .then(html => {
          modalContent.innerHTML = '';
          modalContent.innerHTML = html;
          attachPrivacyPolicyListener();
        })
        .catch(error => {
          console.error('There was a problem with the fetch operation:', error);
        });
      });
    }

    if (privacyPolicyLink) {
      privacyPolicyLink.addEventListener('click', function(event) {
        event.preventDefault();
        fetch('/privacy_policy', {
          method: 'GET',
          headers: {
            'X-Requested-With': 'XMLHttpRequest'
          }
        })
        .then(response => {
          if (response.ok) {
            return response.text();
          } else {
            throw new Error('Network response was not ok.');
          }
        })
        .then(html => {
          modalContent.innerHTML = '';
          modalContent.innerHTML = html;
          attachPrivacyPolicyListener();
        })
        .catch(error => {
          console.error('There was a problem with the fetch operation:', error);
        });
      });
    }
  }

  attachPrivacyPolicyListener();

  if (settingEventModal) {
    settingEventModal.addEventListener('hidden.bs.modal', function () {
      modalContent.innerHTML = originalContent;
      attachPrivacyPolicyListener();
    });
  }
});

