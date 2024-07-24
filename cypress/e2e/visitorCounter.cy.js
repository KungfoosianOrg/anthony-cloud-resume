/// <reference types="cypress" />

const getCounterValue = () => {
    // wait 3 seconds for counter to load
    cy.wait(3000)

    cy.get('#visitorCounter-container > div.text-white').then(element => {
        return parseInt(element['0'].textContent)
    })
}

describe('E2E test for visitor counter component', () => {
    beforeEach(() => {
        cy.visit('https://www.vocloudresume.click')
    })

    it('should load the component', () => {
        cy.get('#visitorCounter-container').should('exist')
    })

    it('The counter text element should increase after page reload (1 time)', () => {
        // // wait 3 seconds for counter to load
        cy.wait(3000)
        
        

        cy.get('#visitorCounter-container > div.text-white').then(element => {
            let currentCounterValue = parseInt(element['0'].textContent);
            
            // reload the page and check if counter increases
            cy.reload()

            cy.get('#visitorCounter-container > div.text-white').then(element => {
                let newCounterValue = parseInt(element.textContent)

                expect(newCounterValue).greaterThan(currentCounterValue)
            })
        })


        // intercepts and listen to the http resquest

        // cy.wait('@updateVisitorCounter').its('response.statusCode').should('be.oneOf', [200])
    })
})