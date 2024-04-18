console.log('hi')

// shows "back to top" button if scrolled past
const backToTopBtn = document.getElementById('btn-backToTop');


document.addEventListener('scroll', () => {
    if (window.scrollY > 250) {
        // shows the button
        backToTopBtn.classList.remove('d-none');
        backToTopBtn.classList.add('d-block');

        return
    }

    // hides the button
    backToTopBtn.classList.remove('d-block');
    backToTopBtn.classList.add('d-none');
    return
})


backToTopBtn.addEventListener('click', () => {
    window.scrollTo({
        top: 0,
        left: 0,
        behavior: 'smooth'
    })
})