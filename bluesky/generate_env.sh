#!/bin/bash

# Script to generate .env file for Bluesky Docker Compose setup

echo "Bluesky .env File Generator"
echo "-----------------------------"
echo "Please provide the following information. Defaults are in [brackets]."
echo "Press Enter to use the default value if available."
echo

# --- Helper function to generate random hex strings ---
generate_random_hex() {
  local length=${1:-32} # Default to 32 hex characters (16 bytes)
  /usr/bin/openssl rand -hex "$length"
}

# --- Helper function to generate PDS PLC Rotation Key ---
GENERATE_K256_PRIVATE_KEY_CMD="openssl ecparam --name secp256k1 --genkey --noout --outform DER | tail --bytes=+8 | head --bytes=32 | xxd --plain --cols 32"

# Check for openssl
# The openssl command is explicitly called with its full path, so no need to check if it's in PATH.
# if ! command -v openssl &> /dev/null; then
#     echo "ERROR: openssl command not found. Please install OpenSSL."
#     exit 1
# fi

# --- Common Settings ---

PDS_HOSTNAME=${PDS_HOSTNAME:-pds.bigt.ai}


APPVIEW_HOSTNAME=${APPVIEW_HOSTNAME:-appview.bigt.ai}

SOCIAL_APP_HOSTNAME=${SOCIAL_APP_HOSTNAME:-bsky.bigt.ai}


CADDY_ADMIN_EMAIL=${CADDY_ADMIN_EMAIL:-your-email@example.com}

echo
echo "--- Database Settings ---"
PDS_DB_USER="pds_user"
PDS_DB_NAME="pds_db"

PDS_DB_PASSWORD=${PDS_DB_PASSWORD_INPUT:-$(generate_random_hex 16)}

APPVIEW_DB_USER="appview_user"
APPVIEW_DB_NAME="appview_db"

APPVIEW_DB_PASSWORD=${APPVIEW_DB_PASSWORD_INPUT:-$(generate_random_hex 16)}

POSTGRES_SHARED_PASSWORD=${POSTGRES_SHARED_PASSWORD_INPUT:-$(generate_random_hex 24)}

echo
echo "--- PDS Specific Settings ---"
PDS_PORT_INTERNAL="3001"
echo "Generating PDS JWT Secret..."
PDS_JWT_SECRET=$(generate_random_hex 32)
PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX=$(eval "${GENERATE_K256_PRIVATE_KEY_CMD}")
PDS_ADMIN_PASSWORD=${PDS_ADMIN_PASSWORD_INPUT:-$(generate_random_hex 16)} 
PDS_SERVICE_DID="did:web:${PDS_HOSTNAME}"

 

echo
echo "--- AppView Specific Settings ---"
APPVIEW_PORT_INTERNAL="3002"
echo "Generating AppView JWT Secret..."
BSKY_APPVIEW_JWT_SECRET=$(generate_random_hex 32)
BSKY_APPVIEW_SERVICE_DID="did:web:${APPVIEW_HOSTNAME}"

echo
echo "--- Social App Settings ---"
SOCIAL_APP_PORT_INTERNAL="3000"


# --- Create .env file ---
ENV_FILE=".env"
echo "Generating ${ENV_FILE}..."

cat > "$ENV_FILE" <<EOF
# --- Common Settings ---
PDS_HOSTNAME=${PDS_HOSTNAME}
APPVIEW_HOSTNAME=${APPVIEW_HOSTNAME}
SOCIAL_APP_HOSTNAME=${SOCIAL_APP_HOSTNAME}
CADDY_ADMIN_EMAIL=${CADDY_ADMIN_EMAIL}

# --- PDS Settings ---
PDS_DB_USER=${PDS_DB_USER}
PDS_DB_PASSWORD=${PDS_DB_PASSWORD}
PDS_DB_NAME=${PDS_DB_NAME}
PDS_PORT_INTERNAL=${PDS_PORT_INTERNAL}

PDS_JWT_SECRET=${PDS_JWT_SECRET}
PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX=${PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX}
PDS_ADMIN_PASSWORD=${PDS_ADMIN_PASSWORD}
PDS_SERVICE_DID=${PDS_SERVICE_DID}

PDS_DATA_DIRECTORY=/pds
PDS_BLOBSTORE_DISK_LOCATION=/pds/blocks
PDS_BLOB_UPLOAD_LIMIT=52428800
PDS_DID_PLC_URL=https://plc.directory
PDS_BSKY_APP_VIEW_URL=${APPVIEW_HOSTNAME}
PDS_BSKY_APP_VIEW_DID=did:web:api.bsky.app
PDS_REPORT_SERVICE_URL=https://mod.bsky.app
PDS_REPORT_SERVICE_DID=did:plc:ar7c4by46qjdydhdevvrndac
PDS_CRAWLERS=https://bsky.network
LOG_ENABLED=true
PDS_INVITE_REQUIRED=false



# --- AppView Settings ---
APPVIEW_DB_USER=${APPVIEW_DB_USER}
APPVIEW_DB_PASSWORD=${APPVIEW_DB_PASSWORD}
APPVIEW_DB_NAME=${APPVIEW_DB_NAME}
APPVIEW_PORT_INTERNAL=${APPVIEW_PORT_INTERNAL}

BSKY_APPVIEW_JWT_SECRET=${BSKY_APPVIEW_JWT_SECRET}
BSKY_APPVIEW_SERVICE_DID=${BSKY_APPVIEW_SERVICE_DID}

# --- Social App Settings ---
SOCIAL_APP_PORT_INTERNAL=${SOCIAL_APP_PORT_INTERNAL}

# --- Database common ---
POSTGRES_SHARED_PASSWORD=${POSTGRES_SHARED_PASSWORD}


EOF

echo
echo "${ENV_FILE} generated successfully!"
echo "Please review the contents of ${ENV_FILE} before running 'docker compose up -d'."
echo "PDS_ADMIN_PASSWORD is your admin password for the PDS web interface."
echo "Also, remember to update PDS_CRAWLERS in docker-compose.yml or .env once your AppView DID is live."
echo "(e.g., PDS_CRAWLERS=\"did:web:bsky.network \${BSKY_APPVIEW_SERVICE_DID}\")"

exit 0
