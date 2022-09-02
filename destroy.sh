#!/usr/bin/env bash

echo "Attention. This will completely wipe out all data in your local GitLab. Are you sure?"
read -p "Wipe out all data? [y|n]: " user_response

if [[ "${user_response}" =~ ^[y|Y]+(es|ES)?$ ]]; then
  echo "The containers will be removed and the data stored locally deleted."
  docker-compose down
  sudo rm -rf /tmp/gitlab /tmp/runner ~/.ssh/id_rsa ~/.ssh/id_rsa.pub
  ssh-keygen -R [localhost]:8822
fi
