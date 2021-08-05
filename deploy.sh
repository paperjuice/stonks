#!/bin/bash

DOCKER_IMAGE=$(docker inspect stonks:1.2.0 --format={{.Id}})

curl --netrc -X PATCH https://api.heroku.com/apps/stonks-timeline/formation \
  -d '{
  "updates": [
    {
      "type": "web",
      "docker_image": "sha256:7c8023b045446e823c883c60746ee61c2bc05d858a0775e2a213af2fd9388d9c"
    }
  ]
}' \
  -H "Content-Type: application/json" \
  -H "Accept: application/vnd.heroku+json; version=3.docker-releases"

