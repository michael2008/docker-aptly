#! /usr/bin/env bash
set -e

DEBIAN_RELEASE=oldstable
UPSTREAM_URL="http://mirrors.aliyun.com/debian/"

aptly mirror create -architectures=amd64 -with-installer -with-udebs oldstable-main ${UPSTREAM_URL} oldstable main
aptly mirror create -architectures=amd64 -with-installer -with-udebs oldstable-contrib ${UPSTREAM_URL} oldstable contrib
aptly mirror create -architectures=amd64 -with-installer -with-udebs oldstable-non-free ${UPSTREAM_URL} oldstable non-free

REPOS=( oldstable-main oldstable-contrib oldstable-non-free )

for repo in ${REPOS[@]}; do
    aptly mirror update ${repo}
done

unset SNAPSHOTARRAY

for repo in ${REPOS[@]}; do
    echo "Creating snapshot of ${repo} repository mirror.."
    SNAPSHOTARRAY+="${repo}-`date +%Y%m%d%H` "
    aptly snapshot create ${repo}-`date +%Y%m%d%H` from mirror ${repo}
done

# Publish the latest merged snapshot
aptly publish snapshot -passphrase="${GPG_PASSWORD}" \
    -component="main,contrib,non-free" -distribution=${DEBIAN_RELEASE} ${SNAPSHOTARRAY[@]} debian

# Export the GPG Public key
if [[ ! -f /opt/aptly/public/aptly_repo_signing.key ]]; then
  gpg --export --armor > /opt/aptly/public/aptly_repo_signing.key
fi

# Generate Aptly Graph
aptly graph -output /opt/aptly/public/aptly_graph.png
