# 3. Use Azure DevOps for CI/CD

Date: 2019-03-27

## Status

Accepted

## Context

We desire to have a hosted/PaaS CI/CD solution.

## Decision

* Use Microsoft Azure DevOps (formerly Visual Studio Team Services) for build and release pipelines

## Consequences

* Azure DevOps CLI doesn't support creation of pipelines.  We will have to use REST APIs.
* Azure DevOps is a separate product outside of Azure (even though they share the name Azure and both from Microsoft).
* We will assume that an Azure DevOps organization has already been created and users are assigned roles/access.
* The current thinking is that there will be 1 Rig for each Azure DevOps Project.  There can be multiple Applications (repositories) per Azure DevOps project.  For example, for Bookit, we'd expect 1 "Bookit" Azure DevOps project which contains 1 instance of the Azure rig, as well as 1 CI/CD Pipeline for each bookit-api and bookit-client-react.
* Azure DevOps distinguishes between "Build" and "Release" pipelines.