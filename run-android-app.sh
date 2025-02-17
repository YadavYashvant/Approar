#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in an Android project directory
if [ ! -f "./gradlew" ]; then
    echo -e "${RED}Error: Not in an Android project directory${NC}"
    echo "Please navigate to your Android project's root directory"
    exit 1
fi

echo -e "${YELLOW}Checking for connected devices...${NC}"

# Check if ADB is installed
if ! command -v adb &> /dev/null; then
    echo -e "${RED}Error: ADB is not installed${NC}"
    echo "Please install android-tools package:"
    echo "sudo pacman -S android-tools"
    exit 1
fi

# Check for connected devices
DEVICES=$(adb devices | grep -v "List" | grep "device$")
if [ -z "$DEVICES" ]; then
    echo -e "${RED}No devices connected. Please connect a device and enable USB debugging.${NC}"
    echo "To enable USB debugging:"
    echo "1. Go to Settings > About Phone"
    echo "2. Tap Build Number 7 times"
    echo "3. Go to Settings > Developer Options"
    echo "4. Enable USB Debugging"
    exit 1
fi

echo -e "${GREEN}Found device(s):${NC}"
echo "$DEVICES"

# Make gradlew executable
chmod +x ./gradlew

# Clean and build the project
echo -e "${YELLOW}Building project...${NC}"
./gradlew clean
./gradlew assembleDebug

if [ $? -ne 0 ]; then
    echo -e "${RED}Build failed${NC}"
    exit 1
fi

# Get the application ID from build.gradle
APP_ID=$(grep 'applicationId' app/build.gradle | awk '{print $2}' | tr -d '"')
if [ -z "$APP_ID" ]; then
    echo -e "${RED}Could not determine application ID${NC}"
    exit 1
fi

# Install the app
echo -e "${YELLOW}Installing app...${NC}"
adb install -r app/build/outputs/apk/debug/app-debug.apk

if [ $? -ne 0 ]; then
    echo -e "${RED}Installation failed${NC}"
    exit 1
fi

# Launch the app
echo -e "${YELLOW}Launching app...${NC}"
adb shell am start -n "${APP_ID}/.MainActivity"

echo -e "${GREEN}App launched successfully!${NC}"

# Show logcat
echo -e "${YELLOW}Showing logs (Ctrl+C to stop):${NC}"
adb logcat --pid=$(adb shell pidof -s ${APP_ID})
