from unittest import TestCase
from boto3 import client
from moto import mock_aws

from back_end.lambda_function import lambda_handler


class TestLambdaHandlerFunction(TestCase):
    def setUp(self):
        self.mock_aws = mock_aws()
        self.mock_aws.start()

    """test  wrong path"""

    """test wrong method"""

    """test correct path & method with  counter less than 100"""

    """test corrrect path & method with counter over 100"""