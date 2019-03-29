# 7. Use Docker as the build manager

Date: 2019-03-27

## Status

Accepted

## Context

The Azure Rig needs a contract of sorts between the Rig Pipelines and the Application build steps.  Since these build steps are application/language specific, it's ideal if these steps are owned/versioned by the Application.  

## Decision

We will use `docker build` as the primary mechanism for building and running tests in our Azure DevOps pipelines.

## Consequences

* Docker provides a common interface from a Pipeline perspective as well as a Developer perspective.  Each applciation can control its dependencies and versions without assuming or requiring Pipeline Agents or Developers to install specific software on their machines.
* Docker supports [Multi-Stage Builds](https://docs.docker.com/develop/develop-images/multistage-build/) which provides a nice mechanism to build and run tests using an image that contains your buildchain tools, whilst producing final images that are much smaller.  See [Slackbot](https://github.com/buildit/slackbot/blob/master/Dockerfile) as an example.
* The biggest challenge is figuring out how to copy the generated test results out of the intermediate images and imported into the Pipeline (so they are easy to view).  At the time of writing, we copy those files to our Azure Storage account.  Again refer to [Slackbot](https://github.com/buildit/slackbot/blob/master/Dockerfile) which has an example of how we accomplish this.