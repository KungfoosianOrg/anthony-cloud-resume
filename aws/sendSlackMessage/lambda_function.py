import json
import boto3
import urllib3
import os


ssm = boto3.client('ssm', region_name=os.environ['AWS_REGION'])

_RESPONSE_DEFAULT = {
    'statusCode': 200,
    'body': 'request processed'
}

# print(os.environ['AWS_REGION'])

def lambda_handler(event, context):
    try:
        print(f'event received: {event}')

        # print(f'event type {type(event)}')

        print(f'event source: {event["Records"][0]}')

        if "Records" not in event or event["Records"][0]["EventSource"] != 'aws:sns':
            return _RESPONSE_DEFAULT
        

        print('printing out event dict keys')
        for k, v in event.items():
            print(k, v)


        # get the SNS topic name that triggered the Lambda to pass in message send to Slack
        sns_topic_arn = event['Records'][0]['Sns']['TopicArn']

        sns_topic_name = sns_topic_arn.split(':')[-1]

        # finally, get the slack webhook URL from Parameter Store
        slack_url = ssm.get_parameter(Name='/SLACK_WEBHOOK_URL',WithDecryption=True)['Parameter']['Value']
        
        print(f'got url: {slack_url}')

        connection_pool = urllib3.PoolManager()
        
        encoded_body = json.dumps({
            'text': f'Alarm {sns_topic_name} has been triggered'
        })
        
        print(f'PoolManager is: {connection_pool}')

        r = connection_pool.request(method='POST',
                                  url=slack_url,
                                  body=encoded_body,
                                  headers={'Content-Type': 'application/json'}
                                  )
        
        print(f'got response: {r}')
        
        # If everything went OK, Slack will response with status 200
        if r.status == 200:
            return json.dumps({
                'statusCode': 200,
                'body': 'ok'
            })

    except Exception as e:
        print(f'\tERROR: Lambda handler for sendSlackMessage encountered an exception: {e}')