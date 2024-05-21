from boto3 import client
from json import dumps
import os 

from LambdaResponse import LambdaResponse
from DDBVisitorCounter import DDBVisitorCounter


_RESPONSE_DEFAULT = {
    'statusCode': 200,
    'body': 'request processed'
}

_VISITORCOUNTER_RESOURCE = {
    'client': client('dynamodb', region_name=os.environ.get('DDB_TABLE_REGION') or 'us-west-1'),
    'table_name': os.environ.get('DDB_TABLE_ARN'),
    'counter_table_entry': {
        'id': { 'S': '0' }
    }
}



def lambda_handler(event, context):
    # ignore requests that are not POST to /visitor-count
    if event['resource'] != '/visitor-count' or event['httpMethod'] != 'POST':
        return LambdaResponse(response=_RESPONSE_DEFAULT).json
    
    try:
        # need to set again bc unittest does not load first go
        _VISITORCOUNTER_RESOURCE['table_name'] = os.environ.get('DDB_TABLE_ARN')

        myVisitorCounter = DDBVisitorCounter(DDBResource=_VISITORCOUNTER_RESOURCE)


        myVisitorCounter.increase_counter()

        if myVisitorCounter.counter > 100:
            myVisitorCounter.reset_counter()
            

        myVisitorCounter.update_ddb()
        
        test = LambdaResponse(response={
                                        'statusCode': 200,
                                        'body': dumps({ 'timesVisited': str(myVisitorCounter.counter) })
                                        }).json
        

        return test
    except Exception as e:
        print(f'UH OH...Encountered an exception: {e}')

    return