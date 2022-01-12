import boto3
import os
import json
import smtplib
import requests

from datetime import datetime, timedelta
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email.encoders import encode_base64
from subprocess import call

# Set up secret manager
SECRETMANAGER = boto3.client('secretsmanager')
SECRETMANAGER_VALUES = SECRETMANAGER.get_secret_value(
    SecretId = os.environ['SECRET_ID']
)
NEWRELIC_AUTOMATION_ENV = json.loads(SECRETMANAGER_VALUES['SecretString'])

# Set up newrelic
NERDGRAPH_URL = os.environ['NERDGRAPH_URL']
APM_AVERGE_TIME_GUID = NEWRELIC_AUTOMATION_ENV['APM_AVERGE_TIME_GUID']
APM_THROUGHPUT_GUID = NEWRELIC_AUTOMATION_ENV['APM_THROUGHPUT_GUID']
DB_TABLE_SLOWEST_QUERY_TIME_GUID = NEWRELIC_AUTOMATION_ENV['DB_TABLE_SLOWEST_QUERY_TIME_GUID']
DB_TABLE_THROUGHPUT_GUID = NEWRELIC_AUTOMATION_ENV['DB_TABLE_THROUGHPUT_GUID']
NEWRELIC_API_KEY = NEWRELIC_AUTOMATION_ENV['NEWRELIC_API_KEY']

# Set up datetime
DATETIME_TODAY = datetime.today()
TIME_DIFFRENCE = 32400000 # 9h(KST = UTC + 9h)
WEEK = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
WEEK_NUM = DATETIME_TODAY.weekday()
DAILY_DURATION = 1
WEEKLY_DURATION = 7
WEEKLY_REPORTING_DAY = "WED"

# Set up file & directory
LOCAL_DIR_PATH = '/tmp'
REPORT_TYPE_DAILY = 'daily'
REPORT_TYPE_WEEKLY = 'weekly'

# Set up s3
BUCKET_NAME = os.environ['BUCKET_NAME']

# Set up users for email
USER_EMAIL = os.environ['USER_EMAIL']
USER_CERTIFICATION_NUM= NEWRELIC_AUTOMATION_ENV['USER_CERTIFICATION_NUM']
RECIPIENTS = os.environ['RECIPIENTS']
SENDER_NAME = os.environ['SENDER_NAME']

def get_datetime(duration: int) :
    begin_date = (DATETIME_TODAY - timedelta(duration))
    begin_time = {
        'date' :  begin_date.strftime('%Y%m%d'),
        'year' : begin_date.year,
        'month' : begin_date.month,
        'day' : begin_date.day,
        'timestamp' : (int(datetime(begin_date.year, begin_date.month, begin_date.day, 0, 0, 0, 0).timestamp()) * 1000) - TIME_DIFFRENCE
    }

    end_date = (DATETIME_TODAY - timedelta(1))
    end_time = {
        'date' : end_date.strftime('%Y%m%d'),
        'year' : end_date.year,
        'month' : end_date.month,
        'day' : end_date.day,
        'timestamp' : (int(datetime(end_date.year, end_date.month, end_date.day, 23, 59, 59, 999999).timestamp()) * 1000) - TIME_DIFFRENCE
    }

    return begin_time, end_time

def get_newrelic_report_filename(report_type: str, begin_datetime: str, end_datetime: str):

    if report_type == REPORT_TYPE_DAILY:
        return {
            'apm_response_time' : f'{begin_datetime}_apm_response_time.pdf',
            'apm_throughput' : f'{begin_datetime}_apm_throughput.pdf',
            'db_table_slowest_query_time' : f'{begin_datetime}_db_table_slowest_query_time.pdf',
            'db_table_throughput_guid' : f'{begin_datetime}_db_table_throughput_guid.pdf'
        }
    else:
        return {
            'apm_response_time' : f'{begin_datetime}-{end_datetime}_apm_response_time.pdf',
            'apm_throughput' : f'{begin_datetime}-{end_datetime}_apm_throughput.pdf',
            'db_table_slowest_query_time' : f'{begin_datetime}-{end_datetime}_db_table_slowest_query_time.pdf',
            'db_table_throughput_guid' : f'{begin_datetime}-{end_datetime}_db_table_throughput_guid.pdf'
        }

def write_newrelic_report_to_file(guid: str, file_name: str, begin_time_timestamp: datetime, end_time_timestamp: datetime):

    value = '''mutation {
      dashboardCreateSnapshotUrl(guid: "%s", params: {timeWindow: {beginTime: %d, endTime: %d}})
    }''' %(guid, begin_time_timestamp, end_time_timestamp)

    payload = { 'query': value }

    headers = { 'Content-Type': 'application/json', 'API-Key': NEWRELIC_API_KEY }

    resonpse = requests.post(NERDGRAPH_URL, data=json.dumps(payload), headers=headers)
    dashboard_create_snapshot_url = resonpse.json()['data']['dashboardCreateSnapshotUrl']

    os.chdir('/tmp')

    daily_report = requests.get(dashboard_create_snapshot_url, allow_redirects=True)
    
    with open(file_name, 'wb') as f:
        f.write(daily_report.content)

def post_report_to_s3(bucket_dir_path: str, filenames: str):

  s3 = boto3.resource('s3')
  bucket = s3.Bucket(BUCKET_NAME)

  for file in filenames:
      bucket.upload_file(file, bucket_dir_path + os.path.basename(file)) 

def get_mail_content(begin_time: dict, end_time: dict):

    return {
        'subject' : f'''
        [{begin_time["year"]}.{begin_time["month"]}.{begin_time["day"]}~{end_time["year"]}.{end_time["month"]}.{end_time["day"]}] 서비스 모니터링 위클리 레포트
        ''',
        'text' : f'''
        안녕하세요, DevOps 팀 {SENDER_NAME} 입니다.<br>
        <br>
        {begin_time["year"]}년 {begin_time["month"]}월 {begin_time["day"]}일 ~ {end_time["year"]}년 {end_time["month"]}월 {end_time["day"]}일 한 주 동안의 prod 서비스 처리량, 응답시간 기준 레포트 첨부해드립니다.<br>
        (appback 서비스는 현재 네이밍 이슈로 apm이 정상적으로 잡히지 않고 있어서 제외하고 봐주시면 감사할 것 같습니다.)<br>
        <br>
        감사합니다.<br>
        ---<br>
        {SENDER_NAME}<br>
        DevOps/SRE<br>
        ''' 
    }

def post_mail_with_newrelic_report(content: dict, filenames: str):

   msg = MIMEMultipart()
   msg['From'] = USER_EMAIL
   msg['To'] = RECIPIENTS
   msg['Subject'] = content['subject']

   bodyPart = MIMEText(content['text'], 'html', 'utf-8')
   msg.attach(bodyPart)

   # Get all the attachments
   for file in filenames:
      part = MIMEBase('application', 'octet-stream')
      part.set_payload(open(file, 'rb').read())
      encode_base64(part)
      part.add_header('Content-Disposition', 'attachment; filename="%s"' % os.path.basename(file))  # file
      msg.attach(part)

   mailServer = smtplib.SMTP("smtp.gmail.com", 587)
   mailServer.ehlo()
   mailServer.starttls()
   mailServer.ehlo()
   mailServer.login(USER_EMAIL, USER_CERTIFICATION_NUM)
   mailServer.sendmail(msg['From'], RECIPIENTS.split(', '), msg.as_string())

   mailServer.quit()

def process_newrelic_report_to_s3(report_type: str, begin_time: dict, end_time: dict):  

    filename = get_newrelic_report_filename(report_type, begin_time['date'], end_time['date'])
    bucket_dir_path = f'newrelic-{report_type}-report/{begin_time["year"]}/{begin_time["month"]}/'

    write_newrelic_report_to_file(APM_AVERGE_TIME_GUID, filename['apm_response_time'], begin_time['timestamp'], end_time['timestamp'])
    write_newrelic_report_to_file(APM_THROUGHPUT_GUID, filename['apm_throughput'], begin_time['timestamp'], end_time['timestamp'])
    write_newrelic_report_to_file(DB_TABLE_SLOWEST_QUERY_TIME_GUID, filename['db_table_slowest_query_time'], begin_time['timestamp'], end_time['timestamp'])
    write_newrelic_report_to_file(DB_TABLE_THROUGHPUT_GUID, filename['db_table_throughput_guid'], begin_time['timestamp'], end_time['timestamp'])

    filenames = [os.path.join(LOCAL_DIR_PATH, f) for f in os.listdir(LOCAL_DIR_PATH)]
    
    post_report_to_s3(bucket_dir_path, filenames)
    
def lambda_handler(event, context):

    begin_time, end_time = get_datetime(DAILY_DURATION)
    
    process_newrelic_report_to_s3(REPORT_TYPE_DAILY, begin_time, end_time)
    call('rm -rf /tmp/*', shell=True)

    if WEEK[WEEK_NUM] == WEEKLY_REPORTING_DAY:
        begin_time, end_time = get_datetime(WEEKLY_DURATION)

        process_newrelic_report_to_s3(REPORT_TYPE_WEEKLY, begin_time, end_time)

        content = get_mail_content(begin_time, end_time)
        filenames = [os.path.join(LOCAL_DIR_PATH, f) for f in os.listdir(LOCAL_DIR_PATH)]
        post_mail_with_newrelic_report(content, filenames)