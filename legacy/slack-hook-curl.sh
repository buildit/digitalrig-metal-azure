curl -u nicholas.galazzo@wipro.com:hhklxwv6nuxkdiekpdeqnfkkqgr2u2snmpvf2brhheh4qateoqdq https://dev.azure.com/rigtest/_apis/hooks/subscriptions?api-version=5.0 -H "Accept: application/json" -H "Content-type: application/json" -X POST -d '{
    "status": "enabled",
    "publisherId": "tfs",
    "eventType": "build.complete",
    "subscriber": null,
    "resourceVersion": null,
    "eventDescription": "Any completed build.",
    "consumerId": "slack",
    "consumerActionId": "postMessageToChannel",
    "actionDescription": null,
    "publisherInputs": {
      "buildStatus": "",
      "definitionName": "",
      "projectId": "e2eb2c17-9bef-4d0c-93a0-650bd0b2e28d",
      "tfsSubscriptionId": "9b03f034-368f-4155-ab95-cf3f43d9f18d"
    },
    "consumerInputs": {
      "url": "https://hooks.slack.com/services/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"
    },
    "_links": {
      "self": {
        "href": "https://dev.azure.com/rigtest/_apis/hooks/subscriptions/61358a3e-7ef0-4019-943f-9edcc18efe48"
      },
      "consumer": {
        "href": "https://dev.azure.com/rigtest/_apis/hooks/consumers/slack"
      },
      "actions": {
        "href": "https://dev.azure.com/rigtest/_apis/hooks/consumers/slack/actions"
      },
      "notifications": {
        "href": "https://dev.azure.com/rigtest/_apis/hooks/subscriptions/61358a3e-7ef0-4019-943f-9edcc18efe48/notifications"
      },
      "publisher": {
        "href": "https://dev.azure.com/rigtest/_apis/hooks/publishers/tfs"
      }
    }
  }’