const { IncomingWebhook } = require('@slack/client');

const SLACK_DEV_CICD_MONITORING_WEBHOOK_URL = process.env.SLACK_DEV_CICD_MONITORING_WEBHOOK_URL;
const SLACK_PROD_CICD_MONITORING_WEBHOOK_URL = process.env.SLACK_PROD_CICD_MONITORING_WEBHOOK_URL;
const SLACK_TEST_CICD_MONITORING_WEBHOOK_URL = process.env.SLACK_TEST_CICD_MONITORING_WEBHOOK_URL;

let webhook;
const slackGroupCodes = {
  SQUERD : {
    A : 'xxxxxxxxxx',
    B : 'xxxxxxxxxx',
    C : 'xxxxxxxxxx',
    D : 'xxxxxxxxxx',
    E : 'xxxxxxxxxx'
  },
  TEAM : {
    IOT : 'S043RK0CQMV',
    BACKEND : 'S0358E4V4US',
    FRONTEND : 'S03B6LXRZ8V',
    DATAPLATFORM : 'S04463J6UP5',
    INFRASECURITY : 'S043ZHQF3HU',
    DEVOPS : 'S03QYSLJYP3'
  }
};

const statusCodes = {
  CANCELLED: {
    color: '#fbbc05',
    text: '빌드 취소' // 'Build cancelled'
  },
  FAILURE: {
    color: '#ea4335',
    text: '빌드 실패' //'Build failed'
  },
  INTERNAL_ERROR: {
    color: '#ea4335',
    text: '빌드 내부 오류' // 'Internal error encountered during build'
  },
  QUEUED: {
    color: '#fbbc05',
    text: '빌드 대기' // 'New build queued'
  },
  SUCCESS: {
    color: '#34a853',
    text: '빌드 성공' // 'Build successfully completed'
  },
  TIMEOUT: {
    color: '#ea4335',
    text: '빌드 타임아웃' // 'Build timed out'
  },
  WORKING: {
    color: '#34a853',
    text: '빌드 시작' // 'New build in progress'
  }
};

// createSlackMessage create a message from a build object.
const createSlackMessage = (build) => {
  const statusMessage = statusCodes[build.status].text;
  const cloudBuildId = build.id;
  const cloudBuildTriggerName = build.substitutions.TRIGGER_NAME
  const gitRepoName = build.substitutions.REPO_NAME
  const gitBranchName = build.substitutions.BRANCH_NAME;
  const commitSha = build.substitutions.SHORT_SHA;
  const logUrl = build.logUrl;
  const tags = build.tags
  let mention;

  if(tags.includes('PROD')){
    if(tags.includes('A')){
      mention = "<!subteam^" + slackGroupCodes.SQUERD['A'] + ">, " + "<!subteam^" + slackGroupCodes.TEAM.DEVOPS + ">";
    }else if(tags.includes('B')){
      mention = "<!subteam^" + slackGroupCodes.SQUERD['B'] + ">, " + "<!subteam^" + slackGroupCodes.TEAM.DEVOPS + ">";
    }else if(tags.includes('C')){
      mention = "<!subteam^" + slackGroupCodes.SQUERD['C'] + ">, " + "<!subteam^" + slackGroupCodes.TEAM.DEVOPS + ">";
    }else if(tags.includes('D')){
      mention = "<!subteam^" + slackGroupCodes.SQUERD['D'] + ">, " + "<!subteam^" + slackGroupCodes.TEAM.DEVOPS + ">";
    }else if(tags.includes('E')){
      mention = "<!subteam^" + slackGroupCodes.SQUERD['E'] + ">, " + "<!subteam^" + slackGroupCodes.TEAM.DEVOPS + ">";
    }else{
      mention = "<!subteam^" + slackGroupCodes.TEAM.DEVOPS + ">";
    }
  }else{
    mention = '';
  }

  const title = {
    type: 'section',
    text: {
      type: 'mrkdwn',
      text: `[ ${statusMessage} ] for Cloud Build Trigger Name: \`${cloudBuildTriggerName}\`` // ${enlightenServiceCodes.DEVOPS.members.join(" ")
    }
  };

  const buildStatus = {
    type: 'section',
    text: {
      type: 'mrkdwn',
      text: `*Build Log:* <${logUrl}|${cloudBuildId}>`
    }
  };

  const context = {
    type: 'context',
    elements: [
      {
        type: 'mrkdwn',
        text: `*Branch:* <https://github.com/solarconnect/${gitRepoName}/tree/${gitBranchName}|${gitBranchName}>`
      },
      {
        type: 'mrkdwn',
        text: `*Commit:* <https://github.com/solarconnect/${gitRepoName}/commit/${commitSha}|${commitSha}>`
      },
      {
        type: 'mrkdwn',
        text: `*Mention:* ${mention}`
      }
    ]
  };

  const message = {
    attachments: [
      {
        blocks: [
          title
        ],
        color: statusCodes[build.status].color
      }
    ]
  };

  if(build.status.includes('SUCCESS' || 'CANCELLED' || "FAILURE" || 'INTERNAL_ERROR' || 'TIMEOUT')){
    message.attachments[0].blocks.push(buildStatus);
    message.attachments[0].blocks.push(context);
  }

  return message;
}

// subscribe is the main function called by Cloud Functions.
exports.subscribe = (pubSubEvent, context) => {

  const build = pubSubEvent.data
      ? JSON.parse(Buffer.from(pubSubEvent.data, 'base64').toString())
      : null;

  if (build == null) {
    return;
  }

  const status = ['CANCELLED', 'QUEUED', 'WORKING', 'SUCCESS', 'FAILURE', 'INTERNAL_ERROR', 'TIMEOUT'];
  if (status.indexOf(build.status) === -1) {
    return;
  }

  const tags = build.tags;

  if (tags.includes('DEV')){
    webhook = new IncomingWebhook(SLACK_DEV_CICD_MONITORING_WEBHOOK_URL);
  }else if(tags.includes('PROD')){
    webhook = new IncomingWebhook(SLACK_PROD_CICD_MONITORING_WEBHOOK_URL);
  }else{
    webhook = new IncomingWebhook(SLACK_TEST_CICD_MONITORING_WEBHOOK_URL);
  }

  // Send message to Slack.
  const message = createSlackMessage(build);
  webhook.send(message);
};