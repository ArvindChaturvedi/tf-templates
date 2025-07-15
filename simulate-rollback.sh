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

echo "VALUES_PATH: $VALUES_PATH"

# Read versions from metadata files
echo "Reading versions from app-release-metadata.yaml..."
LATEST_VERSION=$(yq e ".app.${APP_NAME}.latest_version" app-release-metadata.yaml)
LAST_SUCCESSFUL_VERSION=$(yq e ".app.${APP_NAME}.last_successful_version" app-release-metadata.yaml)
PREV_SUCCESSFUL_VERSION=$(echo "$LAST_SUCCESSFUL_VERSION" | awk -F. '{patch=$3-1; print $1"."$2"."patch}' | sed 's/\"//g')
echo "LATEST_VERSION: $LATEST_VERSION"
echo "LAST_SUCCESSFUL_VERSION: $LAST_SUCCESSFUL_VERSION"
echo "PREV_SUCCESSFUL_VERSION: $PREV_SUCCESSFUL_VERSION"

if [[ -z "$LATEST_VERSION" || -z "$LAST_SUCCESSFUL_VERSION" ]]; then
  echo "Error: One or more required version fields are blank in app-release-metadata.yaml. Aborting."
  exit 1
fi

echo "Reading versions from helm-release-metadata.yaml..."
LATEST_CHART_VERSION=$(yq e ".app.${APP_NAME}.latest_version" helm-release-metadata.yaml)
LAST_SUCCESSFUL_CHART_VERSION=$(yq e ".app.${APP_NAME}.last_successful_version" helm-release-metadata.yaml)
PREV_SUCCESSFUL_CHART_VERSION=$(echo "$LAST_SUCCESSFUL_CHART_VERSION" | awk -F. '{patch=$3-1; print $1"."$2"."patch}' | sed 's/\"//g')
echo "LATEST_CHART_VERSION: $LATEST_CHART_VERSION"
echo "LAST_SUCCESSFUL_CHART_VERSION: $LAST_SUCCESSFUL_CHART_VERSION"
echo "PREV_SUCCESSFUL_CHART_VERSION: $PREV_SUCCESSFUL_CHART_VERSION"

if [[ -z "$LATEST_CHART_VERSION" || -z "$LAST_SUCCESSFUL_CHART_VERSION" ]]; then
  echo "Error: One or more required version fields are blank in helm-release-metadata.yaml. Aborting."
  exit 1
fi

echo "Updating $VALUES_PATH with image tag: $LAST_SUCCESSFUL_VERSION"
echo "> yq e -i \".${APP_NAME}.image.tag = \"$LAST_SUCCESSFUL_VERSION\"\" \"$VALUES_PATH\""
yq e -i ".${APP_NAME}.image.tag = \"$LAST_SUCCESSFUL_VERSION\"" "$VALUES_PATH"

if [ -f "$VALUES_PATH" ]; then
  echo "Contents of $VALUES_PATH:"
  cat "$VALUES_PATH"
else
  echo "File $VALUES_PATH does not exist!"
fi

echo "Updating app-release-metadata.yaml for $APP_NAME"
echo "> yq e -i .app.${APP_NAME}.last_failed_version = \"$LATEST_VERSION\" app-release-metadata.yaml"
yq e -i ".app.${APP_NAME}.last_failed_version = \"$LATEST_VERSION\"" app-release-metadata.yaml
echo "> yq e -i .app.${APP_NAME}.latest_version = \"$LAST_SUCCESSFUL_VERSION\" app-release-metadata.yaml"
yq e -i ".app.${APP_NAME}.latest_version = \"$LAST_SUCCESSFUL_VERSION\"" app-release-metadata.yaml
echo "> yq e -i .app.${APP_NAME}.last_successful_version = \"$PREV_SUCCESSFUL_VERSION\" app-release-metadata.yaml"
yq e -i ".app.${APP_NAME}.last_successful_version = \"$PREV_SUCCESSFUL_VERSION\"" app-release-metadata.yaml

echo "Contents of app-release-metadata.yaml:"
cat app-release-metadata.yaml

echo "Updating helm-release-metadata.yaml for $APP_NAME"
echo "> yq e -i .app.${APP_NAME}.last_failed_version = \"$LATEST_CHART_VERSION\" helm-release-metadata.yaml"
yq e -i ".app.${APP_NAME}.last_failed_version = \"$LATEST_CHART_VERSION\"" helm-release-metadata.yaml
echo "> yq e -i .app.${APP_NAME}.latest_version = \"$LAST_SUCCESSFUL_CHART_VERSION\" helm-release-metadata.yaml"
yq e -i ".app.${APP_NAME}.latest_version = \"$LAST_SUCCESSFUL_CHART_VERSION\"" helm-release-metadata.yaml
echo "> yq e -i .app.${APP_NAME}.last_successful_version = \"$PREV_SUCCESSFUL_CHART_VERSION\" helm-release-metadata.yaml"
yq e -i ".app.${APP_NAME}.last_successful_version = \"$PREV_SUCCESSFUL_CHART_VERSION\"" helm-release-metadata.yaml

echo "Contents of helm-release-metadata.yaml:"
cat helm-release-metadata.yaml

echo "Done! Review the changes with 'git diff' or by inspecting the files." 