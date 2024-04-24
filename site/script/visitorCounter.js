// DISPLAY VISITOR COUNTER IN MAIN NAVBAR

// SECTION - DUMMY DATA, DELETE WHEN DONE
let timesVisited = 100;
// END SECTION



const elementWrapper = document.getElementById('visitorCounter-container');
elementWrapper.classList.add('d-flex', 'align-items-center')

// add message on hover
elementWrapper.setAttribute('data-bs-toggle', 'tooltip');
elementWrapper.setAttribute('data-bs-title', 'The amount of times this page has been visited');



// Create the element and insert into wrapper
// SECTION - Svg icon
let myElementSvg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
myElementSvg.classList.add('bi', 'bi-geo-alt-fill', 'flex-shrink-0', 'me-2');
myElementSvg.setAttribute('viewBox', '0 0 16 16');
myElementSvg.role = 'img';
myElementSvg.setAttribute('aria-label', 'Times visited:');
myElementSvg.classList.add('icon');

let svgPath1 = document.createElementNS("http://www.w3.org/2000/svg", 'path');
svgPath1.setAttribute('d', 'M12.166 8.94c-.524 1.062-1.234 2.12-1.96 3.07A32 32 0 0 1 8 14.58a32 32 0 0 1-2.206-2.57c-.726-.95-1.436-2.008-1.96-3.07C3.304 7.867 3 6.862 3 6a5 5 0 0 1 10 0c0 .862-.305 1.867-.834 2.94M8 16s6-5.686 6-10A6 6 0 0 0 2 6c0 4.314 6 10 6 10');
svgPath1.setAttribute('fill', 'white');

let svgPath2 = document.createElementNS("http://www.w3.org/2000/svg", 'path');
svgPath2.setAttribute('d', 'M8 8a2 2 0 1 1 0-4 2 2 0 0 1 0 4m0 1a3 3 0 1 0 0-6 3 3 0 0 0 0 6');
svgPath2.setAttribute('fill', 'white');

myElementSvg.appendChild(svgPath1);
myElementSvg.appendChild(svgPath2);
// END SECTION

// SECTION - Text
let myElementText = document.createElement('div');
myElementText.classList.add('text-white');
// END SECTION


elementWrapper.appendChild(myElementSvg);
elementWrapper.appendChild(myElementText);


// SECTION - enable popper
const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]')
const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl))
// End section


// SECTION - DATA SECTION
let dataIsLoaded = false;


// Asynchronously doing an API call and display result
let spinnerElement = document.createElement('div');
spinnerElement.classList.add('spinner-grow', 'spinner-grow-sm');
spinnerElement.role = 'status';

let spinnerText = document.createElement('span');
spinnerText.classList.add('visually-hidden');
spinnerText.innerText = 'Loading...'

spinnerElement.appendChild(spinnerText);

if (!dataIsLoaded) {
  // display spinner
  myElementText.appendChild(spinnerElement);
}


fetch('https://izsr45o8g5.execute-api.us-west-1.amazonaws.com/default/visitor-count', { method: 'POST' })
  .then(response => response.json())
  .then(data => {
    myElementText.removeChild(spinnerElement);

    myElementText.innerText = data.timesVisited;
  })
  .catch(err => console.error(`Couldn't fetch data: ${err}`))


// END SECTION
