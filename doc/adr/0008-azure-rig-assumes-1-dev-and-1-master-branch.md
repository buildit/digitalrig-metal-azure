# 8. Azure Rig assumes 1 dev and 1 master branch

Date: 2019-03-28

## Status

Accepted

## Context

There are a number of different branching strategies that a team can employ.  Whatever strategy is chosen, the Rig's pipelines must support and build them.  The most common branching strategies are Trunk-Based, GitHub flow, and GitFlow.

## Decision

The Azure Rig pipelines will create builds/deployments off of 2 branches: `dev` and `master`.  

## Consequences

* This begins to follow GitHub flow.
* The `dev` branch builds are tagged with `unstable` and are deployed to the Integration environment.
* The `master` branch bulids are tagged with `stable` and are deployed to the Staging then then Production environments.
* We might want to rename `dev` to `develop` which is the standard name in GitFlow.
* Initially the focus will be on mainline builds, but will look to utilizing PR, hotfix, and release builds.
* GitFlow can add complexity and potenitally incongruent with Continuous Integration/Deployment.