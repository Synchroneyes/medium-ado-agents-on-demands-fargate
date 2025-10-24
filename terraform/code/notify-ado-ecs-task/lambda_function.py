import gzip
import json
import base64
import boto3
import os
import requests
from logger import get_logger

def process_cloudwatch_logs_data(cloudwatch_logs_data):
    compressed_payload = base64.b64decode(cloudwatch_logs_data)
    uncompressed_payload = gzip.decompress(compressed_payload)
    payload = json.loads(uncompressed_payload)
    return payload

def get_dynamodb_item(taskId):
    dynamodb = boto3.resource('dynamodb')
    table_name = os.environ.get("DYNAMODB_TABLE_NAME")
    table = dynamodb.Table(table_name)

    response = table.get_item(Key={'taskId': taskId})
    return response.get('Item', None)

def delete_dynamodb_item(taskId):
    dynamodb = boto3.resource('dynamodb')
    table_name = os.environ.get("DYNAMODB_TABLE_NAME")
    table = dynamodb.Table(table_name)

    table.delete_item(Key={'taskId': taskId})

def lambda_handler(event, context):
    print(json.dumps(event))
    logger = get_logger()

    cloudwatch_logs_data = event['awslogs']['data']
    payload = process_cloudwatch_logs_data(cloudwatch_logs_data)

    logger.debug(f"Processed payload: {json.dumps(payload)}")

    log_stream = payload.get('logStream', None)

    if log_stream is None:
        logger.error("logStream not found in payload")
        return {
            'statusCode': 400,
            'body': json.dumps('Bad Request: logStream not found in payload')
        }

    task_id = log_stream.split('/')[-1] if '/' in log_stream else None
    if task_id is None:
        logger.error("task ID not found in logStream")
        return {
            'statusCode': 400,
            'body': json.dumps('Bad Request: task ID not found in logStream')
        }
    
    logger.info(f"Extracted task ID: {task_id}")
    dynamodb_item = get_dynamodb_item(task_id)
    
    if dynamodb_item is None:
        logger.error(f"No DynamoDB item found for task ID: {task_id}")
        return {
            'statusCode': 404,
            'body': json.dumps('Not Found: No DynamoDB item found for task ID')
        }
    
    logger.info(f"DynamoDB item found for task ID: {task_id}, proceeding to notify ADO")
    authorization_token = dynamodb_item['authorizationToken']
    ado_callback_url = dynamodb_item['adoPipelineCallbackURL']
    ado_task_id = dynamodb_item['adoTaskId']
    ado_job_id = dynamodb_item['adoJobId']


    response = requests.post(
        ado_callback_url,
        headers={
            'Content-Type': 'application/json',
            'Authorization': 'Basic ' + str((base64.b64encode(bytes('ado:'+ authorization_token, 'ascii'))), 'ascii')
        },
        json={
            'name': 'TaskCompleted',
            'taskId': ado_task_id,
            'jobId': ado_job_id,
            'result': "succeeded"
        }
    )

    delete_dynamodb_item(task_id)


    return {
        'statusCode': 200,
        'body': json.dumps(f'Task ID: {task_id}')
    }