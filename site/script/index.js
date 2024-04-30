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
const pageNavHeight = pageNav.getBoundingClientRect().y;


const contentContainer = document.getElementById('content-container');
let currentContentContainerPaddingTop = window.getComputedStyle(contentContainer, null).getPropertyValue('padding-top');



// Get main navbar height
const mainNavbarBounds = document.getElementById('main-nav').getBoundingClientRect();
const mainNavbarHeight = mainNavbarBounds.bottom - mainNavbarBounds.y;

// section - create dynamic padding style
let cssDynamicPadding = `dynamicPadding { padding-left: 0px !important }`,
    head = document.head || document.getElementsByTagName('head')[0],
    styleDynamicPadding = document.createElement('style');

head.appendChild(styleDynamicPadding);

styleDynamicPadding.setAttribute('type', 'text/css')
if (styleDynamicPadding.styleSheet) {
    // This is required for IE8 and below.
    styleDynamicPadding.styleSheet.cssText = css;
} else {
    styleDynamicPadding.appendChild(document.createTextNode(css));
}
// END section

document.addEventListener('scroll', () => {
    isNaN(currentContentContainerPaddingTop) ? currentContentContainerPaddingTop = 0 : '';

    // unstick navbar if scroll height is less than main navbar height
    if (window.scrollY < mainNavbarHeight) {
        unstickPageNav();
        
        return;
    }

    

    // for users on small screen
    // set padding of content container to height of page navbar and set sticky on the page navbar
    if (window.innerWidth < VIEWPORT_SM_BREAKPOINT) {
        pageNav.classList.add('sticky');

        return;
    }

    // for users on big screen, make page navbar stick to top of screen when scroll past main navbar height
    // add pageNavList width to left padding of content-container when sticky is enabled
    pageNavList.classList.add('sticky');    

    // add pageNav width to left padding of content-container when sticky is enabled
    let pageNavWidth = pageNav.getBoundingClientRect().right;

    let currentContentContainerPaddingLeft = window.getComputedStyle(contentContainer, null).getPropertyValue('padding-left');

    contentContainer.setAttribute('style', `padding-left: ${currentContentContainerPaddingLeft + pageNavWidth}px !important`)

    return;
})

function unstickPageNav() {
    contentContainer.setAttribute('style', `padding-top: ${currentContentContainerPaddingTop === 0 ? '0 px;' : `${currentContentContainerPaddingTop - pageNavHeight} px !important;`}`)

    pageNav.classList.remove('sticky');


    pageNavList.classList.remove('sticky'); 
}


// END SECTION  