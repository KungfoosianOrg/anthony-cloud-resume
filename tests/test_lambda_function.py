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
        
        # sets up a mock dynamoDB table to test API calls to AWS
        self.mock_ddb_table_name = 'mock-ddb-table'
        self.dynamodb = client('dynamodb', region_name='us-west-1')


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
                        "resource": "/visitor-count",
                        "httpMethod": "GET"
                    }
        
        self.assertEqual(lambda_handler(event=mock_event), self.default_http_response)


    def test_lambda_handler_counter_less_than_100(self):
        """
            test correct path & method with  counter less than 100
            expected: counter increase by 1
        """
        # creating the table
        self.dynamodb.create_table(
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

        # add an entry less than 100
        # add entry of timesVisited (type N) to entry of id 0
        test_counter_entry = '50'

        self.dynamodb.put_item(
                                TableName = self.mock_ddb_table_name,
                                Item = {
                                    'id': {
                                        'S': '0'
                                    },
                                    'timesVisited': {
                                        'N': test_counter_entry
                                    }
                                }
                            )

        mock_event = {
                        "resource": "/visitor-count",
                        "httpMethod": "POST"
                    }

        # test_response = lambda_handler(event=mock_event)

        expected_response = {
                                'statusCode': 200,
                                'body': {
                                            'timesVisited': str(int(test_counter_entry) + 1)
                                        }
                            }

        self.assertEqual(lambda_handler(event=mock_event), expected_response)




    """
        test corrrect path & method with counter over 100
        expected: counter reset to 1    
    """