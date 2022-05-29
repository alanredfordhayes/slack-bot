import json
import boto3
import os
import time
from slack_bolt import App
from slack_bolt.adapter.aws_lambda import SlackRequestHandler
import logging

# DynamDB
# Challenge Message
def challenge_message(event):
    body = event['body']
    body = json.loads(body)
    challenge = body['challenge']
    event_id = challenge
    responseObject = {}
    responseObject['statusCode'] = 200
    responseObject['headers'] = {}
    responseObject['headers']['Content-Type'] = 'application/json'
    responseObject['body'] = event_id
    return responseObject

#DYNAMODB  
table_name = os.environ['event_api_table']
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(table_name)

def dynamodb_put_item(event):
    body = event['body']
    body = json.loads(body)
    logging.info(body)
    event_id = body['event_id']
    event['EventID'] = event_id
    table.put_item(Item = event)

# BOLT
app = App(process_before_response=True)

@app.event("app_mention")
def handle_app_mentions(event, say):
    channel = event['channel']
    say(channel)


def lambda_handler(event, context):
    httpMethod = event['httpMethod']
    if httpMethod == 'POST':
        dynamodb_put_item(event)
        slack_handler = SlackRequestHandler(app=app)

    return slack_handler.handle(event, context)