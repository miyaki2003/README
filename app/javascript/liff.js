import liff from '@line/liff';

document.addEventListener('DOMContentLoaded', function() {
    initializeLiff();
});

function initializeLiff() {
    liff.init({
        liffId: '2003779201-OwqpG72P',
        withLoginOnExternalBrowser: true
    }).then(() => {
        if (!liff.isLoggedIn()) {
            liff.login();
        } else {
            handleLoggedInUser();
        }
    }).catch((err) => {
        console.error('LIFF Initialization failed', err);
    });
}

function handleLoggedInUser() {
    const idToken = liff.getIDToken();
    console.log('ID Token:', idToken);
}
