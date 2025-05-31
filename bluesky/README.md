run sh generate_env.sh


#!/bin/bash

sudo snap install docker 

git clone https://github.com/j0904/social-app.git 
cd social-app
sudo docker build -t  social-app  -f Dockerfile .

cd .. # Go back to bluesky directory

git clone https://github.com/j0904/atproto.git  
 
cd  atproto/service/pds # Go to atproto/packages/pds from atproto/build
docker build -t bluesky_pds:latest \
  --build-arg PDS_DATABASE_URL="postgresql://${PDS_DB_USER}:${PDS_DB_PASSWORD}@db:5432/${PDS_DB_NAME}" \
  --build-arg PDS_BLOB_STORE=disk \
  --build-arg PDS_BLOB_STORE_DISK_LOCATION=/usr/src/app/blobstore .
 
git clone https://github.com/j0904/deploy.git 
cd deploy/bluesky
 sh generate_env.sh

mkdir -p /data/vm
sudo chmod 777 /data/vm

 curl https://raw.githubusercontent.com/j0904/deploy/main/bluesky/installer.sh >installer.sh

sudo bash installer.sh

curl https://pds.bigt.ai/xrpc/_health

wsdump "wss://pds.bigt.ai/xrpc/com.atproto.sync.subscribeRepos?cursor=0"
 