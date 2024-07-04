from unittest import TestCase

from aws.visitorCounter.LambdaResponse import LambdaResponse


class TestLambdaResponseClass(TestCase):
    def test_lambda_response(self):
        mock_response = {
                            'statusCode': 418,
                            'body': 'this is a test'
                        }

        test_response = LambdaResponse(response=mock_response)
        
        self.assertEqual(test_response.json, mock_response)
