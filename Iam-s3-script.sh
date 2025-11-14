BUCKET_ARN="arn:aws:s3:::your-bucket-name"

aws iam list-policies --scope Local --query 'Policies[*].Arn' --output text | \
while read policy_arn; do
  version_id=$(aws iam list-policy-versions --policy-arn "$policy_arn" --query 'Versions[?IsDefaultVersion==`true`].VersionId' --output text)
  policy_doc=$(aws iam get-policy-version --policy-arn "$policy_arn" --version-id "$version_id" --output json)
  echo "$policy_doc" | grep -q "$BUCKET_ARN" && echo "Policy $policy_arn references $BUCKET_ARN"
done
