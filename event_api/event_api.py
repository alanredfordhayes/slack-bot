import os
from slack_bolt.async_app import AsyncApp
from slack_bolt.adapter.aws_lambda import SlackRequestHandler
import logging
logging.getLogger().setLevel(logging.INFO)

app = AsyncApp(process_before_response=True, token=os.environ.get("SLACK_BOT_TOKEN"), signing_secret=os.environ.get("SLACK_SIGNING_SECRET"))

@app.event("app_mentioon")
async def app_mention(event, say):
    welcome_channel_id = "C12345"
    user_id = event["user"]
    text = f"Welcome to the team, <@{user_id}>! 🎉 You can introduce yourself in this channel."
    await say(text=text, channel=welcome_channel_id)

def lambda_handler(event, context):
    slack_handler = SlackRequestHandler(app=app)
    return slack_handler.handle(event, context)