import json
import boto3
import urllib3
import urllib3.request

ssm = boto3.client('ssm', region_name='us-east-1')

_RESPONSE_DEFAULT = {
    'statusCode': 200,
    'body': 'request processed'
}

def lambda_handler(event, context):
    try:
        if 'Records' not in event or event['Records'][0]['EventSource'] != 'aws:sns':
            return _RESPONSE_DEFAULT
        

        print(event)

        print(context)
        
        # get the SNS topic name that triggered the Lambda to pass in message send to Slack
        sns_topic_arn = event['Records'][0]['Sns']['TopicArn']

        sns_topic_name = sns_topic_arn.split(':')[-1]

        # finally, get the slack webhook URL from Parameter Store
        slack_url = ssm.get_parameter(Name='/SLACK_WEBHOOK_URL',WithDecryption=True)['Parameter']['Value']
        
        # post message to Slack
        # r = urllib3.request.urlopen(urllib3.request.Request(url=slack_url,
        #                                                   headers={'Content-Type': 'application/json'},
        #                                                   method='POST',
        #                                                   data=bytes(json.dumps({'text': f'Alarm {sns_topic_name} has been triggered'}), encoding="utf-8")),
        #                                                   timeout=5
        #                             )
        r = urllib3.request('POST', slack_url, headers={'Content-Type': 'application/json'},json={'text': f'Alarm {sns_topic_name} has been triggered'})


        print(r)

        # If everything went OK, Slack will response with status 200
        if r['code'] == 200:
            return {
                'statusCode': 200,
                'body': 'ok'
            }
    except Exception as e:
        print(f'\tERROR: Lambda handler for sendSlackMessage encountered an exception: {e}')