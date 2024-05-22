document.addEventListener('DOMContentLoaded', function() {
  const deleteButtons = document.querySelectorAll('.delete-reminder-button');

  deleteButtons.forEach(button => {
    button.addEventListener('click', function(event) {
      event.preventDefault();
      const reminderId = this.getAttribute('data-reminder-id');
      const url = `/reminder_lists/${reminderId}/deactivate`;
      console.log(`Deleting reminder with ID: ${reminderId}`);
      console.log(`Request URL: ${url}`);

      fetch(url, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        body: JSON.stringify({ is_active: false })
      })
      .then(response => {
        if (response.ok) {
          document.getElementById(`reminder-${reminderId}`).remove();
        } else {
          console.error('Failed to delete reminder');
        }
      })
      .catch(error => {
        console.error('Error:', error);
      });
    });
  });
});
