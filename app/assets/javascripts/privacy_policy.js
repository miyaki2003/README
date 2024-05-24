document.addEventListener('DOMContentLoaded', function() {
  const originalContent = document.querySelector('#modal-content').innerHTML;
  document.querySelector('a[href="/staticpages/privacy_policy"]').addEventListener('click', function(event) {
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
      document.querySelector('#modal-content').innerHTML = data.html;
    })
    .catch(error => {
      console.error('There was a problem with the fetch operation:', error);
    });
  });
  document.querySelector('#settingEventModal').addEventListener('hidden.bs.modal', function () {
    document.querySelector('#modal-content').innerHTML = originalContent;
  });
});
