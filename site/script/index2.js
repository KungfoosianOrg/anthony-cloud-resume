console.log('hi')

const VIEWPORT_SM_BREAKPOINT = 576; // pixels

const backToTopBtn = document.getElementById('btn-backToTop');


document.addEventListener('scroll', () => {
    // shows the "back to top" button when user scroll past 250px
    if (window.scrollY > 250) {
        backToTopBtn.classList.remove('d-none');
        backToTopBtn.classList.add('d-block');

        return
    }



    // hides the "back to top" button
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

// END SECTION


// Sticky page nav when scrolled past
const pageNav = document.getElementById('pageNav');

const pageNavHeight = pageNav.getBoundingClientRect().y;


const contentContainer = document.getElementById('content-container');

let currentContentContainerPaddingTop = window.getComputedStyle(contentContainer, null).getPropertyValue('padding-top');


document.addEventListener('scroll', () => {
    if (typeof(currentContentContainerPaddingTop) !== 'number') {
        currentContentContainerPaddingTop = 0;
    }

    let mainNavbarBounds = document.getElementById('main-nav').getBoundingClientRect();

    let mainNavbarHeight = mainNavbarBounds.bottom - mainNavbarBounds.y;

    // if user on small screen and if user scrolled past main navbar height, set padding of content container to height of page navbar and set sticky on the page navbar
    if (window.innerWidth < VIEWPORT_SM_BREAKPOINT) {
        if ( window.scrollY >= mainNavbarHeight ) {
            pageNav.classList.add('sticky');
    
            // add top padding to content-container when sticky is enabled
            contentContainer.setAttribute('style', `padding-top: ${currentContentContainerPaddingTop + pageNavHeight}px !important`)
        }
         else {
            unstickPageNav();
        }

        return
    }

    unstickPageNav();

    
    return
})

function unstickPageNav() {
    contentContainer.setAttribute('style', `padding-top: ${currentContentContainerPaddingTop === 0 ? 0 : currentContentContainerPaddingTop - pageNavHeight}px !important`)

    pageNav.classList.remove('sticky');
}