#! /bin/bash
set -e

# Automate the initial creation and update of a EPICS NSLS-II package mirror in aptly

# The variables (as set below) will create a mirror of the Debian jessie repo
# with the main and update components. If you do mirror these, you'll want to
# include "deb http://security.debian.org jessie/updates main" in your sources.list
# file or mirror it similarly as done below to keep up with security updates.

DEBIAN_RELEASE=stretch
UPSTREAM_URL="https://epicsdeb.bnl.gov/debian/"
COMPONENTS=( main contrib )
REPOS=( ${DEBIAN_RELEASE}/staging )

# Create repository mirrors if they don't exist
set +e
for component in ${COMPONENTS[@]}; do
  for repo in ${REPOS[@]}; do
    aptly mirror list -raw | grep "^${repo}-${component}$"
    if [[ $? -ne 0 ]]; then
      echo "Creating mirror of ${repo}-${component} repository."
      aptly mirror create \
        -architectures=amd64 ${repo}-${component} ${UPSTREAM_URL} ${repo}-${component} ${component}
    fi
  done
done
set -e

# Update all repository mirrors
for component in ${COMPONENTS[@]}; do
  for repo in ${REPOS[@]}; do
    echo "Updating ${repo}-${component} repository mirror.."
    aptly mirror update ${repo}-${component}
  done
done

# Create snapshots of updated repositories
for component in ${COMPONENTS[@]}; do
  for repo in ${REPOS[@]}; do
    echo "Creating snapshot of ${repo}-${component} repository mirror.."
    SNAPSHOTARRAY+="${repo}-${component}-`date +%Y%m%d%H` "
    aptly snapshot list
    aptly snapshot create ${repo}-${component}-`date +%Y%m%d%H` from mirror ${repo}-${component}
  done
done

echo ${SNAPSHOTARRAY[@]}

# Merge snapshots into a single snapshot with updates applied
echo "Merging snapshots into one.."
aptly snapshot merge -latest                 \
  ${DEBIAN_RELEASE}-merged-`date +%Y%m%d%H`  \
  ${SNAPSHOTARRAY[@]}

# Publish the latest merged snapshot
set +e
aptly publish list -raw | awk '{print $2}' | grep "^${DEBIAN_RELEASE}$"
if [[ $? -eq 0 ]]; then
  aptly publish switch            \
    -passphrase="${GPG_PASSWORD}" \
    ${DEBIAN_RELEASE} ${DEBIAN_RELEASE}-merged-`date +%Y%m%d%H`
else
  aptly publish snapshot \
    -passphrase="${GPG_PASSWORD}" \
    -distribution=${DEBIAN_RELEASE} ${DEBIAN_RELEASE}-merged-`date +%Y%m%d%H`
fi
set -e

# Export the GPG Public key
if [[ ! -f /opt/aptly/public/aptly_repo_signing.key ]]; then
  gpg --export --armor > /opt/aptly/public/aptly_repo_signing.key
fi

# Generate Aptly Graph
aptly graph -output /opt/aptly/public/aptly_graph.png
