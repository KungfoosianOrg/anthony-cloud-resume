from unittest import TestCase
from moto import mock_aws
from boto3 import client
import json
import urllib.request


from aws.sendSlackMessage.lambda_function import lambda_handler

class TestLambdaHandlerFunction(TestCase):
    def setUp(self):
        self.mock_aws = mock_aws()
        self.mock_aws.start()

        self.default_http_response = {
            'statusCode': 200,
            'body': 'request processed'
        }

        self.slack_response_success = {
            'statusCode': 200,
            'body': 'ok'
        }

        # Create SSM client and add the SLACK_WEBHOOK SecureString parameter, simulating process of creating the SecureString parameter in AWS Systems Manager
        self.ssm = client('ssm', region_name='us-east-1')
        self.ssm.put_parameter(
            Name='/SLACK_WEBHOOK',
            Description='example slack webhook for testing',
            Value='https://hooks.slack.com/services/TEST/SLACK/w3bH0OKurL',
            Type='SecureString'
        )


        return
    
    def tearDown(self):
        self.mock_aws.stop()
    
    def test_correct_event_initiator(self):
        """
            test with SNS as the event initiator

            expected: JSON object { statusCode: 200, body: 'ok' }
        """

        mock_event = {
            "Records": [
                {
                    "EventSource": "aws:sns",
                    "EventVersion": "1.0",
                    "Sns": {
                        "Type": "Notification",
                        "TopicArn": "arn:aws:sns:aws-region:aws-account-id:TestAlarmTopicForSlackIntegration",
                        "Subject": "None",
                        "Message": "test alarm"
                    }
                }
            ]
        }

        self.assertEqual(lambda_handler(event=mock_event, context=None), self.slack_response_success)
        

    def test_incorrect_event_initiator(self):
        """
            test with anything else but SNS as the event initiator, this instance uses an API gateway event from the visitorCounter test

            expected: JSON object { statusCode: 200, body: 'request processed' }
        """
        mock_event = {
            "rawPath": "/visitor-counter",
            "requestContext": {
                "http": {
                    "method": "GET"
                }
            }
        }


        self.assertEqual(lambda_handler(event=mock_event, context=None), self.default_http_response)