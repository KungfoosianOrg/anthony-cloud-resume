// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
// Cypress.Commands.add('login', (email, password) => { ... })
//
//
// -- This is a child command --
// Cypress.Commands.add('drag', { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add('dismiss', { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This will overwrite an existing command --
// Cypress.Commands.overwrite('visit', (originalFn, url, options) => { ... })


Cypress.Commands.add('getCounter', (url) => {
    try {
        cy.visit(url)
    
        // wait 3 seconds for counter to load
        cy.wait(3000)
        
        cy.get('#visitorCounter-container > div.text-white')
          .then(element => {
            return parseInt(element['0'].textContent)
          })
    } catch (error) {
        console.error(`Something went wrong while using Cypress: ${error}`)
    }
})