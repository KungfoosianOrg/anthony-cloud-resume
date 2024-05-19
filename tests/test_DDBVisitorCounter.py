from unittest import TestCase
from boto3 import client
from moto import mock_aws
from os import environ
import json
import sys

from  back_end.DDBVisitorCounter import DDBVisitorCounter

# @mock_aws
class TestDDBVisitorCounter(TestCase):
    def setUp(self):
        self.mock_aws = mock_aws()
        self.mock_aws.start()

        self.mocked_ddb_table_name = 'test-ddb-table'
        environ['DDB_TABLE_ARN'] = self.mocked_ddb_table_name

        self.initial_counter_value = 10

        # to test the code, need to create a DDB table with an entry of id of 0, type string (S), and a timesVisited entry type number (N)
        dynamodb = client('dynamodb', region_name='us-west-1')

        # creating the table
        dynamodb.create_table(
            AttributeDefinitions = [
                {
                    'AttributeName': 'id',
                    'AttributeType': 'S'
                }
            ],
            TableName = self.mocked_ddb_table_name,
            BillingMode = 'PAY_PER_REQUEST',
            KeySchema = [
                {
                    'AttributeName': 'id',
                    'KeyType': 'HASH'
                }
            ]
        )

        # add entry of timesVisited (type N) to entry of id 0
        dynamodb.put_item(
            TableName = self.mocked_ddb_table_name,
            Item = {
                'id': {
                    'S': '0'
                },
                'timesVisited': {
                    'N': str(self.initial_counter_value)
                }
            }
        )

        self.mocked_visitorcounter_resource = {
            'client': client('dynamodb', region_name='us-west-1'),
            'table_name': self.mocked_ddb_table_name,
            'counter_table_entry': {
                'id': { 'S': '0' }
            }
        }


    def tearDown(self) -> None:
        self.mock_aws.stop()


    def test_get_counter_entry(self):
        """ makes sure we can get a number from the table"""
        mocked_ddbvisitorcounter_class = DDBVisitorCounter(DDBResource=self.mocked_visitorcounter_resource)

        test_return_value = mocked_ddbvisitorcounter_class.get_counter_entry()

        self.assertEqual(test_return_value, int(self.initial_counter_value))


    def test_increase_counter(self):


