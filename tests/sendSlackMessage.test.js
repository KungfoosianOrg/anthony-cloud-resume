const sendSlackMessage = require('../aws/sendSlackMessage/lambda_function.js');
const handler = sendSlackMessage.handler;

const { mockClient } = require('aws-sdk-client-mock');

// Overriding fetch for test
global.fetch = jest.fn(() => {
    return Promise.resolve({
        json: () => Promise.resolve({ status: 200 })
    })
});

describe('test with correct event initiator', () => {
    let testEvent = {
        "Records": [
          {
            "EventSource": "aws:sns",
            "Sns": {
              "Type": "Notification",
              "TopicArn": "arn:aws:sns:aws_region:account_id:test_send_slack_message",
            }
          }
        ]
    }

    it('should return "Status code: 200"', async () => {
        expect(await handler(testEvent)).toBe('Status code: 200')
    })
})




// describe('test with incorrect event initiator')