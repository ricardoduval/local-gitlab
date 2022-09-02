#!/usr/bin/env bash

if docker-compose ps | grep local-gitlab-gitlab-1 | awk '{print $4 $5}' | grep 'running(healthy)'; then
  echo "Nothing to be done. The application is already running."
  exit 0
fi

ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N '' -C 'test@test.local'
export SHARED_RUNNER_REG_TOKEN=$(uuidgen)
export ROOT_TOKEN=$(uuidgen | cut -c 1-20)
export ROOT_PASSWORD=$(uuidgen | cut -c 1-8)
export TEST_PASSWORD=$(uuidgen | cut -c 1-8)

docker-compose up -d

i=0
while ! docker-compose ps | grep local-gitlab-gitlab-1 | awk '{print $4 $5}' | grep 'running(healthy)'; do
  sleep 10
  if [[ "${i}" -gt "60" ]]; then
    echo "Gitlab failed to come up after $((i * 10)) seconds"
    exit 1
  fi
  i=$((i+1))
  echo "Attempt $i executed - gitlab server is not up yet"
done

docker-compose exec gitlab-runner bash -c 'gitlab-runner register --non-interactive'

PAT_CREATION_COMMAND=$'gitlab-rails runner "token = User.find_by_username(\'root\').personal_access_tokens.create(scopes: [:api], name: \'Automation token\'); token.set_token(\''${ROOT_TOKEN}"');"'token.save!;"'
echo "Ready to create the root user token - ${PAT_CREATION_COMMAND}"
docker-compose exec gitlab bash -c "${PAT_CREATION_COMMAND}"

TEST_USER_RESULT=$(docker-compose exec gitlab curl -H "Authorization: Bearer ${ROOT_TOKEN}" -X POST -d "email=test@test.local&password=${TEST_PASSWORD}&username=test&name=Test%20User&skip_confirmation=true" http://localhost/api/v4/users)
TEST_USER_ID=$(echo "$TEST_USER_RESULT" | jq -r .id)
echo "User successfully created with ID: ${TEST_USER_ID}"
PUB_KEY_CONTENT=$(cat ~/.ssh/id_rsa.pub)
JSON_DATA='{"title": "Default user key", "key": "'$PUB_KEY_CONTENT'"}'
docker-compose exec gitlab curl -H "Authorization: Bearer ${ROOT_TOKEN}" -H 'content-type: application/json' -d "${JSON_DATA}" -X POST "http://localhost/api/v4/users/${TEST_USER_ID}/keys"

echo ""; echo "";
echo "########### RANDOM GENERATED CREDENTIALS ###############"
echo "#  UI Access:                                          #"
echo "#      Root user: root / ${ROOT_PASSWORD}                      #"
echo "#      Test user: test / ${TEST_PASSWORD}                      #"
echo "#  Root user Personal Access Token:                    #"
echo "#      ${ROOT_TOKEN}                            #"
echo "#  Registration Shared Runner Token:                   #"
echo "#      ${SHARED_RUNNER_REG_TOKEN}            #"
echo "#  Root Private Key Location:                          #"
echo "#      /home/vagrant/.ssh/id_rsa                       #"
echo "########################################################"