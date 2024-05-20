from boto3 import client
from json import dumps
from os import environ
from back_end.LambdaResponse import LambdaResponse
from back_end.DDBVisitorCounter import DDBVisitorCounter

_RESPONSE_DEFAULT = {
    'statusCode': 200,
    'body': 'request processed'
}

_VISITORCOUNTER_RESOURCE = {
    'client': client('dynamodb', region_name=environ.get('DDB_TABLE_REGION') or 'us-west-1'),
    'table_name': environ.get('DDB_TABLE_ARN'),
    'counter_table_entry': {
        'id': { 'S': '0' }
    }
}



def lambda_handler(event, context=None):
    # ignore requests that are not POST to /visitor-count
    if event['resource'] != '/visitor-count' or event['httpMethod'] != 'POST':
        return LambdaResponse(response=_RESPONSE_DEFAULT).json
    
    try:
        myVisitorCounter = DDBVisitorCounter(DDBResource=_VISITORCOUNTER_RESOURCE)

        myVisitorCounter.increase_counter()

        if myVisitorCounter.counter > 100:
            myVisitorCounter.reset_counter()
            

        myVisitorCounter.update_ddb()

        return LambdaResponse(response={
                                        'statusCode': 200,
                                        'body': dumps({ 'timesVisited': str(myVisitorCounter.counter) })
                                        }).json
    except Exception as e:
        print(f'Encountered an exception: {e}')

    return