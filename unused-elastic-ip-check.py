import boto3

client = boto3.client('ec2', region_name='ap-northeast-2')

addresses_dict = client.describe_addresses()
unused_eip = []
for eip_dict in addresses_dict['Addresses']:
    if "NetworkInterfaceId" not in eip_dict:
        unused_eip.append(eip_dict['PublicIp'])