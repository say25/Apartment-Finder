# Apartment Finder

An application that polls and API to check for an available apartment matching specific criteria.

## High Level Overview

- Lambda function is invoked by CRON
  - Daytime (9am-9pm) - Every 5 minutes
  - Evening (9pm-9am) - Every 15 minutes
- Lambda function executes
    1. Queries apartment API
    1. Sends 2 metrics to CloudWatch
        1. Total Units Available
        1. Units Matching Criteria  
- CloudWatch Alarms Watch exist for the following conditions
    1. Are there any matching units?
        - If so send a PagerDuty alert to notify interested party that there is a unit available
    1. Lambda function executing successfully?
        - If not send a PagerDuty alert to notify developer that function is not executing correctly
    1. Lambda function being invoked?
        - If not send a PagerDuty alert to notify developer that function is not executing correctly

## Infrastructure

This application is Terraformed. If creating from scratch, this application will upload an empty lambda function. The developer will need to upload the code afterwards.

## Documentation

Additional documentation lives in the [docs folder](/docs).
