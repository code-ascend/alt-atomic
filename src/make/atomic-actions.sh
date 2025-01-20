#!/bin/bash
set -euo pipefail

echo "Running atomic-actions build and install script..."

# Define repository and paths
REPO_URL="https://github.com/SkyWar-design/atomic-actions.git"
BUILD_DIR="/tmp/atomic-actions"
INSTALL_DIR="/usr/local/bin"
ACTIONS_SRC_PATH="${BUILD_DIR}/models/actions"
ACTIONS_DEST_PATH="/usr/local/share/atomic-actions/actions"

# Step 1: Clone the repository
echo "Cloning atomic-actions repository from ${REPO_URL}..."
rm -rf "${BUILD_DIR}"  # Ensure no residual directory exists
git clone "${REPO_URL}" "${BUILD_DIR}"

# Step 2: Build the project with Go
echo "Building atomic-actions..."
cd "${BUILD_DIR}"
go build -o "${INSTALL_DIR}/atomic-actions"

# Step 3: Verify binary installation
if [[ -f "${INSTALL_DIR}/atomic-actions" ]]; then
  echo "Binary atomic-actions successfully built at ${INSTALL_DIR}/atomic-actions"
else
  echo "Failed to build atomic-actions binary!" >&2
  exit 1
fi

# Step 4: Clean and copy actions folder
echo "Preparing actions directory..."
rm -rf "${ACTIONS_DEST_PATH}"  # Remove existing actions
mkdir -p "${ACTIONS_DEST_PATH}"  # Ensure the target directory exists
cp -r "${ACTIONS_SRC_PATH}/." "${ACTIONS_DEST_PATH}"  # Copy actions folder

# Step 5: Cleanup temporary files
echo "Cleaning up..."
rm -rf "${BUILD_DIR}"

echo "Installation complete!"