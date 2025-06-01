 
 curl https://raw.githubusercontent.com/j0904/deploy/main/bluesky/pds/installer.sh >installer.sh

sudo bash installer.sh

curl https://pds.bigt.ai/xrpc/_health

wsdump "wss://pds.bigt.ai/xrpc/com.atproto.sync.subscribeRepos?cursor=0"
 

  curl https://raw.githubusercontent.com/j0904/deploy/main/bluesky/social-app/installer.sh >installer.sh
  sudo bash installer.sh

    curl https://raw.githubusercontent.com/j0904/deploy/main/bluesky/bsky/installer.sh >installer.sh
  sudo bash installer.sh