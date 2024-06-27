import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ec2_client = boto3.client('ec2')
sns_client = boto3.client('sns')

def lambda_handler(event, context):
    instance_id = "i-014b8c63d780df229"
    sns_topic_arn = "arn:aws:sns:us-east-1:339712706640:osmansns"
    try: 
        logger.info(f"ec2 restarting: {instance_id}")
        ec2_client.reboot_instances(InstanceIds=[instance_id])
        logger.info(f"instance restarted {instance_id}")
        message = f"instance {instance_id} restarted due to sumo logic"
        sns_client.publish(
            TopicArn=sns_topic_arn,
            Message=message,
            Subject="instance restarted"
        )
        logger.info(f"SNS topic{instance_id}")
    except Exception as e:
        logger.error(f"error got it: {str(e)} ")
        raise
    return {
        'statuscode':200,
        'body': f" {instance_id} restarted and {sns_topic_arn} sended"
    }
    