document.addEventListener('DOMContentLoaded', function() {
  const modalContent = document.querySelector('#modal-content');
  const settingEventModal = document.querySelector('#settingEventModal');
  const originalContent = modalContent.innerHTML;
  const contentContainer = document.querySelector('#content-container');

  function loadContent(url, targetElement, updateURL, callback) {
    fetch(url, {
      method: 'GET',
      headers: {
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => {
      if (!response.ok) {
        throw new Error('Network response was not ok.');
      }
      return response.text();
    })
    .then(html => {
      console.log('Loaded HTML:', html);
      targetElement.innerHTML = html;
      if (updateURL) {
        history.pushState(null, '', url);
      }
      if (callback) callback();
    })
    .catch(error => {
      console.error('There was a problem with the fetch operation:', error);
    });
  }

  function attachLinkListeners() {
    const links = document.querySelectorAll('.async-link');

    links.forEach(link => {
      link.addEventListener('click', function(event) {
        event.preventDefault();
        const url = this.getAttribute('href');
        const targetId = this.getAttribute('data-target');
        const targetElement = document.getElementById(targetId);
        const updateURL = targetId === 'content-container';

        loadContent(url, targetElement, updateURL, function() {
          if (targetId === 'modal-content') {
            const modal = new bootstrap.Modal(settingEventModal);
            modal.show();
          }
        });
      });
    });
  }

  function attachPrivacyPolicyListener() {
    const termsLink = document.getElementById('terms-link');
    const privacyPolicyLink = document.getElementById('privacy-policy-link');
    
    if (termsLink) {
      termsLink.addEventListener('click', function(event) {
        event.preventDefault();
        loadContent('/staticpages/terms', modalContent, false, attachPrivacyPolicyListener);
      });
    }

    if (privacyPolicyLink) {
      privacyPolicyLink.addEventListener('click', function(event) {
        event.preventDefault();
        loadContent('/staticpages/privacy_policy', modalContent, false, attachPrivacyPolicyListener);
      });
    }
  }

  attachPrivacyPolicyListener();
  attachLinkListeners();

  if (settingEventModal) {
    settingEventModal.addEventListener('hidden.bs.modal', function () {
      modalContent.innerHTML = originalContent;
      attachPrivacyPolicyListener();
    });
  }


  window.addEventListener('popstate', function(event) {
    const currentURL = window.location.pathname;
    console.log('Popstate event fired:', currentURL);
    const asyncLink = document.querySelector(`.async-link[href="${currentURL}"]`);
    if (asyncLink) {
      const targetId = asyncLink.getAttribute('data-target');
      const targetElement = document.getElementById(targetId);
      loadContent(currentURL, targetElement, false);
    }
  });
});
