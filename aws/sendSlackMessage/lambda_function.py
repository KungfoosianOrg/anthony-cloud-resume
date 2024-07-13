import json
import boto3
import urllib3
import os


ssm = boto3.client('ssm', region_name=os.environ['AWS_REGION'])

_RESPONSE_DEFAULT = {
    'statusCode': 200,
    'body': 'request processed'
}

def lambda_handler(event, context):
    try:
        if 'Records' not in event or event['Records'][0]['EventSource'] != 'aws:sns':
            return _RESPONSE_DEFAULT
        

        # get the SNS topic name that triggered the Lambda to pass in message send to Slack
        sns_topic_arn = event['Records'][0]['Sns']['TopicArn']

        sns_topic_name = sns_topic_arn.split(':')[-1]

        # finally, get the slack webhook URL from Parameter Store
        slack_url = ssm.get_parameter(Name='/SLACK_WEBHOOK_URL',WithDecryption=True)['Parameter']['Value']
        
        connectionPool = urllib3.PoolManager()
        
        encoded_body = json.dumps({
            'text': f'Alarm {sns_topic_name} has been triggered'
        })
        
        r = connectionPool.request(method='POST',
                                  url=slack_url,
                                  body=encoded_body,
                                  headers={'Content-Type': 'application/json'}
                                  )
        
        
        
        # If everything went OK, Slack will response with status 200
        if r.status == 200:
            return json.dumps({
                'statusCode': 200,
                'body': 'ok'
            })

    except Exception as e:
        print(f'\tERROR: Lambda handler for sendSlackMessage encountered an exception: {e}')