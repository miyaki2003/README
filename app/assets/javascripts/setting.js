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
        fetch('/staticpages/terms', {
          method: 'GET',
          headers: {
            'X-Requested-With': 'XMLHttpRequest'
          }
        })
        .then(response => {
          if (response.ok) {
            return response.json();
          } else {
            throw new Error('Network response was not ok.');
          }
        })
        .then(data => {
          modalContent.innerHTML = '';
          modalContent.innerHTML = data.html;
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
        fetch('/staticpages/privacy_policy', {
          method: 'GET',
          headers: {
            'X-Requested-With': 'XMLHttpRequest'
          }
        })
        .then(response => {
          if (response.ok) {
            return response.json();
          } else {
            throw new Error('Network response was not ok.');
          }
        })
        .then(data => {
          modalContent.innerHTML = '';
          modalContent.innerHTML = data.html;
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