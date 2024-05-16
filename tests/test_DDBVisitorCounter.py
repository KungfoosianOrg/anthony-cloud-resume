from unittest import TestCase
from boto3 import client
from moto import mock_aws
import os
import json
import sys

from back_end import DDBVisitorCounter


@mock_aws
class TestDDBVisitorCounter(TestCase):
    def setUp(self):
        DDBVisitorCounter()