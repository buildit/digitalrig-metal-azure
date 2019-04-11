# 9. Use Bash Scripts to Drive Rig Creation

Date: 2019-03-28

## Status

Accepted

## Context

Needed a way to create the rig in a automated way.

## Decision

Used bash scripts to call azure cli commands and curl requests to the Azure DevOps Services API 

## Consequences

Able to create the rig in an automataed way but no exception handling and user input is not well regulated
