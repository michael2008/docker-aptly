#! /usr/bin/env bash
set -e

DEBIAN_RELEASE=jessie
UPSTREAM_URL="http://mirrors.163.com/debian/"

aptly mirror create -architectures=amd64 -with-installer -with-udebs jessie-updates-main ${UPSTREAM_URL} jessie-updates main
aptly mirror create -architectures=amd64 -with-installer -with-udebs jessie-updates-contrib ${UPSTREAM_URL} jessie-updates contrib
aptly mirror create -architectures=amd64 -with-installer -with-udebs jessie-updates-non-free ${UPSTREAM_URL} jessie-updates non-free

REPOS=( jessie-updates-main jessie-updates-contrib jessie-updates-non-free )

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
    -component="main,contrib,non-free" -distribution=jessie-updates ${SNAPSHOTARRAY[@]} debian

# Export the GPG Public key
if [[ ! -f /opt/aptly/public/aptly_repo_signing.key ]]; then
  gpg --export --armor > /opt/aptly/public/aptly_repo_signing.key
fi

# Generate Aptly Graph
aptly graph -output /opt/aptly/public/aptly_graph.png