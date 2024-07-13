import moto
import unittest
from aws.sendSlackMessage.lambda_function import lambda_handler

import json
import boto3
import urllib3
import os





class TestSendSlackMessage(unittest.TestCase):
    @unittest.mock('lambda_handler.ssm')
    def test_lambda_handler():
        return