import boto3
import os
from time import time

def write_to_dynamodb(ecs_task_id, authorization_token, ado_callback_url, ado_task_id, ado_job_id):
    dynamodb = boto3.resource('dynamodb')
    table_name = os.environ.get("DYNAMODB_TABLE_NAME")
    table = dynamodb.Table(table_name)

    item = {
        'taskId': ecs_task_id,
        'authorizationToken': authorization_token,
        'adoPipelineCallbackURL': ado_callback_url,
        'adoTaskId': ado_task_id,
        'adoJobId': ado_job_id,
        'ttl': int(time()) + 86400  # Item expires in 24 hours
    }

    table.put_item(Item=item)