// const sendSlackMessage = require('../aws/sendSlackMessage/lambda_function.mjs');
// const handler = sendSlackMessage.handler;

// TODO: https://dev.to/steveruizok/jest-and-esm-cannot-use-import-statement-outside-a-module-4mmj

import { handler } from "../aws/sendSlackMessage/lambda_function.mjs";

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

    it('should return "Status code: 200"', () => {
        expect(handler(testEvent)).toBe('Status code: 200')
    })
})




describe('test with incorrect event initiator')