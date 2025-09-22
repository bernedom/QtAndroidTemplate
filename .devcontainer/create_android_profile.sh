#!/bin/bash

# This script creates a default Android profile for Qt6 projects.

PROFILE_NAME="android"
ANDROID_CLANG_MAJOR_VERSION=$(${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin/clang -dumpversion | head -n1 | cut -d. -f1)
# Create the Android profile using Conan
conan profile detect --name $PROFILE_NAME --force

# the architecture will be set by the cmake toolchain
PROFILE_FILE="$HOME/.conan2/profiles/$PROFILE_NAME"

# Update or add the required settings in the profile file

# Remove any existing 'compiler' line
sed -i '/^compiler[ =]/d' "$PROFILE_FILE"
# Insert 'compiler=clang' before the first line starting with 'compiler.' or at the end if not found
awk '/^compiler\./ && !x {print "compiler=clang"; x=1} {print}' "$PROFILE_FILE" > "${PROFILE_FILE}.tmp"
if ! grep -q '^compiler=clang' "${PROFILE_FILE}.tmp"; then
    echo "compiler=clang" >> "${PROFILE_FILE}.tmp"
fi
mv "${PROFILE_FILE}.tmp" "$PROFILE_FILE"

sed -i '/^compiler.version[ =]/d' "$PROFILE_FILE"
echo "compiler.version=$ANDROID_CLANG_MAJOR_VERSION" >> "$PROFILE_FILE"

sed -i '/^compiler.libcxx[ =]/d' "$PROFILE_FILE"
echo "compiler.libcxx=libstdc++11" >> "$PROFILE_FILE"

for variant in release debug; do

    VARIANT_PROFILE="$HOME/.conan2/profiles/android-$variant"
    echo "Creating variant profile: $VARIANT_PROFILE"
    cp "$PROFILE_FILE" "$VARIANT_PROFILE"
    sed -i '/^build_type[ =]/d' "$VARIANT_PROFILE"
    echo "build_type=$(echo $variant | tr '[:lower:]' '[:upper:]')" >> "$VARIANT_PROFILE"
done