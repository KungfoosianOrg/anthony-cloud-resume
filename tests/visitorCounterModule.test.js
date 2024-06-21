const visitorCounterModule = require('../github/scripts/visitorCounterModule.js');
const makeApiCall = visitorCounterModule.makeApiCall;
const createVisitorCounter = visitorCounterModule.createVisitorCounter;
const createVisitorCounterWrapper = visitorCounterModule.createVisitorCounterWrapper;


// Overriding fetch for test
global.fetch = jest.fn(() => {
    return Promise.resolve({
        json: () => Promise.resolve({ timesVisited: '42069' })
    })
});

describe('Test API response from API GW connected DynamoDB, should get back { timesVisited: <string of number> }', () => {  
    let response;
    
    beforeAll(() => {
        makeApiCall('testurl.tld','')
            .then(res => response = res)
    })

    it('rejects if no argument is passed in', () => {
        makeApiCall()
            .then(response => expect(response).toBe(null))
    })
    
    it('should return JSON object from the API call and have timesVisited in response object', () => {
        expect(typeof(response)).toBe('object');
    })

    it('should contain timesVisited entry in response', () => {
        expect(Object.keys(response).includes('timesVisited')).toBe(true)
    })

    test('timesVisited entry in the response to be a string', () => {
        expect(typeof(response.timesVisited)).toBe('string')
    })
})


describe('Test creation of DOM element', () => {
    it('returns null if no ID of div container element passed', () => {
        expect(createVisitorCounter()).toBe('Must define id of element to add this module to')
        expect(createVisitorCounterWrapper()).toBe(null)
    })
    
    it('returns null if no API URL and/or API method passed', () => {
        expect(createVisitorCounter('test-wrapper-element-id')).toBe('Must define API URL and method')
        expect(createVisitorCounter('test-wrapper-element-id',null,'POST')).toBe('Must define API URL and method')
        expect(createVisitorCounter('test-wrapper-element-id','randomurl.tld',null)).toBe('Must define API URL and method')
    })
})