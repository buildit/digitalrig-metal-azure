# 6. Use Buildit Slackbot as our example application

Date: 2019-03-27

## Status

Accepted

## Context

Rigs are only as valuable as the applications that run on them.  We need an application for which we can create pipelines.

## Decision

This rig will use the [Buildit Slackbot](https://github.com/buildit/slackbot/) as our first app to deploy on the Azure rig.

## Consequences

* Buildit Slackbot is written in Golang.  It's definitely not a first class platform in Azure.  It probably is a better candidate as a Serverless application as well.