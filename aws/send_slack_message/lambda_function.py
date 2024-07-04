import json
import boto3
import urllib.request

ssm = boto3.client('ssm')


def lambda_handler(event, context):
    slack_url = ssm.get_parameter(Name='/SLACK_WEBHOOK_URL',WithDecryption=True)['Parameter']['Value']
    
    
    r = urllib.request.urlopen(urllib.request.Request(
        url=slack_url,
        headers={'Content-Type': 'application/json'},
        method='POST',
        data=bytes(json.dumps({'text': 'hello from Lambda'}), encoding="utf-8")),
        timeout=5)
        

    return {
        'statusCode': 200,
        'body': r.read().decode('utf-8')
    }
