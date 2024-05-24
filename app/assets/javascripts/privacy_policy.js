document.addEventListener('DOMContentLoaded', function() {
  const privacyPolicyLink = document.getElementById('privacy-policy-link');
  const modalContent = document.querySelector('#modal-content');
  const settingEventModal = document.querySelector('#settingEventModal');
  const originalContent = modalContent.innerHTML;

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
      })
      .catch(error => {
        console.error('There was a problem with the fetch operation:', error);
      });
    });
  }

  if (settingEventModal) {
    settingEventModal.addEventListener('hidden.bs.modal', function () {
      modalContent.innerHTML = originalContent;
    });
  }
});
