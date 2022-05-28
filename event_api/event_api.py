import json
import boto3
import os

import logging
logging.getLogger().setLevel(logging.INFO)

# DynamDB
table_name = os.environ['event_api_table']
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    httpMethod = event['httpMethod']
    if httpMethod == 'POST':
        body = event['body']
        body = json.loads(body)
        challenge = body['challenge']
        event_id = challenge
        # body = event['body']
        # body = json.loads(body)
        # logging.info(body)
        # event_id = body['event_id']
        # event['EventID'] = event_id
        # table.put_item(Item = event) 
        
    responseObject = {}
    responseObject['statusCode'] = 200
    responseObject['headers'] = {}
    responseObject['headers']['Content-Type'] = 'application/json'
    responseObject['body'] = event_id
    
    return responseObject