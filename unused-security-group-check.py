import boto3
        
client = boto3.client('ec2')
ec2 = boto3.resource('ec2')
all_security_groups_id = []
used_security_groups_id = []

# Get ALL security groups names
security_groups_dict = client.describe_security_groups()
security_groups = security_groups_dict['SecurityGroups']

for groupobj in security_groups:
    if groupobj['GroupName'] == 'default' or groupobj['GroupName'].startswith('d-') or groupobj['GroupName'].startswith('AWS-OpsWorks-'):
        used_security_groups_id.append(groupobj['GroupId'])
    all_security_groups_id.append(groupobj['GroupId'])

# Get all security groups used by instances
instances_dict = client.describe_instances()
reservations = instances_dict['Reservations']
network_interface_count = 0

for i in reservations:
    for j in i['Instances']:
        for k in j['SecurityGroups']:
            if k['GroupId'] not in used_security_groups_id:
                used_security_groups_id.append(k['GroupId'])
                
# Security Groups in use by Network Interfaces				
eni_client = boto3.client('ec2')
eni_dict = eni_client.describe_network_interfaces()
for i in eni_dict['NetworkInterfaces']:
    for j in i['Groups']:
        if j['GroupId'] not in used_security_groups_id:
            used_security_groups_id.append(j['GroupId'])

# Security groups used by classic ELBs
elb_client = boto3.client('elb')
elb_dict = elb_client.describe_load_balancers()
for i in elb_dict['LoadBalancerDescriptions']:
    for j in i['SecurityGroups']:
        if j not in used_security_groups_id:
            used_security_groups_id.append(j)
    
# Security groups used by ALBs
elb2_client = boto3.client('elbv2')
elb2_dict = elb2_client.describe_load_balancers()
for i in elb2_dict['LoadBalancers']:
    for j in i['SecurityGroups']:
        if j not in used_security_groups_id:
            used_security_groups_id.append(j)
    
# Security groups used by RDS
rds_client = boto3.client('rds')
rds_dict = rds_client.describe_db_instances()
for i in rds_dict['DBInstances']:
    for j in i['VpcSecurityGroups']:
        if j['VpcSecurityGroupId'] not in used_security_groups_id:
            used_security_groups_id.append(j['VpcSecurityGroupId'])
            
unused_security_groups_id = []
for group in all_security_groups_id:
    if group not in used_security_groups_id:
        unused_security_groups_id.append(group)