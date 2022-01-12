import boto3
import json
import os
import logging

from base64 import b64decode
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

SLACK_WEB_HOOK_URL = os.environ['SLACK_WEB_HOOK_URL']

def lambda_handler(event, context):
    
    eb = boto3.client('elasticbeanstalk')
    
    detail_type = event['detail-type']
    environment_name = event['detail']['EnvironmentName']
    application_name = event['detail']['ApplicationName']
    severity = event['detail']['Severity']
    message = event['detail']['Message']
    instances_id_message = ""
    
    eb_instance_health = eb.describe_instances_health(
        EnvironmentName=environment_name,
        AttributeNames=[
            'HealthStatus'
        ]
    )
    
    eb_all_instances = eb_instance_health['InstanceHealthList']
    unhealth_instances = list()

    for instance in eb_all_instances :
        if instance['HealthStatus'] == 'NoData'|'Unknown'|'Pending'|'Warning'|'Degraded'|'Severe'|'Suspended':
            unhealth_instances.append(instance['InstanceId'])

    unhealth_instances_id_message = "- Unhealth Instances ID : " + str(unhealth_instances)

    slack_message = {
        'text': 
            "```- Detail-type : %s\n- EnvironmentName : %s\n- ApplicationName : %s\n- Severity : %s\n- Message : %s\n%s```" 
            % (detail_type, environment_name, application_name, severity, message, unhealth_instances_id_message)
    }

    req = Request(SLACK_WEB_HOOK_URL, json.dumps(slack_message).encode('utf-8'))
    
    try:
        response = urlopen(req)
        response.read()
        logger.info("Message posted")
    except HTTPError as e:
        logger.error("Request failed: %d %s", e.code, e.reason)
    except URLError as e:
        logger.error("Server connection failed: %s", e.reason)  