from unittest import TestCase
from boto3 import client
from moto import mock_aws
from os import environ

from  back_end.DDBVisitorCounter import DDBVisitorCounter


class TestDDBVisitorCounter(TestCase):
    def setUp(self):
        self.mock_aws = mock_aws()
        self.mock_aws.start()

        self.mocked_ddb_table_name = 'test-ddb-table'

        self.initial_counter_value = 10

        # to test the code, need to create a DDB table with an entry of id of 0, type string (S), and a timesVisited entry type number (N)
        self.dynamodb = client('dynamodb', region_name='us-west-1')

        # creating the table
        self.dynamodb.create_table(
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
        self.dynamodb.put_item(
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


    def test_get_counter_entry_exist(self):
        """ get existing counter number from the table """
        

        mocked_ddbvisitorcounter_class = DDBVisitorCounter(DDBResource=self.mocked_visitorcounter_resource)

        # test_return_value = mocked_ddbvisitorcounter_class.get_counter_entry()

        # self.assertEqual(test_return_value, int(self.initial_counter_value))
        self.assertEqual(mocked_ddbvisitorcounter_class.counter, int(self.initial_counter_value))

    
    def test_get_counter_entry_not_exist(self):
        """ get non-existing counter value. Expected: new entry created, counter set to 0"""
        # delete the counter entry so test can proceed
        # add entry of timesVisited (type N) to entry of id 0
        self.dynamodb.delete_item(
            TableName = self.mocked_ddb_table_name,
            Key = {
                'id': {
                    'S': '0'
                }
            }
        )


        mocked_ddbvisitorcounter_class = DDBVisitorCounter(DDBResource=self.mocked_visitorcounter_resource)

        self.assertEqual(mocked_ddbvisitorcounter_class.counter, 0)


    def test_increase_counter(self):
        """ test counter increase by 1 correctly"""
        mocked_ddbvisitorcounter_class = DDBVisitorCounter(DDBResource=self.mocked_visitorcounter_resource)

        increased_counter_expected = mocked_ddbvisitorcounter_class.counter + 1

        self.assertEqual(increased_counter_expected, mocked_ddbvisitorcounter_class.increase_counter())


    def test_reset_counter(self):
        """ test counter reset to 1"""
        # set counter to a random number then verify
        mocked_ddbvisitorcounter_class = DDBVisitorCounter(DDBResource=self.mocked_visitorcounter_resource)

        random_counter_value = 20

        mocked_ddbvisitorcounter_class.client.put_item(
            TableName = mocked_ddbvisitorcounter_class.table_name,
            Item = {
                'id': {
                    'S': mocked_ddbvisitorcounter_class.counter_table_entry['id']['S']
                },
                'timesVisited': {
                    'N': str(random_counter_value)
                }
            }
        )

        mocked_ddbvisitorcounter_class.get_counter_entry()
        
        self.assertEqual(random_counter_value, mocked_ddbvisitorcounter_class.counter)

        # reset and testt
        mocked_ddbvisitorcounter_class.reset_counter()
        self.assertEqual(1, mocked_ddbvisitorcounter_class.counter)


    def test_update_ddb(self):
        """ check value returned by database after updating is as expected"""
        mocked_ddbvisitorcounter_class = DDBVisitorCounter(DDBResource=self.mocked_visitorcounter_resource)

        random_counter_value = 20

        counter_before_update = mocked_ddbvisitorcounter_class.counter

        mocked_ddbvisitorcounter_class.counter = random_counter_value

        mocked_new_counter_value = mocked_ddbvisitorcounter_class.update_ddb()

        """ check for difference between counter value before and after updating"""
        self.assertNotEqual(counter_before_update, mocked_new_counter_value)

        """ check random counter value was set to is equals to value returned after updating"""
        self.assertEqual(random_counter_value, mocked_new_counter_value)





