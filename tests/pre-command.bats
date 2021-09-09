#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

@test "ensure error on provider other than github" {
  export BUILDKITE_PIPELINE_PROVIDER="notgithub"

  run "$PWD/hooks/pre-command"

  assert_failure
  assert_output --partial "this plugin can only be used on piplines associated with"
}

@test "ensure early exit if not a PR-build" {
  export BUILDKITE_PIPELINE_PROVIDER="github"
  export BUILDKITE_PULL_REQUEST="false"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "this doesn't appear to be a PR-build"
}

@test "ensure early exit if not a PR-build, when variable is not set" {
  export BUILDKITE_PIPELINE_PROVIDER="github"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "this doesn't appear to be a PR-build"
}

@test "ensure error on unknown repository url format" {
  export BUILDKITE_PIPELINE_PROVIDER="github"
  export BUILDKITE_PULL_REQUEST="1"
  export BUILDKITE_REPO="git://gitlab.com:myorg/myrepo.git"

  run "$PWD/hooks/pre-command"

  assert_failure
  assert_output --partial "BUILDKITE_REPO variable has an unexpected format"
}

@test "ensure warning when no token source is set" {
  export BUILDKITE_PIPELINE_PROVIDER="github"
  export BUILDKITE_PULL_REQUEST="1"
  export BUILDKITE_REPO="git://github.com:myorg/myrepo.git"
  stub curl \
    '-f -Ss https://api.github.com/repos/myorg/myrepo/pulls/1 : echo -n {"labels":[]}'
  stub jq \
    '-r \[.labels\[\].name\]\ \|\ join\(\"\,\"\) : echo ""'

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "configuration is missing a valid 'token-from' stanza"

  unstub curl
  unstub jq
}

@test "ensure token is read from file" {
  export BUILDKITE_PIPELINE_PROVIDER="github"
  export BUILDKITE_PULL_REQUEST="1"
  export BUILDKITE_REPO="git://github.com:myorg/myrepo.git"
  export BUILDKITE_PLUGIN_GITHUB_PR_LABELS_TOKEN_FROM_FILE=/etc/issue

  stub curl \
    '-f -Ss -H @- https://api.github.com/repos/myorg/myrepo/pulls/1 : echo -n {"labels":[]}'
  stub jq \
    '-r \[.labels\[\].name\]\ \|\ join\(\"\,\"\) : echo ""'

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "reading github token from file"
  unstub curl
  unstub jq
}


@test "ensure token is read from env" {
  export BUILDKITE_PIPELINE_PROVIDER="github"
  export BUILDKITE_PULL_REQUEST="1"
  export BUILDKITE_REPO="git://github.com:myorg/myrepo.git"
  export BUILDKITE_PLUGIN_GITHUB_PR_LABELS_TOKEN_FROM_ENV=GITHUB_TOKEN
  export GITHUB_TOKEN=mytoken

  stub curl \
    '-f -Ss -H @- https://api.github.com/repos/myorg/myrepo/pulls/1 : echo -n {\"labels\":[]}'
  stub jq \
    '-r \[.labels\[\].name\]\ \|\ join\(\"\,\"\) : echo ""'

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "reading github token from env"

  unstub curl
  unstub jq
}


@test "ensure labels are correctly outputed" {
  export BUILDKITE_PIPELINE_PROVIDER="github"
  export BUILDKITE_PULL_REQUEST="1"
  export BUILDKITE_REPO="git://github.com:myorg/myrepo.git"

  stub curl \
    '-f -Ss https://api.github.com/repos/myorg/myrepo/pulls/1 : echo -n {\"labels\":[]}'
  stub jq \
    '-r \[.labels\[\].name\]\ \|\ join\(\"\,\"\) : echo "labelone,labeltwo"'

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "labels for PR #1 are: labelone,labeltwo"

  unstub curl
  unstub jq
}

@test "ensure labels published as meta-data" {
  export BUILDKITE_PIPELINE_PROVIDER="github"
  export BUILDKITE_PULL_REQUEST="1"
  export BUILDKITE_REPO="git://github.com:myorg/myrepo.git"
  export BUILDKITE_PLUGIN_GITHUB_PR_LABELS_PUBLISH_METADATA_KEY="myki"

  stub curl \
    '-f -Ss https://api.github.com/repos/myorg/myrepo/pulls/1 : echo -n {\"labels\":[]}'
  stub jq \
    '-r \[.labels\[\].name\]\ \|\ join\(\"\,\"\) : echo "labelone,labeltwo"'
  stub buildkite-agent \
    'meta-data set myki : echo'

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "publishing labels as meta-data key 'myki'"

  unstub curl
  unstub jq
  unstub buildkite-agent
}


@test "ensure labels published as env var" {
  export BUILDKITE_PIPELINE_PROVIDER="github"
  export BUILDKITE_PULL_REQUEST="1"
  export BUILDKITE_REPO="git://github.com:myorg/myrepo.git"
  export BUILDKITE_PLUGIN_GITHUB_PR_LABELS_PUBLISH_ENV_VAR="MYENV"

  stub curl \
    '-f -Ss https://api.github.com/repos/myorg/myrepo/pulls/1 : echo -n {\"labels\":[]}'
  stub jq \
    '-r \[.labels\[\].name\]\ \|\ join\(\"\,\"\) : echo "labelone,labeltwo"'

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "publishing labels as env var 'MYENV'"

  unstub curl
  unstub jq
}