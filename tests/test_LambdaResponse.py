from unittest import TestCase

from back_end.LambdaResponse import LambdaResponse


def TestLambdaResponseClass(TestCase):
    def test_lambda_response(self):
        test_response = LambdaResponse(response={
                                                'statusCode': 418,
                                                'body': 'this is a test'
                                                })
        
        self.assertEqual(test_response.json, {
                                               'statusCode': 418,
                                               'body': 'this is a test'     
                                                })
    
