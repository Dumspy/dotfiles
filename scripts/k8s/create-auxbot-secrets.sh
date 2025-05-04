#!/usr/bin/env bash

# Script to create Kubernetes secrets for Auxbot from sops-nix secrets

set -e

# Check if arguments are provided
if [ "$#" -gt 0 ]; then
  NAMESPACE="$1"
else
  NAMESPACE="default"
fi

echo "Creating Auxbot secrets in namespace: $NAMESPACE"

# Paths to sops-nix secrets
DISCORD_CLIENT_ID_PATH="/run/secrets/auxbot/discord_client_id"
DISCORD_TOKEN_PATH="/run/secrets/auxbot/discord_token"
SENTRY_DNS_PATH="/run/secrets/auxbot/sentry_dns"

# Verify secrets exist
if [ ! -f "$DISCORD_CLIENT_ID_PATH" ]; then
  echo "Error: Discord client ID secret not found at $DISCORD_CLIENT_ID_PATH"
  echo "Make sure you've added this secret to your sops-nix configuration."
  exit 1
fi

if [ ! -f "$DISCORD_TOKEN_PATH" ]; then
  echo "Error: Discord token secret not found at $DISCORD_TOKEN_PATH"
  echo "Make sure you've added this secret to your sops-nix configuration."
  exit 1
fi

if [ ! -f "$SENTRY_DNS_PATH" ]; then
  echo "Error: Sentry DNS secret not found at $SENTRY_DNS_PATH"
  echo "Make sure you've added this secret to your sops-nix configuration."
  exit 1
fi

# Create the Kubernetes secret
echo "Creating Kubernetes secret 'auxbot-secrets'..."
kubectl create secret generic auxbot-secrets \
  --namespace "$NAMESPACE" \
  --from-file=DISCORD_CLIENT_ID="$DISCORD_CLIENT_ID_PATH" \
  --from-file=DISCORD_TOKEN="$DISCORD_TOKEN_PATH" \
  --from-file=SENTRY_DNS="$SENTRY_DNS_PATH" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "✅ Auxbot secrets successfully created in namespace: $NAMESPACE"