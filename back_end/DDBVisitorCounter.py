class DDBVisitorCounter:
    def __init__(self, DDBResource):
        self.client = DDBResource['client']
        self.table_name = DDBResource['table_name']
        self.counter_table_entry = DDBResource['counter_table_entry']
        self.counter = self.get_counter_entry() 

    
    def get_counter_entry(self) -> int:
        """
            Gets visitor counter, if counter entry does not exist, create a new entry, else, return the counter value
        """
        try:
            response = self.client.get_item( 
                                    TableName = self.table_name,
                                    Key = self.counter_table_entry
                                    )

            if 'Item' not in response.keys():
                print('entry does not exist, creating new one')
                return self.write_first_entry()
                
            
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
                         ExpressionAttributeValues={ ':newValue': { 'N': str(self.counter) } },
                         UpdateExpression = 'SET timesVisited = :newValue',
                         ReturnValues = 'UPDATED_NEW'
                        )

            if response['ResponseMetadata']['HTTPStatusCode'] == 200:
                new_counter_value = int(response['Attributes']['timesVisited']['N'])

                self.counter = new_counter_value

                return new_counter_value
        except Exception as e:
            raise e
            
    
    def write_first_entry(self) -> int:
        """
            write first counter entry with value of 0 to table
        """
        self.counter = 0
        
        
        try:
            self.client.put_item(
                                    TableName = self.table_name,
                                    Item = {
                                        'id': {
                                            'S': '0'
                                        },
                                        'timesVisited': {
                                            'N': str(self.counter)
                                        }
                                    }
                                )

            return self.counter
        except Exception as e:
            raise e
