cd "$(dirname "$0")/.." || exit

INFO_PLIST="gmail-mark-as-read/Info.plist"
CREDENTIALS_PLIST="BuildConfig/credentials.plist"

CLIENT_ID=$(/usr/libexec/PlistBuddy -c "Print CLIENT_ID" $CREDENTIALS_PLIST)
REVERSED_CLIENT_ID=$(/usr/libexec/PlistBuddy -c "Print REVERSED_CLIENT_ID" $CREDENTIALS_PLIST)

if [[ $REVERSED_CLIENT_ID == *"com.google"* ]]; then

  if grep -q $REVERSED_CLIENT_ID "$INFO_PLIST"; then
    echo "REVERSED_CLIENT_ID exists in Info.plist"
    exit 0;
  fi

  echo "Inserting Credentials into Info.plist"
  /usr/libexec/PlistBuddy -c "Add :GOOGLE_SIGN_IN_CLIENT_ID string ${CLIENT_ID}" "$INFO_PLIST"
  /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes array" "$INFO_PLIST"
  /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0 dict" "$INFO_PLIST"
  /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes array" "$INFO_PLIST"
  /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes: string ${REVERSED_CLIENT_ID}" "$INFO_PLIST"
  /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleTypeRole string Editor" "$INFO_PLIST"
  echo "Credentials inserted."
  exit 0
fi

echo "error: Failed to add credentials to Info.plist"
exit 1
