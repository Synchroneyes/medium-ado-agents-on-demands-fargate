import boto3
import os
from logger import get_logger

def start_ecs_task(task_definition_arn, collection_uri, azp_token):

    task_definition_name = task_definition_arn.split('/')[-1].split(':')[0]
    subnet_ids = os.environ.get('SUBNETS_IDS', '').split(',')
    client = boto3.client('ecs')
    response = client.run_task(
        cluster=os.environ.get('ECS_CLUSTER_ARN'),
        taskDefinition=task_definition_arn,
        count=1,
        launchType='FARGATE',
        enableExecuteCommand=True,

        overrides={

            'containerOverrides': [
                {
                    'name': task_definition_name,
                    'environment': [
                        {
                            'name': 'agent_on_demands',
                            'value': 'true'
                        },
                        {
                            'name': 'AZP_URL',
                            'value': collection_uri
                        },
                        {
                            'name': 'AZP_TOKEN',
                            'value': azp_token
                        }
                    ]
                }
            ]
        },
        networkConfiguration={
            'awsvpcConfiguration': {
                'subnets': subnet_ids,
                'securityGroups' : [os.environ.get('ECS_SECURITY_GROUP_ID')],
                'assignPublicIp': 'ENABLED'
            },
            
        }
    )
    return response