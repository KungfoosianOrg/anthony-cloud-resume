const enableBootstrapPopper = () => {
  const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]')
  const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl))
}


const createLoadingSpinner = () => {
  let spinnerElement = document.createElement('div');
  spinnerElement.classList.add('spinner-grow', 'spinner-grow-sm');
  spinnerElement.role = 'status';

  let spinnerText = document.createElement('span');
  spinnerText.classList.add('visually-hidden');
  spinnerText.innerText = 'Loading...'

  spinnerElement.appendChild(spinnerText);

  return spinnerElement;
}


const createLocationIcon = () => {
  let myElementSvg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
  myElementSvg.classList.add('bi', 'bi-geo-alt-fill', 'flex-shrink-0', 'me-2');
  myElementSvg.setAttribute('viewBox', '0 0 16 16');
  myElementSvg.role = 'img';
  myElementSvg.setAttribute('aria-label', 'Times visited:');
  myElementSvg.classList.add('icon')

  let svgPath1 = document.createElementNS("http://www.w3.org/2000/svg", 'path');
  svgPath1.setAttribute('d', 'M12.166 8.94c-.524 1.062-1.234 2.12-1.96 3.07A32 32 0 0 1 8 14.58a32 32 0 0 1-2.206-2.57c-.726-.95-1.436-2.008-1.96-3.07C3.304 7.867 3 6.862 3 6a5 5 0 0 1 10 0c0 .862-.305 1.867-.834 2.94M8 16s6-5.686 6-10A6 6 0 0 0 2 6c0 4.314 6 10 6 10');
  svgPath1.setAttribute('fill', 'white');

  let svgPath2 = document.createElementNS("http://www.w3.org/2000/svg", 'path');
  svgPath2.setAttribute('d', 'M8 8a2 2 0 1 1 0-4 2 2 0 0 1 0 4m0 1a3 3 0 1 0 0-6 3 3 0 0 0 0 6');
  svgPath2.setAttribute('fill', 'white');

  myElementSvg.appendChild(svgPath1);
  myElementSvg.appendChild(svgPath2);

  return myElementSvg;
}


const createVisitorCounterWrapper = (appendToElementId=null) => {
  if (appendToElementId === null) {
    console.error('Must define id of element to add this module to');
    
    return null;
  }

  let elementWrapper = document.getElementById(appendToElementId);
  elementWrapper.classList.add('d-flex', 'align-items-center')

  // add message on hover
  elementWrapper.setAttribute('data-bs-toggle', 'tooltip');
  elementWrapper.setAttribute('data-bs-title', 'The amount of times this page has been visited');

  const visitorIconSvg = createLocationIcon();

  elementWrapper.appendChild(visitorIconSvg);

  return elementWrapper
}


const createVisitorCountTextElement = () => {
  let visitorCountText = document.createElement('div');
  visitorCountText.classList.add('text-white');

  return visitorCountText
}


async function makeApiCall(url=null, method='GET') {
  try {
    if (!url) throw new Error('must define url');

    const response = await fetch(url, { method: method })

    let json = await response.json();
    

    return json;

  } catch (error) {
    console.error('Something went wrong: ' + error);

    return null;
  }
}


async function updateVisitorCounter(ApiUrl=null, method=null) {
  try {
    if (!ApiUrl || !method) throw new Error('must define API URL and method')

    let response = await makeApiCall(ApiUrl, method);
    
    return new Promise(resolve => resolve(response))

  } catch (error) {
    console.error('Something went wrong: ' + error);

    return null;
  }
}

/**
 * 
 * @param {string} appendToElementId - ID of div element that you want to attach this module to
 * @returns
 */

function createVisitorCounter(appendToElementId=null, ApiUrl=null, ApiMethod=null) {
  if (appendToElementId === null) return 'Must define id of element to add this module to';


  if (!ApiUrl || !ApiMethod) return 'Must define API URL and method';

  enableBootstrapPopper();

  const elementWrapper = createVisitorCounterWrapper(appendToElementId);

  const visitorCountTextElement = createVisitorCountTextElement();

  elementWrapper.appendChild(visitorCountTextElement);

  const spinnerElement = createLoadingSpinner();


  // SECTION - DATA SECTION
  let dataIsLoaded = false;


  // Asynchronously doing an API call 
  let visitorCount = updateVisitorCounter(ApiUrl, ApiMethod);

  if (!dataIsLoaded) visitorCountTextElement.appendChild(spinnerElement);

  visitorCount
    .then(data => {
      // display visitor counter result after async call
      document.dispatchEvent(new CustomEvent('reload-visitor-counter', { detail: data }));
    })


  document.addEventListener('reload-visitor-counter', event => {
    visitorCountTextElement.removeChild(spinnerElement);

    visitorCountTextElement.innerText = event.detail.timesVisited;
  })
}


window.addEventListener('DOMContentLoaded', () => {
  createVisitorCounter('visitorCounter-container','https://izsr45o8g5.execute-api.us-west-1.amazonaws.com/default/visitor-count','POST')
})


var module = module || {};

module.exports = {
  createVisitorCounter,
  createVisitorCounterWrapper,
  makeApiCall
};