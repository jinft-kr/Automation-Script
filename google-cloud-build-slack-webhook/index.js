const { IncomingWebhook } = require('@slack/client');
const SLACK_WEBHOOK_URL = process.env.SLACK_WEBHOOK_URL;

const webhook = new IncomingWebhook(SLACK_WEBHOOK_URL);

const statusCodes = {
  CANCELLED: {
    color: '#fbbc05',
    text: 'Build cancelled'
  },
  FAILURE: {
    color: '#ea4335',
    text: 'Build failed'
  },
  INTERNAL_ERROR: {
    color: '#ea4335',
    text: 'Internal error encountered during build'
  },
  QUEUED: {
    color: '#fbbc05',
    text: 'New build queued'
  },
  SUCCESS: {
    color: '#34a853',
    text: 'Build successfully completed'
  },
  TIMEOUT: {
    color: '#ea4335',
    text: 'Build timed out'
  },
  WORKING: {
    color: '#34a853',
    text: 'New build in progress'
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

  return {
    text: `${statusMessage} for Cloud Build Trigger Name: \`${cloudBuildTriggerName}\` \nRepo Name : \`${gitRepoName}\` Git Branch : \`${gitBranchName}\``,
    blocks: [
      {
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: `${statusMessage} for *${build.projectId}*.`
        }
      }
    ],
    attachments: [
      {
        blocks: [
          {
            type: 'section',
            text: {
              type: 'mrkdwn',
              text: `*Build Log:* <${logUrl}|${cloudBuildId}>`
            }
          },
          {
            type: 'context',
            elements: [
              {
                type: 'mrkdwn',
                text: `*Branch:* <https://github.com/solarconnect/${gitBranchName}/tree/${gitBranchName}|${gitBranchName}>`
              },
              {
                type: 'mrkdwn',
                text: `*Commit:* <https://github.com/solarconnect/${gitRepoName}/commit/${commitSha}|${commitSha}>`
              }
            ]
          }
        ],
        color: statusCodes[build.status].color
      }
    ]
  };
}

// subscribe is the main function called by Cloud Functions.
exports.subscribe = (pubSubEvent, context) => {

  const build = pubSubEvent.data
      ? JSON.parse(Buffer.from(pubSubEvent.data, 'base64').toString())
      : null;

  if (build == null) {
    return;
  }

  console.log("pubSubEvent.data: ", build);

  const status = ['CANCELLED', 'QUEUED', 'WORKING', 'SUCCESS', 'FAILURE', 'INTERNAL_ERROR', 'TIMEOUT'];
  if (status.indexOf(build.status) === -1) {
    return;
  }

  // Send message to Slack.
  const message = createSlackMessage(build);
  webhook.send(message);

  const msg = createSlackMessage(pubSubEvent);
  webhook.send(msg)
};