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
def handle_app_mentions(event, client):
    channel = event['channel']
    blocks = [
		{ "block_id": "help_headers","type": "header", "text": { "type": "plain_text", "text": "Ticket Help", "emoji": True } },
		{ "block_id": "help_description", "type": "section", "text": { "type": "plain_text", "text": "Here is a list of things that I do for you:", "emoji": True } },
		{   
			"block_id": "help_buttons", "type": "actions", "elements": [
				{ "action_id": "create_new_ticket", "type": "button", "text": { "type": "plain_text", "emoji": True, "text": "Create New Ticket" }, "style": "primary", "value": "create_new_ticket" },
				{ "action_id": "view_ticket_watchers", "type": "button",	"text": { "type": "plain_text", "emoji": True, "text": "View Ticket Watchers" }, "style": "primary", "value": "view_ticket_watchers" },
				{ "action_id": "view_ticket_status", "type": "button", "text": { "type": "plain_text", "emoji": True, "text": "View Ticket Status" }, "style": "primary", "value": "view_ticket_status" },
				{ "action_id": "view_ticket_comments", "type": "button",	"text": { "type": "plain_text", "emoji": True, "text": "View Ticket Comments" }, "style": "primary", "value": "view_ticket_comments" }
			]
		}
	]
    client.chat_postMessage(
        channel=channel,
        blocks = blocks,
        text = "Here is a list of things that I do for you:"
    )
    
@app.action({
    "block_id": "help_buttons",
    "action_id": "create_new_ticket"
})
def approve_request(ack, say):
    # Acknowledge action request
    ack()
    say("Request approved 👍")

def lambda_handler(event, context):
    httpMethod = event['httpMethod']
    if httpMethod == 'POST':
        body = event['body']
        body = json.loads(body)
        logging.info(body)
        event_id = body['event_id']
        event['EventID'] = event_id
        table.put_item(Item = event)
        slack_handler = SlackRequestHandler(app=app)

    return slack_handler.handle(event, context)