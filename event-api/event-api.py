import json

def lambda_handler(event, context):
    # TODO implement
    
    httpMethod = event['httpMethod']
    
    if httpMethod == "POST":
        body = event['body']
        body = json.loads(body)
        challenge = body['challenge']
        
    responseObject = {}
    responseObject['statusCode'] = 200
    responseObject['headers'] = {}
    responseObject['headers']['Content-Type'] = 'application/json'
    responseObject['body'] = challenge
        
    return responseObject