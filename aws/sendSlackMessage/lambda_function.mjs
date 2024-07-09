/* global fetch */
import { SSMClient, GetParameterCommand } from '@aws-sdk/client-ssm';

const client = new SSMClient();

const ssmInput = {
  Name: "/SLACK_WEBHOOK_URL", // required
  WithDecryption: true
}


console.log('Loading function');


const doPostRequest = async (snsTopicName) => {
  try {
    const ssmCommand = new GetParameterCommand(ssmInput);
    const ssmResponse = await client.send(ssmCommand);
    
    console.log(ssmResponse)
    
    const url = ssmResponse['Parameter']['Value'];

    const data = JSON.stringify({ text: `Alarm ${snsTopicName} has been triggered` });

    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: data
    })

    if (response.status === 200) {
      return response.status
    }

    return null
  } catch (error) {
    console.error('Something went wrong: ' + error);

    return null;
  }
};

export const handler = async (event) => {
  if ( !Object.keys(event).includes('Records') || event['Records'][0]['EventSource'] !== 'aws:sns' ) {
    return {
      'statusCode': 200,
      'body': 'request processed'
    }
  }

  // get the sns topic name
  let snsTopicArn = event['Records'][0]['Sns']['TopicArn'];
  let split = snsTopicArn.split(':');
  let snsTopicName = split[split.length - 1]


  // send message to slack with topic name
  await doPostRequest(snsTopicName)
    .then(result => console.log(`Status code: ${result}`))
    .catch(err => console.error(`Error doing the request for the event: ${JSON.stringify(event)} => ${err}`));
};