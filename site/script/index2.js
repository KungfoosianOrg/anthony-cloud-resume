console.log('hi')

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

const pageNavBounds = pageNav.getBoundingClientRect();

const pageNavHeight = pageNavBounds.y;

console.log(pageNavBounds);

const contentContainer = document.getElementById('content-container');

// console.log(window.getComputedStyle(contentContainer, null).getPropertyValue('padding-top'));

document.addEventListener('scroll', () => {
    let currentContentContainerPaddingTop = window.getComputedStyle(contentContainer, null).getPropertyValue('padding-top');

    if (typeof(currentContentContainerPaddingTop) !== 'number') {
        currentContentContainerPaddingTop = 0;
    }

    if ( window.scrollY >= pageNavHeight ) {
        pageNav.classList.add('sticky');

        // add top padding to content-container when sticky is enabled
        contentContainer.setAttribute('style', `padding-top: ${currentContentContainerPaddingTop + pageNavHeight}px !important`)

        return;
    }


    contentContainer.setAttribute('style', `padding-top: ${currentContentContainerPaddingTop - pageNavHeight}px !important`)
    pageNav.classList.remove('sticky');
    return;
})
