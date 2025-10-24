import requests
import base64

def project_id_to_name(collection_uri, project_id, authorization_token):
    collection_uri = collection_uri.rstrip('/')

    response = requests.get(
        f"{collection_uri}/{project_id}/_apis/projects/{project_id}?api-version=7.1-preview.4",
        headers={
            'Accept': 'application/json',
            'Authorization': 'Basic ' + str((base64.b64encode(bytes(':'+ authorization_token, 'ascii'))), 'ascii')
        }
    )
    if response.status_code == 200:
        return response.json().get('name', '')
    return None

def get_ado_pipeline_callback_url(collection_uri, project_id, hub_name, plan_id):
    collection_uri = collection_uri.rstrip('/')

    return f"{collection_uri}/{project_id}/_apis/distributedtask/hubs/{hub_name}/plans/{plan_id}/events?api-version=7.1-preview.1"

def send_ado_pipeline_callback(collection_uri, result, project_id, hub_name, plan_id, task_id, job_id, authorization_token):
    if result not in ['succeeded', 'failed']:
        raise ValueError("result must be either 'succeeded' or 'failed'")

    collection_uri = collection_uri.rstrip('/')
    ado_events_url = get_ado_pipeline_callback_url(collection_uri, project_id, hub_name, plan_id)

    response = requests.post(
        ado_events_url,
        headers={
            'Accept': 'application/json',
            'Authorization': 'Basic ' + str((base64.b64encode(bytes(':' + authorization_token, 'ascii'))), 'ascii')
        },

        json={
            'name': 'TaskCompleted',
            'taskId': task_id,
            'jobId': job_id,
            'result': result
        }
    )

    return response

