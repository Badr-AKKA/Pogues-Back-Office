#!/usr/bin/env bash
#title           :gitbook.sh
#description     :This script generates gitbook documentation on a travis build
#author		     :a-cordier
#==============================================================================
#
#set -e

DOC_FOLDER="docs"
MAIN_BRANCH="zenika-dev"
UPSTREAM="https://$GITHUB_TOKEN@github.com/$TRAVIS_REPO_SLUG.git"
MESSAGE="Auto release from $USER: build $TRAVIS_BUILD"
AUTHOR="$USER <>"
VERSION=$(mvn help:evaluate -Dexpression=project.version | grep -v '\[')
TAG="v$VERSION"

if [ "$TRAVIS_PULL_REQUEST" != "false" ];then
  echo "Won't tag on pull request"
  exit 0
fi

if [ "$TRAVIS_BRANCH" != "$MAIN_BRANCH" ];then
  echo "Won't tag: Not on branch $MAIN_BRANCH"
  exit 0
fi

if [[ -n "$TRAVIS_TAG" ]];then
  echo "Won't tag: Already on tag $TRAVIS_TAG"
  exit 0
fi

function is_patch(){
  if [[ -n "$(git tag -l)" ]];then
    latest_tag=$(git describe --tags `git rev-list --tags --max-count=1` 2>&1 >/dev/null)
  fi
  if [ "$latestTag" == "v${VERSION}" ]; then
    return 1
  else
    return 0
  fi
}

function tag() {
    : ${VERSION?Cannot tag if no version}
    git config --global user.email "travis@travis-ci.org"
    git config --global user.name "Travis"
    git tag --annotate ${TAG} -m ${MESSAGE}
    git push "$UPSTREAM" --tags
    git fetch origin
}

function main(){
    is_patch && tag
}

main