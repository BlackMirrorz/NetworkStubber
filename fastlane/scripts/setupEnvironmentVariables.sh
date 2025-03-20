#--------------------------------------------------
# Environment Configuration
# Configures Environment Variables For Our Pipeline
# Copyright Twinkl Limited 2024
# Created By Josh Robbins (∩｀-´)⊃━☆ﾟ.*･｡ﾟ
#--------------------------------------------------

echo "☁️  Twinkl Environmant Variable Script Running..."

cd ..

ENVIRONMENT_FILE=".env.default"

if [ -f ".env.default" ]; then
    rm ".env.default"
    echo "🗑️  Removing Existing Environment Variables"
fi

# Create The Default Environment Configuration
cat > "$ENVIRONMENT_FILE" << 'EOF'

#----------------------------------------
# Twinkl Environment Configuration
# Copyright Twinkl Limited 2024
# Created By Josh Robbins (∩｀-´)⊃━☆ﾟ.*･｡ﾟ
#----------------------------------------

# The Name Of The Project"
PROJECT_NAME = ""

#------------------------
# XCODE Settings
# Improve Build Stability
#------------------------

# Timeout Duration Used By Fastlane When Building The App
FASTLANE_XCODEBUILD_SETTINGS_TIMEOUT=1800

# Timeout Duration Used By Fastlane When Building The App
FASTLANE_XCODEBUILD_SETTINGS_RETRIES=5

#--------------
# Authorization
#--------------

# All Devs should be using SSH to authenticate so this shouldn't be needed
# MATCH_GIT_BASIC_AUTHORIZATION= ""

# Everyone must have this to be able to sync our certificates.
# MATCH_PASSWORD= ""

# This Is For Admin User When Creating Certificates.
# MATCH_USERNAME= ""

#-------------------------------------------------------------------
# AppStore Connect API
# Required Credentials For Uploading To AppStore Via Terminal Not CI
# These are our GithubSecrets
#-------------------------------------------------------------------

# APP_STORE_CONNECT_API_KEY_ID= ""
# APP_STORE_CONNECT_API_ISSUER_ID= ""
# APP_STORE_CONNECT_API_KEY_CONTENT= ""

# Can Be Any PAT With Read/Write Access To The Repositories
# IOS_GIT_AUTHORIZATION_FOR_WORKFLOWS = ""

#------------------------------------------------
# GoogleChat Webhook
# Required For Posting Messages To Our GoogleChat
#------------------------------------------------

IOS_TEAM_CHAT_CI_WEBHOOK = ""

#-----------------------
# CI Pipeline
# Disables Build Scripts
#-----------------------

IS_CI_PIPELINE = "NO"

#----------------------
# Testing Configuration
#----------------------

IS_TESTING_ENABLED: "YES"
REQUIRES_UI_TESTS: "YES"
  
EOF

echo "🫠  Environment Variables Configured  🫠"

