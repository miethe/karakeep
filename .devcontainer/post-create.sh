#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Starting post-create script..."

# Enable Corepack (should already be available with Node 22 image)
echo "Enabling Corepack..."
corepack enable

# Install pnpm dependencies
echo "Installing dependencies with pnpm..."
pnpm install

# Copy the sample environment file if it exists and .env doesn't
if [ -f ".env.sample" ] && [ ! -f ".env" ]; then
  echo "Copying .env.sample to .env..."
  cp .env.sample .env

  # Attempt to set default NEXTAUTH_SECRET if not already set in sample
  if ! grep -q "^NEXTAUTH_SECRET=" .env; then
    echo "Generating default NEXTAUTH_SECRET..."
    # Generate a secret and append it (use printf for better compatibility)
    printf "\nNEXTAUTH_SECRET=%s\n" "$(openssl rand -base64 36)" >> .env
  fi

  # Set MEILI_ADDR for the application if not already set in sample
   if ! grep -q "^MEILI_ADDR=" .env; then
    echo "Setting default MEILI_ADDR in .env..."
    printf "\nMEILI_ADDR=%s\n" "http://meilisearch:7700" >> .env
  fi
   # Set DATA_DIR for the application if not already set in sample
   if ! grep -q "^DATA_DIR=" .env; then
    echo "Setting default DATA_DIR in .env..."
    printf "\nDATA_DIR=%s\n" "/workspace/data" >> .env
  fi

else
  echo ".env file already exists or .env.sample not found. Skipping copy and default setup."
fi

# Create the default DATA_DIR if it doesn't exist
mkdir -p /workspace/data

echo "Post-create script finished."
echo "-----------------------------------------------------"
echo "IMPORTANT: Please review the generated .env file."
echo "You might need to add your OPENAI_API_KEY manually if required."
echo "Next step: Run 'pnpm run db:migrate' in the terminal."
echo "-----------------------------------------------------"
