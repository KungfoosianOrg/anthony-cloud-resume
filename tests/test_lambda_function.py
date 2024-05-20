from unittest import TestCase
from boto3 import client
from moto import mock_aws

from back_end.lambda_function import lambda_handler




class TestLambdaHandlerFunction(TestCase):
    def setUp(self):
        self.mock_aws = mock_aws()
        self.mock_aws.start()
        self.default_http_response = {
                                        'statusCode': 200,
                                        'body': 'request processed'
                                    }


    def tearDown(self) -> None:
        self.mock_aws.stop()

    def test_lambda_handler_wrong_path(self):
        """test  wrong path"""
        mock_event = {
                        "resource": "/path-does-not-exist",
                        "httpMethod": "POST"
                    }
        
        self.assertEqual(lambda_handler(event=mock_event), self.default_http_response)
        
    def test_lambda_handler_wrong_method(self):
        """test wrong method"""
        mock_event = {
                        "resource": "/visitor-counter",
                        "httpMethod": "GET"
                    }
        
        self.assertEqual(lambda_handler(event=mock_event), self.default_http_response)




    """test correct path & method with  counter less than 100"""

    """test corrrect path & method with counter over 100"""