from moto import mock_aws
import unittest

import json
import boto3
import os


_REGION_DEFAULT = 'us-east-1'

_RESPONSE_SUCCESS = { 
    'statusCode': 200,
    'body': 'ok'
}

# Calls decorators to mock AWS and environment variables for use in test case
@mock_aws
@unittest.mock.patch.dict(os.environ, { 'AWS_REGION': _REGION_DEFAULT })
class TestSendSlackMessage(unittest.TestCase):
    
    def setUp(self):
        # sets up parameter in SSM, for use throughout all tests, state is not shared between tests
        ssm = boto3.client('ssm', region_name=_REGION_DEFAULT)
        ssm.put_parameter(
            Name='/SLACK_WEBHOOK_URL',
            Description='Mocked SSM mocked request parameter for unittest',
            Value='test.slackwebhook.url',
            Type='SecureString'
        )

    def test_lambda_handler_incorrect_initiator_event_source(self):
        """
            Test for events with wrong event source
        """
        print('testing for incorrect initiator event source')
        # importing the code in test after injecting the environment variable
        from aws.sendSlackMessage.lambda_function import lambda_handler

        test_event = {
            "Records": [
                {
                    "EventVersion": "2.0",
                    "EventSource": "aws:s3",
                    "AwsRegion": "us-east-1"
                }
            ]
        }

        self.assertRaises(Exception, lambda_handler(event=test_event, context=None))
        return
    
    # mock urllib3 http connection pool manager
    @unittest.mock.patch('urllib3.PoolManager')
    def test_lambda_handler_correct_initiator(self, mock_PoolManager):
        from aws.sendSlackMessage.lambda_function import lambda_handler

        # creating an HTTPResponse class since urllib3.PoolManager().request() expects a return variable of class HTTPResponse
        class HTTPResponse:
            def __init__(self, status):
                self.status = status

        print('testing for correct initiator event source')


        test_event = {
            "Records": [
                {
                    "EventSource": "aws:sns",
                    "EventVersion": "1.0",
                    "EventSubscriptionArn": "arn:aws:sns:us-east-1::ExampleTopic",
                    "Sns": {
                        "Type": "Notification",
                        "MessageId": "95df01b4-ee98-5cb9-9903-4c221d41eb5e",
                        "TopicArn": "arn:aws:sns:us-east-1:123456789012:ExampleTopic"
                    }
                }
            ]
        }

        # overriding the urllib3 PoolManager().request() response with the HTTPResponse custom class, since the actual code expects a HTTPResponse class with status attribute
        mock_PoolManager().request.return_value = HTTPResponse(200)


        self.assertEqual(lambda_handler(event=test_event, context=None), json.dumps(_RESPONSE_SUCCESS))

        return