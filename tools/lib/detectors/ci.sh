#!/usr/bin/env bash
# lib/detectors/ci.sh — CI/CD System Detectors
#
# SPECTRA v4.2.0 — https://github.com/Rynaro/SPECTRA
# License: CC BY-SA 4.0

detect_ci_github_actions() {
  [[ -d "${PROJECT_ROOT}/.github/workflows" ]] && echo "GitHub Actions"
}

detect_ci_gitlab() {
  [[ -f "${PROJECT_ROOT}/.gitlab-ci.yml" ]] && echo "GitLab CI"
}

detect_ci_circleci() {
  [[ -f "${PROJECT_ROOT}/.circleci/config.yml" ]] && echo "CircleCI"
}

detect_ci_jenkins() {
  [[ -f "${PROJECT_ROOT}/Jenkinsfile" ]] && echo "Jenkins"
}

detect_ci_bitbucket() {
  [[ -f "${PROJECT_ROOT}/bitbucket-pipelines.yml" ]] && echo "Bitbucket Pipelines"
}

detect_ci_azure_devops() {
  [[ -f "${PROJECT_ROOT}/azure-pipelines.yml" ]] && echo "Azure DevOps"
}

detect_ci_travis() {
  [[ -f "${PROJECT_ROOT}/.travis.yml" ]] && echo "Travis CI"
}

register_detector "ci" "github_actions" "detect_ci_github_actions"
register_detector "ci" "gitlab"         "detect_ci_gitlab"
register_detector "ci" "circleci"       "detect_ci_circleci"
register_detector "ci" "jenkins"        "detect_ci_jenkins"
register_detector "ci" "bitbucket"      "detect_ci_bitbucket"
register_detector "ci" "azure_devops"   "detect_ci_azure_devops"
register_detector "ci" "travis"         "detect_ci_travis"
