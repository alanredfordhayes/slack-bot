import json
from lib2to3.pgen2 import token

def lambda_handler(event, context):
    # TODO implement
    
    httpMethod = event['httpMethod']
    
    if httpMethod == "POST":
        body = event['body']
        body = json.dumps(body)
        token = body['token']
        challenge = body['challenge']
        url_type = body['type']
        
        responseObject = {}
        responseObject['statusCode'] = 200
        responseObject['headers'] = {}
        responseObject['headers']['Content-Type'] = 'application/json'
        responseObject['challenge'] = challenge
            
        return responseObject