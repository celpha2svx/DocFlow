#!/bin/bash
# Generate a keystore for DocFlow release signing
# Requires Java JDK (keytool) to be installed

KEYSTORE_DIR="docflow_app/android"
KEYSTORE_FILE="docflow-release.jks"
KEY_ALIAS="docflow"
STOREPASS="docflow-release"
KEYPASS="docflow-release"
VALIDITY_DAYS=10000

keytool -genkey -v \
  -keystore "$KEYSTORE_DIR/$KEYSTORE_FILE" \
  -alias "$KEY_ALIAS" \
  -keyalg RSA \
  -keysize 2048 \
  -validity $VALIDITY_DAYS \
  -storepass "$STOREPASS" \
  -keypass "$KEYPASS" \
  -dname "CN=DocFlow, OU=Clinical, O=DocFlow, L=Lagos, ST=Lagos, C=NG"

echo "Keystore generated at $KEYSTORE_DIR/$KEYSTORE_FILE"
