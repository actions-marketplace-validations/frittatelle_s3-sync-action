# GitHub Action to Sync S3 Bucket 🔄

This simple action uses the [vanilla AWS CLI](https://docs.aws.amazon.com/cli/index.html) to sync a directory (either from your repository or generated during your workflow) with a remote S3 bucket.

The project is based on https://github.com/jakejarvis/s3-sync-action but the entrypoint file is modified so that the profile in ~/.aws/credentials contains also the session token.

Specify AWS_SESSION_TOKEN from the Vocareum platform in github secrets
