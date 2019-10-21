cd "$(dirname "$0")/.." || exit

INFO_PLIST="gmail-mark-as-read/Info.plist"
CREDENTIALS_PLIST="BuildConfig/credentials.plist"

echo "Removing Credentials into Info.plist"
/usr/libexec/PlistBuddy -c "Remove :GOOGLE_SIGN_IN_CLIENT_ID" "$INFO_PLIST"
/usr/libexec/PlistBuddy -c "Remove :CFBundleURLTypes" "$INFO_PLIST"
exit 0
