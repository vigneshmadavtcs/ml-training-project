#!/bin/bash

###############################################################################
# ML Training Pipeline Setup Script
#
# This script:
# 1. Creates a virtual environment if it doesn't exist
# 2. Activates the virtual environment
# 3. Installs dependencies from requirements.txt
# 4. Checks whether config.yaml exists
# 5. Optionally updates dataset_path from the command line
# 6. Runs train.py
# 7. Reports success/failure based on the exit code
###############################################################################

# Exit immediately if any command fails
set -e

# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------

VENV_DIR="venv"
CONFIG_FILE="config.yaml"
REQUIREMENTS_FILE="requirements.txt"
TRAINING_SCRIPT="train.py"

echo "========================================"
echo " ML Training Pipeline Setup"
echo "========================================"

# -----------------------------------------------------------------------------
# Step 1: Create Virtual Environment
# -----------------------------------------------------------------------------

if [ -d "$VENV_DIR" ]; then
    echo "[INFO] Virtual environment already exists."
else
    echo "[INFO] Creating virtual environment..."

    python3 -m venv "$VENV_DIR"

    echo "[INFO] Virtual environment created successfully."
fi

# -----------------------------------------------------------------------------
# Step 2: Activate Virtual Environment
# -----------------------------------------------------------------------------

echo "[INFO] Activating virtual environment..."

source "$VENV_DIR/bin/activate"

echo "[INFO] Virtual environment activated."

# -----------------------------------------------------------------------------
# Step 3: Install Requirements
# -----------------------------------------------------------------------------

if [ -f "$REQUIREMENTS_FILE" ]; then

    echo "[INFO] Installing dependencies..."

    pip install --upgrade pip

    pip install -r "$REQUIREMENTS_FILE"

    echo "[INFO] Dependencies installed."

else

    echo "[ERROR] $REQUIREMENTS_FILE not found."

    exit 1

fi

# -----------------------------------------------------------------------------
# Step 4: Validate Config File
# -----------------------------------------------------------------------------

if [ ! -f "$CONFIG_FILE" ]; then

    echo "[ERROR] $CONFIG_FILE not found."

    exit 1

fi

echo "[INFO] Configuration file found."

# -----------------------------------------------------------------------------
# Step 5: Validate Training Script
# -----------------------------------------------------------------------------

if [ ! -f "$TRAINING_SCRIPT" ]; then

    echo "[ERROR] $TRAINING_SCRIPT not found."

    exit 1

fi

echo "[INFO] Training script found."

# -----------------------------------------------------------------------------
# Bonus: Accept Dataset Path from Command Line
# -----------------------------------------------------------------------------

if [ -n "$1" ]; then

    echo "[INFO] Updating dataset_path in config.yaml"

    sed -i "s|^dataset_path:.*|dataset_path: $1|" "$CONFIG_FILE"

    echo "[INFO] Dataset updated to: $1"

fi

# -----------------------------------------------------------------------------
# Step 6: Execute Training
# -----------------------------------------------------------------------------

echo "[INFO] Starting training..."

# Disable automatic exit temporarily
set +e

python "$TRAINING_SCRIPT"

EXIT_CODE=$?

# Enable automatic exit again
set -e

# -----------------------------------------------------------------------------
# Step 7: Display Result
# -----------------------------------------------------------------------------

if [ "$EXIT_CODE" -eq 0 ]; then

    echo ""
    echo "========================================"
    echo " Training completed successfully."
    echo "========================================"

else

    echo ""
    echo "========================================"
    echo " Training failed."
    echo " Exit Code : $EXIT_CODE"
    echo "========================================"

fi

exit "$EXIT_CODE"