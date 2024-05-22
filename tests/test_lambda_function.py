from unittest import TestCase
from boto3 import client
from moto import mock_aws
import json
from os import environ

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
        environ['DDB_TABLE_ARN'] = self.mock_ddb_table_name
        

        self.dynamodb = client('dynamodb', region_name='us-west-1')

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
        # write first entry to table
        self.dynamodb.put_item(
                        TableName = self.mock_ddb_table_name,
                        Item = {
                            'id': {
                                'S': '0'
                            },
                            'timesVisited': {
                                'N': '50'
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

        self.mock_event = {
                        "resource": "/visitor-count",
                        "httpMethod": "POST"
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


    def test_lambda_handler_counter_less_than_100(self):
        """
            test correct path & method with  counter less than 100
            expected: counter increase by 1
        """        
        
        override_counter_value = 50

        expected_response = {
                                'statusCode': 200,
                                'body': json.dumps({ 'timesVisited': str(override_counter_value + 1) })
                            }

        self.assertEqual(lambda_handler(event=self.mock_event, context=None), expected_response)





    """
        test corrrect path & method with counter over 100
        expected: counter reset to 1    
    """
    def test_lambda_handler_counter_over_100(self):
        # set counter in table to 100
        self.dynamodb.put_item(
                                TableName = self.mock_ddb_table_name,
                                Item = {
                                    'id': {
                                        'S': '0'
                                    },
                                    'timesVisited': {
                                        'N': '100'
                                    }
                                }
                            )
        
        expected_response = {
                                'statusCode': 200,
                                'body': json.dumps({ 'timesVisited': '1' })
                            }

        # add 1 to counter verify counter reset to 1
        self.assertEqual(lambda_handler(event=self.mock_event, context=None), expected_response)