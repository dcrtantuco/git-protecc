#!/usr/bin/env bats

load '../node_modules/bats-support/load'
load '../node_modules/bats-assert/load'

AWESOME_REMOTE=$(mktemp -d)
AWESOME_REPO=$(mktemp -d)
BASE_DIR=$(dirname $BATS_TEST_DIRNAME)

setup() {
  cd $AWESOME_REPO
}

teardown() {
  echo "Deleting $AWESOME_REPO"
  rm -rf $AWESOME_REPO
}

initialize_git() {
  git init
  echo "AWESOME TEXT" > awesome.txt
  git add awesome.txt
  git commit -m "Initial commit"
}

@test 'git-protecc on git repo' {
  initialize_git

  run $BASE_DIR/bin/git-protecc

  assert_success
  assert_line --partial "npx git-protecc"

}

@test 'git-protecc on non git repo' {
  run $BASE_DIR/bin/git-protecc

  assert_failure
  assert_line --partial "git-protecc should be executed on a git repository"
}

@test 'git-protecc branch' {
  initialize_git

  run $BASE_DIR/bin/git-protecc branch

  assert_success
}

@test 'git-protecc branch add master' {
  initialize_git

  run $BASE_DIR/bin/git-protecc branch add master

  assert_success
  assert_line --partial "master"
}

@test 'git-protecc branch add kappa' {
  initialize_git

  run $BASE_DIR/bin/git-protecc branch add kappa

  assert_failure
  assert_line --partial "kappa is not a git branch"
}

@test 'git-protecc branch add develop master' {
  initialize_git
  git checkout -b develop

  run $BASE_DIR/bin/git-protecc branch add develop master

  assert_success
  assert_line --partial "develop"
  assert_line --partial "master"
}

@test 'git-protecc branch add copy pre-push hook' {
  initialize_git

  run $BASE_DIR/bin/git-protecc branch add master

  assert_success
  assert [ -e $AWESOME_REPO/.git/hooks/pre-push ]
}

@test 'git-protecc branch add backup existing pre-push hook' {
  initialize_git
  touch $AWESOME_REPO/.git/hooks/pre-push

  run $BASE_DIR/bin/git-protecc branch add master

  assert_success
  assert [ -e $AWESOME_REPO/.git/hooks/pre-push.old ]
  assert [ -e $AWESOME_REPO/.git/hooks/pre-push ]
}

@test 'git-protecc branch remove develop' {
  initialize_git
  git checkout -b develop
  $BASE_DIR/bin/git-protecc branch add develop

  run $BASE_DIR/bin/git-protecc branch remove develop

  assert_success
}

@test 'git-protecc branch remove kappa' {
  initialize_git
  git checkout -b kappa

  run $BASE_DIR/bin/git-protecc branch remove kappa
  assert_failure
}

@test 'git-protecc branch remove develop master' {
  initialize_git
  git checkout -b develop
  $BASE_DIR/bin/git-protecc branch add develop master

  run $BASE_DIR/bin/git-protecc branch remove develop master

  assert_success
}

@test 'git protecc --help' {
  initialize_git

  run $BASE_DIR/bin/git-protecc --help

  assert_success
  assert_line --partial "npx git-protecc"
}

@test 'git protecc --h' {
  initialize_git

  run $BASE_DIR/bin/git-protecc --h

  assert_success
  assert_line --partial "npx git-protecc"
}

@test 'git-protecc invalid args' {
  initialize_git

  run $BASE_DIR/bin/git-protecc invalid args

  assert_failure
  assert_line --partial "npx git-protecc invalid args is invalid"
}
