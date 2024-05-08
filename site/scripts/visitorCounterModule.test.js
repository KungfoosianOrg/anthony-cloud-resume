const visitorCounterModule = require('./visitorCounterModule.js')
const makeApiCall = visitorCounterModule.makeApiCall


// Overriding fetch for test
global.fetch = jest.fn(() => {
    return Promise.resolve({
        json: () => Promise.resolve({ timesVisited: '42069' })
    })
});

describe('test API response from API GW connected DynamoDB, should get back { timesVisited: <string of number> }', () => {  
    let response;
    
    beforeAll(() => {
        makeApiCall('','')
            .then(res => response = res)
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