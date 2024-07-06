/* global fetch */

console.log('Loading function');

const https = require('https');

const doPostRequest = () => {
    
    const url = 'https://hooks.slack.com/services/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';
    const data = JSON.stringify({ text: 'test from lambda'});
    
    return new Promise((resolve, reject) => {
        const options = {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          }
    };
    
    //create the request object with the callback with the result
    const req = https.request(url, options, (res) => {
      resolve(JSON.stringify(res.statusCode));
    });
    
    // handle the possible errors
    req.on('error', (e) => {
      reject(e.message);
    });
    
    //do the request
    req.write(data);
    
    //finish the request
    req.end();
    });
};

exports.handler = async (event) => {
  await doPostRequest()
    .then(result => console.log(`Status code: ${result}`))
    .catch(err => console.error(`Error doing the request for the event: ${JSON.stringify(event)} => ${err}`));
};
