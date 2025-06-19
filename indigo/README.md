# Bluesky Docker Production Setup

This directory contains a Docker Compose configuration for running Bluesky components in production.

## Services Included
- PostgreSQL database
- PLC (did-method-plc)
- PDS (atproto)
- Relay (indigo-network)
- Fakermaker (test data generator)

## Setup Instructions

1. Build and start all services:
```bash
docker compose up -d --build
```

2. Verify services are running:
```bash
docker compose ps
```

3. To stop services:
```bash
docker compose down
```

## Accessing Services
- PLC: http://localhost:2582
- PDS: http://localhost:2583
- Relay: http://localhost:8080

## Fakermaker Data Generation
Fakermaker will automatically generate test data including:
- 100 test accounts
- User profiles
- Follow relationships
- Posts with mentions and images
- Likes and other interactions
- Simulated browsing activity

The data will be stored in the `fakermaker` directory.
