# NewRelic-Dashboard-Reporting-Automation
NerdGraph API를 활용한 Python Script를 통해 NewRelic Dashboard Reporting 자동화 스크립트.

# 프로젝트 소개
NerdGraph API를 활용하여 NewRelic Dashboard Mail Reporting 자동화 Python Script 입니다.
New Relic은 SaaS 기반의 APM(Application Performance Management) 서비스를 제공하는 프로덕트입니다.
NewRelic을 통해 서비스 Throughput, Request Average Time, Slow Query 등 Dashboard를 생성하였고, 해당 Dashboard를 주기적으로 담당자분들께 레포팅을 하기 위한 목적으로 NewRelic Dashboard Mail Reporting 자동화 스크립트를 구현하였습니다.

# 주요 기능
1. 주기적으로 일 단위 Dashboard Daily Report PDF파일을 S3에 저장합니다.
2. 주기적으로 주 단위 Dashboard Weekly Report PDF파일을 S3에 저장합니다.
3. 주기적으로 서비스 담당자들을 대상으로 Dashboard Weekly Report를 메일로 공유합니다.

# 기술 스택
- AWS, NerdGraph API, Python