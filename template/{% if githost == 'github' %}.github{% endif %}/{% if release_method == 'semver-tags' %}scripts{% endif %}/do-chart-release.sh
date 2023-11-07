#!/usr/bin/env bash

set -e

THISSCRIPT=$(basename $0)

DRYRUN="false"
RELEASED_CHANGES="false"

GITHUB_OUTPUT=${GITHUB_OUTPUT:-$(mktemp)}

# Modify for the help message
usage() {
  echo "${THISSCRIPT} command"
  echo "Executes the step command in the script."
  exit 0
}

fullrun() {
  PACKAGE_BASE="$1"
  if [[ -z "${PACKAGE_BASE}" ]]; then
    echo "Must provide a package base directory with fullrun command"
    exit 1
  fi

  # allow overriding the helm chart subdirectory
  HELM_CHART_SUB_DIR="chart"
  if ! [[ -z "$2" ]]; then
    HELM_CHART_SUB_DIR="$2"
  fi

  PACKAGE_DIR="${PACKAGE_BASE}/"
  HELM_CHART_DIR="${PACKAGE_DIR}${HELM_CHART_SUB_DIR}/"

  # Build the semver-tags command based on inputs
  COMMAND_STRING="./semver-tags run " # --github_action "
  if [[ "${DRYRUN}" == "true" ]]; then
    COMMAND_STRING+="--dry_run "
  fi
  # This just adds the webapp directory to the flags
  COMMAND_STRING+="--directories ${PACKAGE_DIR} "

  # We do a dry run first because we don't want tags to happen before we've updated the chart.yaml
  COMMAND_DRY="${COMMAND_STRING} --dry_run "
  RESULT=$($COMMAND_DRY)

  # Parse the results out to get the versions we need to update and the release notes
  PUBLISHED=$(yq -P ".New_release_published" <<< $RESULT)
  NEW_TAGS=$(yq -P ".New_release_git_tag" <<< $RESULT)
  LAST_TAGS=$(yq -P ".Last_release_version" <<< $RESULT)
  JSON_RELEASE_NOTES=$(yq -P ".New_release_notes_json" <<< $RESULT)
  RUNDATE=$(date +"%Y-%m-%d-%T")

  PUBLISHED_ARRAY=($(echo $PUBLISHED | tr "," "\n"))
  NEW_TAGS_ARRAY=($(echo $NEW_TAGS | tr "," "\n"))
  LAST_TAGS_ARRAY=($(echo $LAST_TAGS | tr "," "\n"))
  # This makes a run specific release not json file
  # this will also be added only if there's a version to change
  
  # For every new tag, update the chart.yaml
  for i in "${!NEW_TAGS_ARRAY[@]}"; do
    if [[ "${PUBLISHED_ARRAY[i]}" == "false" ]]; then
      continue
    fi
    # If we're here, we have a thing to publish
    RELEASED_CHANGES="true"
    IFS='/' read -r DIR NEW_TAG <<< ${NEW_TAGS_ARRAY[i]}
    LAST_VERSION=${LAST_TAGS_ARRAY[i]}
    NEW_VERSION=${NEW_TAG#*v}
    
    # Now update all the things
    # We use the "ci:" prefix because it doesn't count as a version bump
    # but we do need to tag all these and commit the changes. We could break this up to a second loop I guess.
    if [[ "${DRYRUN}" == "true" ]]; then
      echo "Would be changing version $LAST_VERSION to $NEW_VERSION in ${HELM_CHART_DIR}Chart.yaml"
      echo "Would run :"
      echo " > git add \"${HELM_CHART_DIR}Chart.yaml\""
      echo " > git commit -m \"ci: adding version ${NEW_TAG} to ${HELM_CHART_DIR}Chart.yaml\""
    else
      echo "Changing version $LAST_VERSION to $NEW_VERSION in ${HELM_CHART_DIR}Chart.yaml"
      # replace both version and appVersion in the Chart.yaml
      sed -i "s/^\(\(app\)\?[vV]ersion\):.*/\1: ${NEW_VERSION}/" "${HELM_CHART_DIR}Chart.yaml"
      git add "${HELM_CHART_DIR}Chart.yaml"
      git commit -m "ci: adding version ${NEW_TAG} to ${HELM_CHART_DIR}Chart.yaml"
    fi
  done
  
  if [[ "${DRYRUN}" == "true" ]]; then
    echo "Would git push here"
  else
    RESULT=$($COMMAND_STRING)
    git push
  fi

  echo "RELEASED_CHANGES=${RELEASED_CHANGES}"
  echo "NEW_VERSION=${NEW_VERSION}"

  echo "RELEASED_CHANGES=${RELEASED_CHANGES}" >> $GITHUB_OUTPUT
  echo "NEW_VERSION=${NEW_VERSION}" >> $GITHUB_OUTPUT
}

dryrun() {
  DRYRUN="true"
  fullrun "$@"
}

# This should be last in the script, all other functions are named beforehand.
case "$1" in
  "dryrun")
    shift
    dryrun "$@"
    ;;
  "fullrun")
    shift
    fullrun "$@"
    ;;
  *)
    usage
    ;;
esac

exit 0
