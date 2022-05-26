import json
import boto3
import os

# DynamDB
table_name = os.environ['slack_bot_table_name']
event_api_table_name = os.environ['event_api_table_name']
dynamodb = boto3.resource('dynamodb')
db_processor_table = dynamodb.Table(table_name)
event_api_table = dynamodb.Table(event_api_table_name)

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
        
        body = event_api_record['body']
        
        
        db_processor_table.put_item(
            Item = table_item
        )
    
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
