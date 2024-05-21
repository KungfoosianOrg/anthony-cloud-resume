from unittest import TestCase, mock
from boto3 import client
from moto import mock_aws
# from os import environ
import os

from back_end.lambda_function import lambda_handler
from back_end.DDBVisitorCounter import DDBVisitorCounter

class TestLambdaHandlerFunction(TestCase):
    def setUp(self):
        self.mock_aws = mock_aws()
        self.mock_aws.start()

        self.default_http_response = {
                                        'statusCode': 200,
                                        'body': 'request processed'
                                    }
        
        # sets up a mock dynamoDB table to test API calls to AWS
        self.mock_ddb_table_name = 'mock-ddb-table'
        os.environ['DDB_TABLE_ARN'] = self.mock_ddb_table_name
        

        dynamodb = client('dynamodb', region_name='us-west-1')

        dynamodb.create_table(
                                    AttributeDefinitions = [
                                                                {
                                                                    'AttributeName': 'id',
                                                                    'AttributeType': 'S'
                                                                }
                                                            ],
                                    TableName = self.mock_ddb_table_name,
                                    BillingMode = 'PAY_PER_REQUEST',
                                    KeySchema = [
                                                    {
                                                        'AttributeName': 'id',
                                                        'KeyType': 'HASH'
                                                    }
                                                ]
                                )
        # write first entry to table
        dynamodb.put_item(
                        TableName = self.mock_ddb_table_name,
                        Item = {
                            'id': {
                                'S': '0'
                            },
                            'timesVisited': {
                                'N': '0'
                            }
                        }
                    )
        # prepare a resouce to manipulate
        self.my_mock_resource = {
            'client': client('dynamodb', region_name='us-west-1'),
            'table_name': self.mock_ddb_table_name,
            'counter_table_entry': {
                'id': { 'S': '0' }
            }
        }


    def tearDown(self) -> None:
        self.mock_aws.stop()


    def test_lambda_handler_wrong_path(self):
        """test  wrong path"""
        mock_event = {
                        "resource": "/path-does-not-exist",
                        "httpMethod": "POST"
                    }
        
        self.assertEqual(lambda_handler(event=mock_event, context=None), self.default_http_response)
        
    def test_lambda_handler_wrong_method(self):
        """test wrong method"""
        mock_event = {
                        "resource": "/visitor-count",
                        "httpMethod": "GET"
                    }
        
        self.assertEqual(lambda_handler(event=mock_event, context=None), self.default_http_response)


    # @mock.patch('lambda_function._VISITORCOUNTER_RESOURCE', 'hi there')
    def test_lambda_handler_counter_less_than_100(self):
        """
            test correct path & method with  counter less than 100
            expected: counter increase by 1
        """        
        override_counter_value = 50

        mock_event = {
                        "resource": "/visitor-count",
                        "httpMethod": "POST"
                    }
        
        test_response = lambda_handler(event=mock_event, context=None)

        expected_response = {
                                'statusCode': 200,
                                'body': {
                                            'timesVisited': str(override_counter_value + 1)
                                        }
                            }
    
        print(f'Lambda function response {test_response}')

        self.assertEqual(lambda_handler(event=mock_event, context=None), expected_response)





    """
        test corrrect path & method with counter over 100
        expected: counter reset to 1    
    """