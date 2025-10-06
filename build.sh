#!/bin/bash

# A script to run the KiCad jobset and then process the output files.
# It first runs the kicad-cli command, checks for success, and if successful,
# it converts the component placement CSV data to a new format.

# --- Configuration ---
# Set the project and output file names
PROJECT_FILE="Template.kicad_pro"
JOBSET_FILE="Build.kicad_jobset"
RAW_POS_FILE="build/positions_raw-all-pos"
OUTPUT_POS_FILE="build/positions.csv"
BUILD_DIR="build"

# --- Main Logic ---

# Ensure the build directory exists where outputs will be placed.
mkdir -p "$BUILD_DIR"

# Announce the first step.
echo "🚀 Running KiCad jobset for '$PROJECT_FILE'..."

# Execute the KiCad command.
# We capture all output (stdout and stderr) into a variable for later inspection.
# 'tee /dev/tty' allows the output to be printed to the terminal in real-time.
output=$(kicad-cli jobset run -f "$JOBSET_FILE" "$PROJECT_FILE" 2>&1 | tee /dev/tty)

# Capture the exit code of the last command.
exit_code=$?

echo # Add a newline for better readability.

# Check if the command succeeded.
# A successful run must have an exit code of 0 AND contain "0 job failed" in its output.
if [ $exit_code -eq 0 ] && echo "$output" | grep -q "0 job failed"; then
    echo "✅ KiCad jobset completed successfully."

    # --- CSV Conversion Step ---
    echo "📄 Converting component placement file..."

    # Check if the expected input file was created by the jobset.
    if [ ! -f "$RAW_POS_FILE" ]; then
        echo "❌ Error: Input file for conversion not found: '$RAW_POS_FILE'" >&2
        echo "The KiCad jobset may not have generated the expected position file." >&2
        exit 1
    fi

    # Use awk to efficiently process the CSV and create the new format.
    awk '
    # This BEGIN block runs once before processing any lines.
    BEGIN {
        FS=","; # Set the input field separator to a comma.
        OFS=", "; # Set the output field separator to a comma followed by a space.
        print "Designator, Mid X, Mid Y, Layer, Rotation"; # Print the new header.
    }

    # This block runs for every line *except* the header (NR > 1).
    NR > 1 {
        gsub(/"/, "", $1); # Remove quotes from the first field (e.g., "C1" -> C1).
        
        # Convert the "Side" column ($7) to a single letter for the "Layer".
        layer = ($7 == "top") ? "T" : "B";
        
        # Print the columns in the desired new order.
        print $1, $4, $5, layer, $6;
    }
    ' "$RAW_POS_FILE" > "$OUTPUT_POS_FILE"

    echo "✅ Conversion complete. Output saved to '$OUTPUT_POS_FILE'."
    exit 0 # Exit with a success code.

else
    # If the command failed, print an error message and exit.
    echo "❌ Error: KiCad jobset failed." >&2
    echo "Please review the output above for details." >&2
    exit 1 # Exit with a non-zero status to indicate failure.
fi
