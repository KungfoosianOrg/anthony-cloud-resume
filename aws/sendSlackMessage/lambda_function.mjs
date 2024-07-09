/* global fetch */
import { SSMClient, GetParameterCommand } from '@aws-sdk/client-ssm';

const client = new SSMClient();


console.log('Loading function');


const doPostRequest = async (snsTopicName) => {
  try {
    const url = "https://hooks.slack.com/services/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";

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

// exports.handler = async (event) => {
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