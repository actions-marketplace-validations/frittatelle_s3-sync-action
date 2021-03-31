#!/bin/sh

set -e

if [ -z "$AWS_S3_BUCKET" ]; then
  echo "AWS_S3_BUCKET is not set. Quitting."
  exit 1
fi

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "AWS_ACCESS_KEY_ID is not set. Quitting."
  exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "AWS_SECRET_ACCESS_KEY is not set. Quitting."
  exit 1
fi

if [ -z "$AWS_SESSION_TOKEN" ]; then
  echo "AWS_SESSION_TOKEN is not set. Quitting."
  exit 1
fi

# Default to us-east-1 if AWS_REGION not set.
if [ -z "$AWS_REGION" ]; then
  AWS_REGION="us-east-1"
fi

# Override default AWS endpoint if user sets AWS_S3_ENDPOINT.
if [ -n "$AWS_S3_ENDPOINT" ]; then
  ENDPOINT_APPEND="--endpoint-url $AWS_S3_ENDPOINT"
fi

# Create a crdedentials file with session token
cat <<EOF >> ~/.aws/credentials
[s3-sync-action]
aws_access_key_id=${AWS_ACCESS_KEY_ID}
aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}
aws_session_token=${AWS_SESSION_TOKEN}
region
EOF
# config file
cat <<EOF >> ~/.aws/config
[profile s3-sync-action]
region=${AWS_REGION}
EOF


# Sync using our dedicated profile and suppress verbose messages.
# All other flags are optional via the `args:` directive.
sh -c "aws s3 sync ${SOURCE_DIR:-.} s3://${AWS_S3_BUCKET}/${DEST_DIR} \
              --profile s3-sync-action \
              --no-progress \
              ${ENDPOINT_APPEND} $*"

# Clear out credentials after we're done.
# We need to re-run `aws configure` with bogus input instead of
# deleting ~/.aws in case there are other credentials living there.
# https://forums.aws.amazon.com/thread.jspa?threadID=148833
cat <<EOF >> ~/.aws/credentials
[s3-sync-action]
aws_access_key_id=
aws_secret_access_key=
aws_session_token=
EOF
# config file
cat <<EOF >> ~/.aws/config
[profile s3-sync-action]
region=
EOF