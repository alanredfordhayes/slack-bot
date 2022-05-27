import json
import boto3
import os

import logging
logging.getLogger().setLevel(logging.INFO)

# DynamDB
dynamodb = boto3.resource('dynamodb')
event_api_table_name = os.environ['event_api_table']
event_api_table = dynamodb.Table(event_api_table_name)

db_processor_table_name = os.environ['db_processor_table']
db_processor_table = dynamodb.Table(db_processor_table_name)

def lambda_handler(event, context):
    # TODO implement
    
    for record in event['Records']:
        
        
        table_item = {}
        table_item['EventID'] = record['eventID']
        table_item['awsRegion'] = record['awsRegion']
        table_item['dynamodb'] = record['dynamodb']['Keys']['EventID']['S']
        table_item['eventName'] = record['eventName']
        table_item['eventSource'] = record['eventSource']
        table_item['eventVersion'] = record['eventVersion']
        
        event_api_record = event_api_table.get_item(
            Key={
                'EventID': table_item['dynamodb']
            }
        )
        logging.info(event_api_record)
        
        event_api_record_item = event_api_record['Item']
        event_api_record_item_body = event_api_record_item['body']
        item_type = type(event_api_record_item_body)
        logging.info(item_type)
        logging.info(event_api_record_item_body)
        
        db_processor_table.put_item(
            Item = table_item
        )
    
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
