 
 curl https://raw.githubusercontent.com/j0904/deploy/main/bluesky/pds/installer.sh >installer.sh

sudo bash installer.sh

curl https://pds.bigt.ai/xrpc/_health

wsdump "wss://pds.bigt.ai/xrpc/com.atproto.sync.subscribeRepos?cursor=0"
 

  curl https://raw.githubusercontent.com/j0904/deploy/main/bluesky/social-app/installer.sh >installer.sh
  sudo bash installer.sh

    curl https://raw.githubusercontent.com/j0904/deploy/main/bluesky/bsky/installer.sh >installer.sh
  sudo bash installer.sh


  2.1 Add DNS TXT Record
txt
 
_atproto.bigt.ai. IN TXT "did=did:web:pds.bigt.ai"


Verify Setup
curl -v https://yourdomain.com/.well-known/atproto-did

curl -v --http2 https://bigt.ai/xrpc/com.atproto.sync.subscribeRepos
(should return a 200 or stream logs if things work)

