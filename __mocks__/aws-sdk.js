class aws {
    static SecretsManager = class {
        describeSecret = jest.fn(() => {
            return {
                promise: () => Promise.resolve({ ARN: "custom-arn1", Name: "describeSec", SecretString: '{"UserName":"test","Password":"password"}'})
            }
        });
        getSecretValue = jest.fn(() => {
            return {
                promise: () => Promise.resolve({ ARN: "custom-arn2", Name: "getSecretVal", SecretString: '{"UserName":"test","Password":"password"}' })
            }
        });
    };
  }
  
  module.exports = aws;