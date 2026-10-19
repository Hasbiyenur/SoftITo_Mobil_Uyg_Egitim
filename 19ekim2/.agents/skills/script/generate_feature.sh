#!/bin/bash
# Feature Scaffold Oluşturucu Betik

if [ -z "$1" ]; then
  echo "Kullanım: ./generate_feature.sh <feature_name>"
  echo "Örnek: ./generate_feature.sh water_tracker"
  exit 1
fi

FEATURE_NAME=$1
BASE_DIR="lib/features/$FEATURE_NAME"

echo "🚀 '$FEATURE_NAME' modülü oluşturuluyor..."

mkdir -p "$BASE_DIR/controllers"
mkdir -p "$BASE_DIR/models"
mkdir -p "$BASE_DIR/view"
mkdir -p "$BASE_DIR/widgets"

touch "$BASE_DIR/controllers/${FEATURE_NAME}_controller.dart"
touch "$BASE_DIR/models/${FEATURE_NAME}_model.dart"
touch "$BASE_DIR/view/${FEATURE_NAME}_view.dart"
touch "$BASE_DIR/widgets/${FEATURE_NAME}_card.dart"

echo "✅ Modül başarıyla oluşturuldu: $BASE_DIR"
