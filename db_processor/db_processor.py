import json
import boto3
import os
import logging
from slack_bolt import App
logging.getLogger().setLevel(logging.INFO)

dynamodb = boto3.resource('dynamodb')
event_api_table_name = os.environ['event_api_table']
event_api_table = dynamodb.Table(event_api_table_name)
db_processor_table_name = os.environ['db_processor_table']
db_processor_table = dynamodb.Table(db_processor_table_name)
slack_bot_token = os.environ['SLACK_BOT_TOKEN']
slack_signing_secret = os.environ['SLACK_SIGNING_SECRET']
app = App(token=os.environ.get(slack_bot_token), signing_secret=os.environ.get(slack_signing_secret))

def pt_new(text):
    logging.info(text)
    
def pt_help(text):
    logging.info("help")

def pt_status(text):
    logging.info(text)

def pt_comments(text):
    logging.info(text)

def pt_watchers(text):
    logging.info(text)

def parse_text(text, channel):
    message = {}
    message['channel'] = channel

    if text[0] == None: 
        command = pt_help(text)
    elif text[0] == "new":
        command = pt_new(text)
    elif text[0] == "help":
        command = pt_help(text)
    elif text[0] == "status":
        command = pt_status(text)
    elif text[0] == "comments":
        command = pt_comments(text)
    elif text[0] == "watchers":
        command = pt_watchers(text)        
    else:
        command = pt_help()
    return command

def lambda_handler(event, context):
    for record in event['Records']:
        table_item = {}
        table_item['EventID'] = record['eventID']
        table_item['awsRegion'] = record['awsRegion']
        table_item['dynamodb'] = record['dynamodb']['Keys']['EventID']['S']
        table_item['eventName'] = record['eventName']
        table_item['eventSource'] = record['eventSource']
        table_item['eventVersion'] = record['eventVersion']
        event_api_record = event_api_table.get_item(Key={'EventID': table_item['dynamodb']})
        event_api_record_item = event_api_record['Item']
        event_api_record_item_body = event_api_record_item['body']
        event_api_record_item_body = json.loads(event_api_record_item_body)
        event_api_record_item_body_event = event_api_record_item_body['event']
        event_api_record_item_body_event_text = event_api_record_item_body_event['text']
        event_api_record_item_body_event_text = event_api_record_item_body_event_text.split(' ')
        event_api_record_item_body_event_text = event_api_record_item_body_event_text[1]
        event_api_record_item_body_channel = event_api_record_item_body_event['channel']
        pt = parse_text(event_api_record_item_body_event_text, event_api_record_item_body_channel)

        
        db_processor_table.put_item(Item = table_item)
    
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
