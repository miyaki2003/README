document.addEventListener('DOMContentLoaded', function() {
  document.getElementById('calendar-button').addEventListener('click', function() {
    fetch('/events', {
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
      document.open();
      document.write(html);
      document.close();
    })
    .catch(error => {
      console.error('There was a problem with the fetch operation:', error);
    });
  });
});
