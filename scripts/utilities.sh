# This is meant to be sourced by other scripts for the functions here

MASTER_ACCOUNT=423344064466
USER_ACCOUNT=092251750008

verify_all() {
  verify_master_account
  verify_tools
}

verify_master_account () {
  AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
  if [ "${AWS_ACCOUNT_ID}" -ne "${MASTER_ACCOUNT}" ]; then
    echo "Error: This script must be run using the master account credentials"
    exit 1
  fi
}

verify_tools() {
  command -v jq >/dev/null 2>&1 || { echo >&2 "Missing jq. brew install jq"; exit 1; }
  command -v aws >/dev/null 2>&1 || { echo >&2 "Missing aws. brew install awscli"; exit 1; }
}

are_you_sure() {
  read -p "Are you sure? " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
}
