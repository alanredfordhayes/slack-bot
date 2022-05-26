import json
import boto3
import os

# DynamDB
table_name = os.environ['slack_bot_table_name']
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    # TODO implement
    
    httpMethod = event['httpMethod']
    
    if httpMethod == 'POST':
        body = event['body']
        body = json.loads(body)
        challenge = body['challenge']
        event_id = challenge
        # body = event['body']
        # body = json.loads(body)
        # event_id = body['event_id']
        # event['EventID'] = event_id
        # table.put_item(
        #     Item = event
        # )
        
    responseObject = {}
    responseObject['statusCode'] = 200
    responseObject['headers'] = {}
    responseObject['headers']['Content-Type'] = 'application/json'
    responseObject['body'] = event_id
    
    return responseObject