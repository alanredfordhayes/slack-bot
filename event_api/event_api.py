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
        text = "Here is a list of things that I do for you Symran Oruko Nyawade Nyamwaya:"
    )
    
@app.action({
    "block_id": "help_buttons",
    "action_id": "create_new_ticket"
})
def approve_request(ack, body, client):
    # Acknowledge action request
    ack()
    client.views_open(
        # Pass a valid trigger_id within 3 seconds of receiving it
        trigger_id=body["trigger_id"],
        # View payload
        view={
            "type": "modal",
            # View identifier
            "callback_id": "view_1",
            "title": {"type": "plain_text", "text": "New Support Ticket"},
            "submit": {"type": "plain_text", "text": "Submit"},
            "blocks": [
                {
                    "type": "divider"
                },
                {
                    "type": "section",
                    "text": {
                        "type": "mrkdwn",
                        "text": "Issue Type"
                    },
                    "accessory": {
                        "type": "static_select",
                        "placeholder": {
                            "type": "plain_text",
                            "text": "Select an item",
                            "emoji": True
                        },
                        "options": [
                            {
                                "text": {
                                    "type": "plain_text",
                                    "text": "Incident",
                                    "emoji": True
                                },
                                "value": "value-0"
                            },
                            {
                                "text": {
                                    "type": "plain_text",
                                    "text": "Problem",
                                    "emoji": True
                                },
                                "value": "value-1"
                            },
                            {
                                "text": {
                                    "type": "plain_text",
                                    "text": "Purchase",
                                    "emoji": True
                                },
                                "value": "value-2"
                            },
                            {
                                "text": {
                                    "type": "plain_text",
                                    "text": "Font Purchase",
                                    "emoji": True
                                },
                                "value": "value-2"
                            },
                            {
                                "text": {
                                    "type": "plain_text",
                                    "text": "AWS Account Access",
                                    "emoji": True
                                },
                                "value": "value-2"
                            }
                        ],
                        "action_id": "static_select-action"
                    }
                },
                {
                    "type": "divider"
                },
                {
                    "type": "input",
                    "block_id": "create_new_ticket_summary",
                    "label": {
                        "type": "plain_text",
                        "text": "Summary"
                    },
                    "element": {
                        "type": "plain_text_input",
                        "action_id": "create_new_ticket_summary"
                    }
                },
                {
                    "type": "divider"
                },
                {
                    "type": "input",
                    "element": {
                        "type": "plain_text_input",
                        "multiline": True,
                        "action_id": "plain_text_input-action"
                    },
                    "label": {
                        "type": "plain_text",
                        "text": "Description",
                        "emoji": True
                    }
                },
                {
                    "type": "divider"
                },
                {
                    "type": "section",
                    "text": {
                        "type": "mrkdwn",
                        "text": "Priority"
                    },
                    "accessory": {
                        "type": "static_select",
                        "placeholder": {
                            "type": "plain_text",
                            "text": "Select an item",
                            "emoji": True
                        },
                        "options": [
                            {
                                "text": {
                                    "type": "plain_text",
                                    "text": "None",
                                    "emoji": True
                                },
                                "value": "none"
                            },
                            {
                                "text": {
                                    "type": "plain_text",
                                    "text": "Normal",
                                    "emoji": True
                                },
                                "value": "normal"
                            },
                            {
                                "text": {
                                    "type": "plain_text",
                                    "text": "High",
                                    "emoji": True
                                },
                                "value": "high"
                            }
                        ],
                        "action_id": "static_select-action"
                    }
                }
            ]
        }
    )
    
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