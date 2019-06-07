import boto3
from datetime import datetime, timedelta

def handler(event, context):
    ec2 = boto3.client("ec2", region_name = "us-west-2")
    for reservation in ec2.describe_instances(Filters =  [ { "Name": "tag:Name", "Values": [ "canary" ] } ])["Reservations"]:
        instanceIds = []
        for instance in reservation["Instances"]:
            instanceId = instance["InstanceId"]
            launchTime = instance["LaunchTime"].replace(tzinfo = None)
            lifeTime = timedelta(0, 8 * 3600)
            try:
                for tag in instance["Tags"]:
                    if tag["Key"] == "Lifetime":
                        lifeTime = timedelta(0, int(tag["Value"]) * 3600)
                        break
            except:
                pass
            dt = datetime.utcnow() - launchTime
            if dt > lifeTime:
                instanceIds.append(instanceId)
        if len(instanceIds):
            ec2.terminate_instances(InstanceIds = instanceIds)

if __name__ == "__main__":
    handler(None,None)
