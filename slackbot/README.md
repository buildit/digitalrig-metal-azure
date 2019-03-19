Build, Test, and Run Slackbot Container


    cd <workspace>/slackbot  
	DOCKER_BUILDKIT=1 docker build --target=final -t slackbot:latest .  
	docker run -d -p 4390:4390 -e SLACKBOT_OAUTHTOKEN="<oauthtoken>" -e SLACKBOT_VERIFICATIONTOKEN="<verificationtoken>" slackbot:latest  

  
The two tokens that are passed into the app are used to verify API requests.  Both tokens are registered with Slack for the app and will be sent with API requests. However, each serve a different purpose. The Verification token is used to validate Domain changes in slack. When the event url is changed [here](https://api.slack.com/apps/AG29FUH1U/event-subscriptions?), the bot will handle the request and echo the token back to validate communication.  The Oauth token is used by the app to validate all other API requests coming from Slack. 

SLACKBOT_VERIFICATIONTOKEN: https://api.slack.com/apps/AG29FUH1U/general?  
SLACKBOT_OAUTHTOKEN: https://api.slack.com/apps/AG29FUH1U/oauth?  
  
Once the app is running, Slack needs to be pointed at the running container. For running the app locally on your machine you can establish a tunnel to a port on your machine using NGROK. However, when you point slack at this local domain (step 4 below), the hosted app will no longer be receiving API events.  Note: This works for the time being, but if the bot/app gets higher usage, this local development and repointing of slack will not suffice.
1) Download NGROK to enable local development: https://ngrok.com/download  
2) Install it to /usr/local/bin or somewhere on your path  
3) Slackbot runs on port 4390, so you'd run ngrok in a terminal to expose that port on your machine ex. ngrok http 4390  
4) Grab the forwarding domain (ex. http://933d7ddb.ngrok.io) and use that as the domain name for the three different configurations in slack for events, interactions, and slash commands  
 - events:https://api.slack.com/apps/AG29FUH1U/event-subscriptions?  
 - interactions:https://api.slack.com/apps/AG29FUH1U/interactive-messages?  
 - slash commands:  https://api.slack.com/apps/AG29FUH1U/slash-commands?  
 
 
TODO: 

1)Need to host the application somewhere in the cloud.  
2)Add a help menu as we expand bot functionality and event processing. Currently if you mention the app (ex. @miles), the bot will just respond with "Hello"
