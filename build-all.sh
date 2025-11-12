#!/bin/bash

# Build script for all keyboards
# Run this from the host machine - it will automatically find and use the docker container

set -e  # Exit on error

# Find running docker containers
CONTAINER_COUNT=$(docker ps -q | wc -l | tr -d ' ')

if [ "$CONTAINER_COUNT" -eq 0 ]; then
    echo "ERROR: No docker containers are running"
    exit 1
elif [ "$CONTAINER_COUNT" -gt 1 ]; then
    echo "ERROR: Multiple docker containers are running. Please stop all but the ZMK container."
    docker ps
    exit 1
fi

# Get the single running container ID
CONTAINER_ID=$(docker ps -q)
echo "Found docker container: $CONTAINER_ID"
echo ""

# Define paths (inside the container)
ZMK_CONFIG="/workspaces/zmk-config/config"
OUTPUT_DIR="/workspaces/zmk-config/firmware"

# Create output directory inside container
docker exec "$CONTAINER_ID" mkdir -p "$OUTPUT_DIR"

echo "=========================================="
echo "Building all keyboards..."
echo "=========================================="

# Build Corne-ish Zen Left
echo ""
echo "Building Corne-ish Zen (Left)..."
docker exec "$CONTAINER_ID" bash -c "cd /workspaces/zmk && west build -p -s app -b corneish_zen_v2_left -- -DZMK_CONFIG='$ZMK_CONFIG'"
docker exec "$CONTAINER_ID" cp /workspaces/zmk/build/zephyr/zmk.uf2 "$OUTPUT_DIR/corneish_zen_left.uf2"
echo "✓ Corne-ish Zen Left built -> firmware/corneish_zen_left.uf2"

# Build Corne-ish Zen Right
echo ""
echo "Building Corne-ish Zen (Right)..."
docker exec "$CONTAINER_ID" bash -c "cd /workspaces/zmk && west build -p -s app -b corneish_zen_v2_right -- -DZMK_CONFIG='$ZMK_CONFIG'"
docker exec "$CONTAINER_ID" cp /workspaces/zmk/build/zephyr/zmk.uf2 "$OUTPUT_DIR/corneish_zen_right.uf2"
echo "✓ Corne-ish Zen Right built -> firmware/corneish_zen_right.uf2"

# Build Chocofi Left
echo ""
echo "Building Chocofi (Left)..."
docker exec "$CONTAINER_ID" bash -c "cd /workspaces/zmk && west build -p -s app -b nice_nano_v2 -- -DSHIELD=corne_left -DZMK_CONFIG='$ZMK_CONFIG'"
docker exec "$CONTAINER_ID" cp /workspaces/zmk/build/zephyr/zmk.uf2 "$OUTPUT_DIR/chocofi_left.uf2"
echo "✓ Chocofi Left built -> firmware/chocofi_left.uf2"

# Build Chocofi Right
echo ""
echo "Building Chocofi (Right)..."
docker exec "$CONTAINER_ID" bash -c "cd /workspaces/zmk && west build -p -s app -b nice_nano_v2 -- -DSHIELD=corne_right -DZMK_CONFIG='$ZMK_CONFIG'"
docker exec "$CONTAINER_ID" cp /workspaces/zmk/build/zephyr/zmk.uf2 "$OUTPUT_DIR/chocofi_right.uf2"
echo "✓ Chocofi Right built -> firmware/chocofi_right.uf2"

echo ""
echo "=========================================="
echo "All builds complete!"
echo "Firmware files are in: firmware/"
echo "=========================================="
ls -lh firmware/
