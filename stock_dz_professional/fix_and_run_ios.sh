#!/bin/bash
set -e

PROJECT_DIR="$HOME/Desktop/stock_dz_professional"
DEVICE_ID="00008140-0008785C0E33001C"

echo "=================================================="
echo " Flutter iOS Fix + Run Script"
echo "=================================================="

cd "$PROJECT_DIR"

echo ""
echo "▶️ Flutter doctor"
flutter doctor -v || true

echo ""
echo "▶️ Clean Flutter project"
flutter clean

echo ""
echo "▶️ Remove old iOS pod files"
rm -rf ios/Pods
rm -f ios/Podfile.lock
rm -rf ios/Runner.xcworkspace

echo ""
echo "▶️ Get Flutter packages"
flutter pub get

echo ""
echo "▶️ Repair CocoaPods"
cd ios
pod deintegrate || true
pod repo update
pod install --repo-update
cd ..

echo ""
echo "▶️ Analyze project"
flutter analyze || true

echo ""
echo "▶️ Run on iPhone"
flutter run -d "$DEVICE_ID"
