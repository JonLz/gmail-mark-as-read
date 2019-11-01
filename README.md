## Application configuration

### Providing your own Google Sign In secrets

Secrets are not stored in the git commit history and must be provided manually. This application stores secrets in configuration files in the `BuildConfig` folder. To provide your own set of google sign in secrets, copy and rename the `credentials_example.plist` file to `credentials.plist` and provide the secrets. Do not modify the names of the secret keys as the application reads these keys at runtime. You can get these secrets from the Google API Library.

### Reading secrets at runtime

The `AppConfiguration` class is responsible for constructing the `AppConstants` struct with the values provided in the configuration files above. In application code, always use `AppConfiguration().appConstants.secretKey` to access secrets. A build script run phase will pull secrets from the `credentials.plist` file and inject them into the `Info.plist`. This script can be found at `update_google_sign_in_credentials.sh`


### Ensuring secrets are kept clean

Run the `remove_credentials.sh` script to remove build time credentials changes. Alternatively use a git pre-commit hook as described below if you want this to run on every commit.

A git `pre-commit` hook can run the `remove-credentials.sh` script to make sure any values created at build time by the `update_google_sign_in_credentials.sh` script are removed before a commit is created. This uses `git add -u` to update the index directly.

Add the following to your `.git/hooks/pre-commit` if you want this behavior:
```
cd "$(dirname "$0")/../.." || exit
./script/remove_credentials.sh
git add -u gmail-mark-as-read/Info.plist
```