document.addEventListener('DOMContentLoaded', function() {
  const originalContent = document.querySelector('#modal-content').innerHTML;
  const privacyPolicyLink = document.querySelector('a[href="/staticpages/privacy_policy"]');
  const settingEventModal = document.querySelector('#settingEventModal');
  const modalContent = document.querySelector('#modal-content');
  
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

  settingEventModal.addEventListener('hidden.bs.modal', function () {
    modalContent.innerHTML = originalContent;
  });
});