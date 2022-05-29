import json
import boto3
import os
import time
from slack_bolt import App
from slack_bolt.adapter.aws_lambda import SlackRequestHandler
import logging
logging.getLogger().setLevel(logging.INFO)

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

def dynamodb_put_item(body, event):
    event_id = body['event_id']
    event['EventID'] = event_id
    table.put_item(Item = event)

# BOLT
app = App(process_before_response=True)

@app.event("app_mention")
def handle_app_mentions(event, client, body):
    dynamodb_put_item(body, event)
    channel = event['channel']
    blocks = [
		{ "block_id": "help_headers","type": "header", "text": { "type": "plain_text", "text": "Ticket Help", "emoji": True } },
		{ "block_id": "help_description", "type": "section", "text": { "type": "plain_text", "text": "Here is a list of things that I do for you Symran Oruko Nyawade Nyamwaya:", "emoji": True } },
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
def create_ticket(ack, body, client):
    # Acknowledge action request
    ack()
    
    f = open('create_ticket.json')
    f_data = json.load(f)
    client.views_open(
        trigger_id=body["trigger_id"],
        view=f_data
    )
    
@app.view("view_1")
def handle_submission(ack, body, client, view, logger):
    create_ticket_issue_type = view["state"]["values"]["create_ticket_issue_type"]["static_select_action"]
    create_new_ticket_summary = view["state"]["values"]["create_ticket_issue_type"]["plain_text_input_action"]
    create_new_ticket_description = view["state"]["values"]["create_new_ticket_description"]['plain_text_input_action']
    create_new_ticket_priority = view["state"]["values"]["create_new_ticket_priority"]["static_select_action"]
    user = body["user"]["id"]
    errors = {}
    msg = "Please complete the form with all document fields completed."
    if create_ticket_issue_type == None:
        errors['create_ticket_issue_type'] = msg
    elif create_new_ticket_summary = None:
        errors['create_new_ticket_summary'] = msg
    elif create_new_ticket_description == None:
        errors['create_new_ticket_description'] = msg
    elif create_new_ticket_priority == None:
        errors['create_new_ticket_priority'] = msg
        
    if len(errors) > 0:
        ack(response_action="errors", errors=errors)
        return

    msg = "Request Submitted 👍"
    try:
        client.chat_postMessage(channel=user, text=msg)
    except Exception as e:
        logger.exception(f"Failed to post a message {e}")
    
@app.action({
    "block_id": "help_buttons",
    "action_id": "view_ticket_watchers"
})
def approve_request(ack, say):
    # Acknowledge action request
    ack()
    say("Request approved 👍")
    
@app.action({
    "block_id": "help_buttons",
    "action_id": "view_ticket_status"
})
def approve_request(ack, say):
    # Acknowledge action request
    ack()
    say("Request approved 👍")
    
@app.action({
    "block_id": "help_buttons",
    "action_id": "view_ticket_comments"
})
def approve_request(ack, say):
    # Acknowledge action request
    ack()
    say("Request approved 👍")

def lambda_handler(event, context):
    httpMethod = event['httpMethod']
    if httpMethod == 'POST':
        slack_handler = SlackRequestHandler(app=app)

    return slack_handler.handle(event, context)