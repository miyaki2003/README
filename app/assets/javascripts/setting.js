document.addEventListener('DOMContentLoaded', function() {
  const modalContent = document.querySelector('#modal-content');
  const settingEventModal = document.querySelector('#settingEventModal');
  const originalContent = modalContent.innerHTML;

  async function fetchData(url) {
    const response = await fetch(url, {
      method: 'GET',
      headers: {
        'X-Requested-With': 'XMLHttpRequest'
      }
    });
    if (!response.ok) {
      throw new Error('Network response was not ok.');
    }
    return response;
  }

  async function loadContent(link, container) {
    try {
      const response = await fetchData(link);
      if (link === '/') {
        const html = await response.text();
        container.innerHTML = html;
      } else {
        const data = await response.json();
        container.innerHTML = data.html;
      }
      attachLinkListeners();
    } catch (error) {
      console.error('There was a problem with the fetch operation:', error);
    }
  }

  function attachLinkListeners() {
    const termsLink = document.getElementById('terms-link');
    const privacyPolicyLink = document.getElementById('privacy-policy-link');
    const topLink = document.getElementById('top-link');

    if (termsLink) {
      termsLink.addEventListener('click', function(event) {
        event.preventDefault();
        loadContent('/staticpages/terms', modalContent);
      });
    }

    if (privacyPolicyLink) {
      privacyPolicyLink.addEventListener('click', function(event) {
        event.preventDefault();
        loadContent('/staticpages/privacy_policy', modalContent);
      });
    }

    if (topLink) {
      topLink.addEventListener('click', function(event) {
        event.preventDefault();
        loadContent('/', document.getElementById('main-content'));
        const bootstrapModal = bootstrap.Modal.getInstance(settingEventModal);
        bootstrapModal.hide();
        history.pushState(null, null, '/');
      });
    }
  }

  attachLinkListeners();

  if (settingEventModal) {
    settingEventModal.addEventListener('hidden.bs.modal', function () {
      modalContent.innerHTML = originalContent;
      attachLinkListeners();
    });
  }
});
