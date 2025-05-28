#!/bin/bash

. ./.env

git clone https://github.com/j0904/social-app.git ./social-app
cd ./social-app
docker build -t  social-app  -f Dockerfile .

cd .. # Go back to bluesky directory

git clone https://github.com/j0904/atproto.git  
 
cd  atproto/service/pds # Go to atproto/packages/pds from atproto/build
docker build -t bluesky_pds:latest \
  --build-arg PDS_DATABASE_URL="postgresql://${PDS_DB_USER}:${PDS_DB_PASSWORD}@db:5432/${PDS_DB_NAME}" \
  --build-arg PDS_BLOB_STORE=disk \
  --build-arg PDS_BLOB_STORE_DISK_LOCATION=/usr/src/app/blobstore .

cd ../../../ # Go back to bluesky directory

sh generate_env.sh

mkdir -p /data/vm
sudo chmod 777 /data/vm
