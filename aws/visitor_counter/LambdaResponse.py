class LambdaResponse:
    def __init__(self, response):
        self.statusCode = response['statusCode']
        self.body = response['body']
        self.json = self.jsonify_response()


    def jsonify_response(self):
        """
            @return list 'object that is JSON-able as an HTTP response'
        """
        return { 
            'statusCode': self.statusCode,
            'body': self.body
        }