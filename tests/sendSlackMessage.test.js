const sendSlackMessage = require('../aws/sendSlackMessage/lambda_function.js');
const handler = sendSlackMessage.handler;

// TODO https://stackoverflow.com/questions/56821395/jest-mock-with-promise-again

// const { SSMClient, GetParameterCommand } = require('@aws-sdk/client-ssm')
// const { AWS } = require('aws-sdk');

// const { mockClient } = require('aws-sdk-client-mock')

// Overriding fetch for test
global.fetch = jest.fn(() => {
    return Promise.resolve({
        json: () => Promise.resolve({ status: 200 })
    })
});

// mocking out the AWS SSM API
// jest.mock('../aws/sendSlackMessage/node_modules/@aws-sdk/client-ssm', () => ({
//   SSMClient: jest.fn(() => ({
//     send: jest.fn((command, callback) => {
//       callback(null, {
//         Parameters: [
//           {
//             Name: '/SLACK_WEBHOOK_URL',
//             Value: 'testwebhookurl.tld/blabla',
//           },
//         ],
//       });
//     }),
//   })),
//   GetParametersCommand: jest.fn(),
// }));



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