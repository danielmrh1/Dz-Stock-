#!/bin/bash

set -o pipefail

PROJECT_DIR="$HOME/Desktop/stock_dz_professional"
FLUTTER_BIN="/Users/macdnl/Downloads/flutter/bin"
LOG_FILE="$PROJECT_DIR/terminal_build.log"

echo "=================================================="
echo " Flutter iOS Full Repair Script"
echo "=================================================="

cd "$PROJECT_DIR" || { echo "❌ Project folder not found"; exit 1; }

export PATH="$PATH:$FLUTTER_BIN"

echo ""
echo "📍 Current project: $PROJECT_DIR"
echo "📍 Log file: $LOG_FILE"
echo ""

run_step() {
  echo ""
  echo "--------------------------------------------------"
  echo "▶️ $1"
  echo "--------------------------------------------------"
}

run_and_log() {
  bash -c "$1" 2>&1 | tee -a "$LOG_FILE"
  STATUS=${PIPESTATUS[0]}
  if [ $STATUS -ne 0 ]; then
    echo ""
    echo "❌ ERROR in step: $1"
    echo "📄 Check full log here: $LOG_FILE"
    exit $STATUS
  fi
}

echo "" > "$LOG_FILE"

run_step "Check Flutter"
run_and_log "flutter --version"
run_and_log "flutter doctor -v"

run_step "Kill old derived/build leftovers"
run_and_log "rm -rf build"
run_and_log "rm -rf ios/Pods"
run_and_log "rm -f ios/Podfile.lock"
run_and_log "rm -rf ~/Library/Developer/Xcode/DerivedData/*"
run_and_log "rm -rf ~/Library/Caches/CocoaPods"
run_and_log "rm -rf ios/.symlinks"
run_and_log "rm -rf ios/Flutter/Flutter.framework"
run_and_log "rm -rf ios/Flutter/Flutter.podspec"

run_step "Flutter clean"
run_and_log "flutter clean"

run_step "Restore Flutter generated files"
run_and_log "flutter pub get"

run_step "Repair iOS Pods"
run_and_log "cd ios && pod deintegrate"
run_and_log "cd ios && pod repo update"
run_and_log "cd ios && pod install"

run_step "Analyze Flutter project"
run_and_log "flutter analyze"

run_step "Try debug build on connected iPhone"
run_and_log "flutter run -d all --verbose"

echo ""
echo "✅ Script completed"
echo "📄 Full log saved in: $LOG_FILE"
echo ""
echo "If Xcode still opens white screen, open:"
echo "  ios/Runner.xcworkspace"
echo "then run the app and inspect terminal_build.log"