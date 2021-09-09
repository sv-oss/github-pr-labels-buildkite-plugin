# GitHub PR Labels Buildkite Plugin

Retrieve the labels associated with a GitHub Pull Request and publish them as environment variable and/or build meta-data.

Multiple labels will appear as comma-separated values.

## Pre-requisites for private repositories

When using with a private repository, a valid GitHub token (PAT) must be provided.
It can be provided either inside an environment variable or inside a file.
Other plugins can be used before this pluginddddd to set up the token.

## Examples

### Publish the labels as environment variable (public repository)

The comma-separated list of labels will be published in the `PULL_REQUEST_LABELS` environment variable.
The variable is accessible to all subsequent commands and plugins within the same step.

```yml
steps:
  - command: echo $$PULL_REQUEST_LABELS
    plugins:
      - sv-oss/github-pr-labels#v0.0.2:
          publish-env-var: PULL_REQUEST_LABELS
```

### Publish the labels as environment variable (private repository)

In this example a valid GitHub token has been pre-loaded inside the GITHUB_TOKEN environment variable

The comma-separated list of labels will be published in the `PULL_REQUEST_LABELS` environment variable.
The variable is accessible to all subsequent commands and plugins within the same step.

```yml
steps:
  - command: echo $$PULL_REQUEST_LABELS
    plugins:
      - sv-oss/github-pr-labels#v0.0.2:
          token-from:
            env: GITHUB_TOKEN
          publish-env-var: PULL_REQUEST_LABELS
```

### Publish the labels as build meta-data (private repository)

In this example a valid GitHub token has been pre-loaded inside the /etc/github/token file

The comma-separated list of labels will be available in the `pull-request-labels` meta-data key.
The meta-data key is accessible on all subsequent steps of the pipeline.

```yml
steps:
  - command: buildkite-agent meta-data get pull-request-labels
    plugins:
      - sv-oss/github-pr-labels#v0.0.2:
          token-from:
            file: /etc/github/token
          publish-metadata-key: pull-request-labels
  - wait: ~
  - command: buildkite-agent meta-data get pull-request-labels
```
## Configuration

### `token-from` (optional, {file | env})
Datasource for the github token. One of `file` or `env` subkeys must be provided
#### `file` (optional[mutually-exclusive with env], string)
File containing the github token
#### `env` (optional[mutually-exclusive with file], string)
Env var containing the github token


### `publish-env-var` (optional, string)
Enables publishing the labels in an environment variable of specified name

### `publish-metadata-key` (optional, string)
Enables publishing the labels in a build meta-data key of specified name

## Developing

To run the tests:

```shell
docker-compose run --rm tests
```

## Contributing

1. Fork the repo
2. Make the changes
3. Run the tests
4. Commit and push your changes
5. Send a pull request
