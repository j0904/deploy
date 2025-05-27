#!/bin/bash
 
git clone https://github.com/j0904/social-app.git
cd social-app
docker build -t  social-app  -f Dockerfile .

 
git clone https://github.com/j0904/atproto.git
cd atproto/build
sh buildlocal.sh 
