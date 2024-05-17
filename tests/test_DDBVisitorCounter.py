from unittest import TestCase
from boto3 import client
from moto import mock_aws
import os
import json
import sys

from back_end import DDBVisitorCounter


# @mock_aws
class TestDDBVisitorCounter(TestCase):
    def setUp(self):
        self.mock_aws = mock_aws()
        self.mock_aws.start()

        _MOCK_TABLE_NAME = 'test-ddb-table'

        # to test the code, need to create a DDB table with an entry of id of 0, type string (S), and a timesVisited entry type number (N)
        dynamodb = client('dynamodb')

        # creating the table
        table = dynamodb.create_table(
            AttributeDefinitions = [
                {
                    'AttributeName': 'id',
                    'AttributeType': 'S'
                }
            ],
            TableName = _MOCK_TABLE_NAME,
            KeySchema = [
                {
                    'AttributeName': 'id',
                    'KeyType': 'HASH'
                }
            ]
        )

        # add entry of timesVisited (type N) to entry of id 0
        counter_entry = dynamodb.put_item(
            TableName = _MOCK_TABLE_NAME,
            Item = {
                'id': {
                    'S': '0'
                },
                'timesVisited': {
                    'N': '0'
                }
            }
        )

    def tearDown(self) -> None:
        self.mock_aws.stop()