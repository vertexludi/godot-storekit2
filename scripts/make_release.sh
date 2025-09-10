#!/bin/bash
set -e

# CHANGE THIS to the project name.
PLUGIN_NAME=iOSPluginTemplate

# Check if godot headers were generated.
if [[ $(find godot -name '*.gen.h' | wc -l | awk '{$1=$1};1') == 0 ]]; then
	./scripts/generate_headers.sh
fi

# Build archives
xcrun xcodebuild archive -project ${PLUGIN_NAME}.xcodeproj -scheme ${PLUGIN_NAME} -destination "generic/platform=iOS" -archivePath "bin/archives/${PLUGIN_NAME}.debug" -configuration Debug
xcrun xcodebuild archive -project ${PLUGIN_NAME}.xcodeproj -scheme ${PLUGIN_NAME} -destination "generic/platform=iOS" -archivePath "bin/archives/${PLUGIN_NAME}.release" -configuration Release

# Build xcframework
xcrun xcodebuild -create-xcframework \
		-archive bin/archives/${PLUGIN_NAME}.debug.xcarchive -library lib${PLUGIN_NAME}.a \
		-output bin/xcframeworks/${PLUGIN_NAME}.debug.xcframework
xcrun xcodebuild -create-xcframework \
		-archive bin/archives/${PLUGIN_NAME}.release.xcarchive -library lib${PLUGIN_NAME}.a \
		-output bin/xcframeworks/${PLUGIN_NAME}.release.xcframework

# Move all to release folder
rm -rf bin/${PLUGIN_NAME}
mkdir -p bin/${PLUGIN_NAME}

touch bin/${PLUGIN_NAME}/.gdignore
cp ${PLUGIN_NAME}/${PLUGIN_NAME}.gdip bin/${PLUGIN_NAME}/
mv bin/xcframeworks/${PLUGIN_NAME}.debug.xcframework bin/${PLUGIN_NAME}/
mv bin/xcframeworks/${PLUGIN_NAME}.release.xcframework bin/${PLUGIN_NAME}/

rm -rf bin/xcframeworks
rm -rf bin/archives

cd bin
rm -rf ${PLUGIN_NAME}.zip
zip -r ${PLUGIN_NAME} ${PLUGIN_NAME}
cd ..
