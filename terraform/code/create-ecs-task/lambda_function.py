import boto3
import json
import os
import base64

import ecs
import ado


from logger import get_logger
from dynamodb import write_to_dynamodb

ADO_PIPELINE_FAILED_STATUS = 'failed'
ADO_PIPELINE_SUCCEEDED_STATUS = 'succeeded'
ADO_AGENT_ON_DEMAND_CAPABILITY = 'agent_on_demands'

def get_authentication_secret():
    secret_arn = os.environ.get("ADO_AUTHENTICATION_PASSWORD")
    if not secret_arn:
        raise ValueError("Environment variable ADO_AUTHENTICATION_PASSWORD is not set")

    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId=secret_arn)
    secret = json.loads(response['SecretString'])
    return secret['password']

def base64_decode(data):
    return base64.b64decode(data).decode('utf-8')

def get_access_denied_response():
    return {
        'statusCode': 403,
        'body': json.dumps('Forbidden: Invalid credentials')
    }

def get_authorization_passed_password(headers):
    authorization = headers.get('Authorization', '')
    if not authorization.startswith('Basic '):
        return None
    
    password = base64_decode(authorization.split(' ')[1])
    if password and password[0] == ':':
        password = password[1:]
    return password

def fetch_pat_token():
    secret_arn = os.environ.get("ADO_TOKEN_ARN")
    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId=secret_arn)
    secret = json.loads(response['SecretString'])
    return secret['azure-devops-secret-token']


def lambda_handler(event, context):

    logger = get_logger()

    try:
        print(json.dumps(event))
    
        authorization = event['headers'].get('Authorization', '')
        project_id = event['headers'].get('ProjectId', '')
        hub_name = event['headers'].get('HubName', '')
        plan_id = event['headers'].get('PlanId', '')
        task_id = event['headers'].get('TaskInstanceId', '')
        job_id = event['headers'].get('JobId', '')
        authorization_token = event['headers'].get('AuthToken', '')
        stage_name = event['headers'].get('StageName', '')
        build_id = event['headers'].get('BuildId', '')
        collection_uri = event['headers'].get('CollectionUri', '')

        pat_token = fetch_pat_token()

        if not all([project_id, hub_name, plan_id, task_id, job_id, authorization_token]):
            return get_access_denied_response()

        if not authorization.startswith('Basic '):
            ado.send_ado_pipeline_callback(collection_uri, ADO_PIPELINE_FAILED_STATUS, project_id, hub_name, plan_id, task_id, job_id, authorization_token)
            return get_access_denied_response()

        password = get_authentication_secret()
        received_password = get_authorization_passed_password(event['headers'])

        if password != received_password:
            ado.send_ado_pipeline_callback(collection_uri, ADO_PIPELINE_FAILED_STATUS, project_id, hub_name, plan_id, task_id, job_id, authorization_token)
            return get_access_denied_response()
        
        project_name = ado.project_id_to_name(collection_uri, project_id, authorization_token)

        logger.info(f"Project Name: {project_name}")
        logger.info(f"Project ID: {project_id}")
        logger.info(f"Hub Name: {hub_name}")
        logger.info(f"Plan ID: {plan_id}")
        logger.info(f"Task ID: {task_id}")
        logger.info(f"Job ID: {job_id}")
        logger.info(f"Stage Name: {stage_name}")

        ecs_response = ecs.start_ecs_task(os.environ.get("AGENT_TASK_DEFINITION_ARN"), collection_uri, pat_token)
        ecs_task_id = ecs_response['tasks'][0]['taskArn'].split('/')[-1]
        ado_callback_url = ado.get_ado_pipeline_callback_url(collection_uri, project_id, hub_name, plan_id)

        write_to_dynamodb(ecs_task_id, authorization_token, ado_callback_url, task_id, job_id)        

        return {
            'statusCode': 200,
            'body': json.dumps('Request processed successfully, ECS task started')
        }
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e)
            })
        }