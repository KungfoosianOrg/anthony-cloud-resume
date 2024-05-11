const VIEWPORT_SM_BREAKPOINT = 576; // pixels

// SECTION - "Back to Top" button
const backToTopBtn = document.getElementById('btn-backToTop');

document.addEventListener('scroll', () => {
    // shows the "back to top" button when user scroll past 250px
    if (window.scrollY > 250) {
        backToTopBtn.classList.remove('d-none');
        backToTopBtn.classList.add('d-block');

        return;
    }



    // hides the "back to top" button
    backToTopBtn.classList.remove('d-block');
    backToTopBtn.classList.add('d-none');
    return;
})

// scroll to top when click button
backToTopBtn.addEventListener('click', () => {
    window.scrollTo({
        top: 0,
        left: 0,
        behavior: 'smooth'
    })
})

// END SECTION


// SECTION - Sticky page nav when scroll
const pageNavList = document.getElementById('pageNavList');


const pageNav = document.getElementById('pageNav');
// const pageNavHeight = pageNav.getBoundingClientRect().y;


const contentContainer = document.getElementById('content-container');
let currentContentContainerPaddingTop = window.getComputedStyle(contentContainer, null).getPropertyValue('padding-top');



// Get main navbar height
const mainNavbarBounds = document.getElementById('main-nav').getBoundingClientRect();
const mainNavbarHeight = mainNavbarBounds.bottom - mainNavbarBounds.y;


document.addEventListener('scroll', () => {
    // unstick navbar if current scroll position is less than main navbar height
    if (window.scrollY < mainNavbarHeight) {
        pageNav.classList.remove('sticky');
        pageNavList.classList.remove('sticky');
        
        return;
    }

    
    // for users on small screen
    if (window.innerWidth < VIEWPORT_SM_BREAKPOINT) {
        pageNav.classList.add('sticky');

        return;
    }

    // for users on big screen
    pageNavList.classList.add('sticky');    

    return;
})


// END SECTION  