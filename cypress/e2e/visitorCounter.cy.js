/// <reference types="cypress" />

describe('E2E test for visitor counter component', () => {
    it('should load the component', () => {
        cy.visit('https://www.vocloudresume.click')

        cy.get('#visitorCounter-container').should('exist')
    })


    it('The counter text element should increase after page reload (1 time)', () => {
        cy.getCounter('https://www.vocloudresume.click').as('currentCounter')


        cy.getCounter('https://www.vocloudresume.click').as('newCounter')
        

        cy.get('@currentCounter').then(currentCounter => {
            cy.get('@newCounter').then(newCounter => {
                expect(newCounter).greaterThan(currentCounter)
            })

        })
    })
})