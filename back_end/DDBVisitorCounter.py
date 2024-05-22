class DDBVisitorCounter:
    def __init__(self, DDBResource):
        self.client = DDBResource['client']
        self.table_name = DDBResource['table_name']
        self.counter_table_entry = DDBResource['counter_table_entry']
        self.counter = self.get_counter_entry() 

    
    
    def get_counter_entry(self) -> int:
        """
            Gets visitor counter

            Tests: get entry that exist, get entry that doesn't
        """
        try:

            response = self.client.get_item( 
                                    TableName = self.table_name,
                                    Key = self.counter_table_entry
                                    )
            
            if 'Item' not in response.keys():
                raise Exception(f'Table entry does not exist, received: {response}')
            
            self.counter = int(response['Item']['timesVisited']['N'])

            return self.counter

        except Exception as e:
            raise e
        

    def increase_counter(self) -> int:
        """
            Increase counter by 1
        """
        self.counter += 1

        return self.counter


    def reset_counter(self) -> int:
        """
            Reset counter to 1
        """
        self.counter = 1

        return self.counter


    def update_ddb(self) -> int:
        """
            Updates DDB entry visitorCounter to whichever number self.counter has
            @return int updated counter number
        """
        

        try:
            response = self.client.update_item(
                         TableName = self.table_name,
                         Key = self.counter_table_entry,
                ExpressionAttributeValues={ ':newValue': { 'N': str(self.counter)} },
                         UpdateExpression = 'SET timesVisited = :newValue',
                         ReturnValues = 'UPDATED_NEW'
                        )

            if response['ResponseMetadata']['HTTPStatusCode'] == 200:
                new_counter_value = int(response['Attributes']['timesVisited']['N'])

                self.counter = new_counter_value

                return new_counter_value
        except Exception as e:
            raise e
