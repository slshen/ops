import boto3
from datetime import datetime, timedelta

def handler(event, context):
    terminate_instances()
    terminate_load_balancers()

def terminate_instances():
    ec2 = boto3.client("ec2", region_name = "us-west-2")
    for result in \
        ec2.get_paginator("describe_instances") \
           .paginate(Filters =
                     [ { "Name": "tag:Name", "Values": [ "canary" ] } ]):
        for reservation in result["Reservations"]:
            instance_ids = []
            for instance in reservation["Instances"]:
                instance_id = instance["InstanceId"]
                launch_time = instance["LaunchTime"].replace(tzinfo = None)
                life_time = timedelta(0, 8 * 3600)
                try:
                    for tag in instance["Tags"]:
                        if tag["Key"] == "Lifetime":
                            life_time = timedelta(0, int(tag["Value"]) * 3600)
                            break
                except:
                    pass
                dt = datetime.utcnow() - launch_time
                if dt > life_time:
                    instance_ids.append(instance_id)
            if len(instance_ids):
                print("terminating", instance_ids)
                ec2.terminate_instances(InstanceIds = instance_ids)

def terminate_load_balancers():
    elb = boto3.client('elbv2')
    for result in elb.get_paginator("describe_load_balancers").paginate():
        load_balancers = {}
        for load_balancer in result["LoadBalancers"]:
            load_balancers[load_balancer["LoadBalancerArn"]] = load_balancer
        if len(load_balancers) == 0:
            continue
        for tags_description in elb.describe_tags(ResourceArns = list(load_balancers.keys()))["TagDescriptions"]:
            for tag in tags_description["Tags"]:
                if tag["Key"] == "Name" and tag["Value"].startswith("canary"):
                    load_balancer = load_balancers[tags_description["ResourceArn"]]
                    created_time = load_balancer["CreatedTime"].replace(tzinfo = None)
                    dt = datetime.utcnow() - created_time
                    if dt > timedelta(0, 8 * 60):
                        print("deleting", load_balancer["LoadBalancerArn"])
                        elb.delete_load_balancer(LoadBalancerArn = load_balancer["LoadBalancerArn"])

if __name__ == "__main__":
    handler(None,None)
