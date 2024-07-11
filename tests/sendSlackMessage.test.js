jest.mock('../__mocks__/aws-sdk')
const { aws } = require('aws-sdk');

const sendSlackMessage = require('../aws/sendSlackMessage/lambda_function.js');
const handler = sendSlackMessage.handler;

// const { SSMClient, GetParameterCommand } = require('@aws-sdk/client-ssm')


// const { mockClient } = require('aws-sdk-client-mock')


// Overriding fetch for test via stubbing with jest.fn()
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

  console.log(aws)

  it('should return "Status code: 200"', async () => {
    let result = await handler(testEvent)

    // secretsManager.describeSecret = jest.fn().mockImplementationOnce(() => {
    //   Promise.resolve("test-values")
    // })

    console.log(result)

    expect(result).toBe('Status code: 200')
  })
})




// describe('test with incorrect event initiator')