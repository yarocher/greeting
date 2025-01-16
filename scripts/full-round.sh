#!/bin/bash

# Configuration
ANDROID_API_LEVEL=30
ANDROID_JAR="${ANDROID_HOME}/platforms/android-${ANDROID_API_LEVEL}/android.jar"
BUILD_DIR=build

# Cleanup
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}/{apk,generated,classes,dex,jks}

# 1. Compile resources
aapt package -m -J ${BUILD_DIR}/generated -M AndroidManifest.xml -S res -I ${ANDROID_JAR}

# 2. Compile .java source code
javac -d ${BUILD_DIR}/classes -cp ${ANDROID_JAR} $(find ${BUILD_DIR}/generated/ src/main/java/ -type f -name '*.java')

# 3. Convert .class files into .dex files
d8 --no-desugaring --output ${BUILD_DIR}/dex $(find ${BUILD_DIR}/classes -type f -name '*.class')

# 4. Package unaligned unsigned APK
aapt package -M AndroidManifest.xml -F ${BUILD_DIR}/apk/greeting.unaligned.apk -S res -I ${ANDROID_JAR} ${BUILD_DIR}/dex/

# 5. Align APK
zipalign -p 4 ${BUILD_DIR}/apk/greeting.{unaligned,unsigned}.apk

# 6. Generate keypair
keytool -genkeypair -keystore ${BUILD_DIR}/jks/keystore.jks -alias androidkey -dname "CN=ychernysh.org, OU=ID, O=YCHERNYSH, L=Abc, S=Xyz, C=GB" -validity 10000 -keyalg RSA -keysize 2048 -storepass android -keypass android

# 7. Sign APK
apksigner sign --ks ${BUILD_DIR}/jks/keystore.jks --ks-key-alias androidkey --ks-pass pass:android --key-pass pass:android --out ${BUILD_DIR}/apk/greeting.apk ${BUILD_DIR}/apk/greeting.unsigned.apk

# 8. Uninstall package from device
adb uninstall org.ychernysh.greeting

# 9. Install package on device
adb install build/apk/greeting.apk

# 10. Launch the app on device
adb shell am start -n org.ychernysh.greeting/.GreetingActivity
