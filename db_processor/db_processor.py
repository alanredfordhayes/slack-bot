import json
import boto3
import os

# DynamDB
table_name = os.environ['slack_bot_table_name']
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    # TODO implement
    
    for record in event['Records']:
        
        table.put_item(
            Item = record
        )
    
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
