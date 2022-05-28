import json
import boto3
import os
import time
from slack_bolt import App
from slack_bolt.adapter.aws_lambda import SlackRequestHandler
import logging

# DynamDB
table_name = os.environ['event_api_table']
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(table_name)

# BOLT
app = App(process_before_response=True)

@app.event("app_mention")
def handle_app_mentions(body, say, logger):
    logger.info(body)
    say("What's up?")

def lambda_handler(event, context):
    
    httpMethod = event['httpMethod']
    if httpMethod == 'POST':
        # body = event['body']
        # body = json.loads(body)
        # challenge = body['challenge']
        # event_id = challenge
        body = event['body']
        body = json.loads(body)
        logging.info(body)
        event_id = body['event_id']
        event['EventID'] = event_id
        table.put_item(Item = event)
        slack_handler = SlackRequestHandler(app=app)
        
    responseObject = {}
    responseObject['statusCode'] = 200
    responseObject['headers'] = {}
    responseObject['headers']['Content-Type'] = 'application/json'
    responseObject['body'] = event_id
    
    return slack_handler.handle(event, context)