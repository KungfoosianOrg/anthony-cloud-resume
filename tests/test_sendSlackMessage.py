from moto import mock_aws
import unittest

import json
import boto3
import urllib3
import os


_REGION_DEFAULT = 'the-basement'

_RESPONSE_DEFAULT = {
    'statusCode': 200,
    'body': 'request processed'
}

# Calls decorators to mock AWS and environment variables for use in test case
@mock_aws
@unittest.mock.patch.dict(os.environ, { 'AWS_REGION': _REGION_DEFAULT })
class TestSendSlackMessage(unittest.TestCase):
    
    def setUp(self):
        ssm = boto3.client('ssm', region_name=_REGION_DEFAULT)

    def test_lambda_handler_no_initiator_event_source(self):
        """
            Test for events with wrong event source
        """

        # importing the code in test after injecting the environment variable
        from aws.sendSlackMessage.lambda_function import lambda_handler

        test_event = {
            "Records": [
                {
                    "EventVersion": "2.0",
                    "eventsource": "aws:s3",
                    "AwsRegion": "us-east-1"
                }
            ]
        }

        self.assertEqual(lambda_handler(event=test_event, context=None), _RESPONSE_DEFAULT)
        # self.assertRaises(Exception, lambda_handler(event=test_event, context=None))

        return
    
    def test_lambda_handler_correct_initiator(self):
        return