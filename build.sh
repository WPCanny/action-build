#!/bin/sh

# Set variables
BUILD_PATH="${HOME}/build"

# If not configured defaults to repository name
if [ -z "$PLUGIN_SLUG" ]; then
  PLUGIN_SLUG=${GITHUB_REPOSITORY#*/}
fi

# Set GitHub "path" output
DEST_PATH="${BUILD_PATH}/${PLUGIN_SLUG}"
echo "::set-output name=path::${DEST_PATH}"

# Set GitHub "version" output
PLUGIN_VERSION="${GITHUB_REF#refs/tags/}"
echo "::set-output name=version::${PLUGIN_VERSION}"

cd "$GITHUB_WORKSPACE" || exit

echo "➤ Installing PHP and JS dependencies..."
npm install
composer install || exit "$?"
echo "➤ Running JS Build..."
npm run build || exit "$?"
echo "➤ Cleaning up PHP dependencies..."
composer install --no-dev || exit "$?"

echo "➤ Generating build directory..."
rm -rf "$BUILD_PATH"
mkdir -p "$DEST_PATH"

echo "➤ Copying files..."
if [ -r "${GITHUB_WORKSPACE}/.distignore" ]; then
  rsync -rc --exclude-from="$GITHUB_WORKSPACE/.distignore" "$GITHUB_WORKSPACE/" "$DEST_PATH/" --delete --delete-excluded
else
  rsync -rc "$GITHUB_WORKSPACE/" "$DEST_PATH/" --delete
fi

if [ "${INPUT_GENERATE_ZIP}" = true ]; then
  echo "➤ Generating zip file..."
  cd "$BUILD_PATH" || exit
  zip -r "${GITHUB_WORKSPACE}/${PLUGIN_SLUG}.zip" "$PLUGIN_SLUG/"
  # Set GitHub "zip-path" output
  echo "::set-output name=zip-path::${GITHUB_WORKSPACE}/${PLUGIN_SLUG}.zip"
  echo "✓ Zip file generated!"
fi

echo "✓ Build done!"
