#!/bin/bash

set -e

APP_NAME="$1"
AWS_ACCOUNT_ID="$2"

if [[ -z "$APP_NAME" || -z "$AWS_ACCOUNT_ID" ]]; then
  echo "Usage: $0 <app1|app2> <AWS_ACCOUNT_ID>"
  exit 1
fi

echo "Simulating rollback for $APP_NAME with AWS_ACCOUNT_ID $AWS_ACCOUNT_ID"

# Set the correct values.yaml path
if [ "$APP_NAME" = "app1" ]; then
  VALUES_PATH="charts/app1/values-${AWS_ACCOUNT_ID}.yaml"
elif [ "$APP_NAME" = "app2" ]; then
  VALUES_PATH="charts/app2/values-${AWS_ACCOUNT_ID}.yaml"
else
  echo "Unknown app: $APP_NAME"
  exit 1
fi

# Read versions from metadata files
LATEST_VERSION=$(yq e ".app.${APP_NAME}.latest_version" app-release-metadata.yaml)
LAST_SUCCESSFUL_VERSION=$(yq e ".app.${APP_NAME}.last_successful_version" app-release-metadata.yaml)
PREV_SUCCESSFUL_VERSION=$(echo $LAST_SUCCESSFUL_VERSION | awk -F. '{patch=$3-1; print $1"."$2"."patch}' | sed 's/\"//g')

LATEST_CHART_VERSION=$(yq e ".app.${APP_NAME}.latest_version" helm-release-metadata.yaml)
LAST_SUCCESSFUL_CHART_VERSION=$(yq e ".app.${APP_NAME}.last_successful_version" helm-release-metadata.yaml)
PREV_SUCCESSFUL_CHART_VERSION=$(echo $LAST_SUCCESSFUL_CHART_VERSION | awk -F. '{patch=$3-1; print $1"."$2"."patch}' | sed 's/\"//g')

echo "Updating $VALUES_PATH with image tag: $LAST_SUCCESSFUL_VERSION"
yq e -i ".${APP_NAME}.image.tag = strenv(LAST_SUCCESSFUL_VERSION)" "$VALUES_PATH"

echo "Updating app-release-metadata.yaml for $APP_NAME"
yq e -i ".app.${APP_NAME}.last_failed_version = strenv(LATEST_VERSION)" app-release-metadata.yaml
yq e -i ".app.${APP_NAME}.latest_version = strenv(LAST_SUCCESSFUL_VERSION)" app-release-metadata.yaml
yq e -i ".app.${APP_NAME}.last_successful_version = strenv(PREV_SUCCESSFUL_VERSION)" app-release-metadata.yaml

echo "Updating helm-release-metadata.yaml for $APP_NAME"
yq e -i ".app.${APP_NAME}.last_failed_version = strenv(LATEST_CHART_VERSION)" helm-release-metadata.yaml
yq e -i ".app.${APP_NAME}.latest_version = strenv(LAST_SUCCESSFUL_CHART_VERSION)" helm-release-metadata.yaml
yq e -i ".app.${APP_NAME}.last_successful_version = strenv(PREV_SUCCESSFUL_CHART_VERSION)" helm-release-metadata.yaml

echo "Done! Review the changes with 'git diff' or by inspecting the files." 