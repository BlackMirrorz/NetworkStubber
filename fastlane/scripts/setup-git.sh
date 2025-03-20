#---------------------------------------------
# Git Configuration
# Configures The Git Hooks For Our CI Pipeline
# Copyright Twinkl Limited 2024
# Created By Josh Robbins (∩｀-´)⊃━☆ﾟ.*･｡ﾟ
#---------------------------------------------

echo "☁️  Twinkl Github Hook Running..."

# Change Into The Parent Directory
cd ../../..
echo "📁 Changed Directory to: $(pwd)"

# Create The Hooks Directory Or Replace If Needed
GIT_HOOKS_DIR=".git/hooks"
PRE_COMMIT_HOOK="$GIT_HOOKS_DIR/pre-commit"
POST_CHECKOUT_HOOK="$GIT_HOOKS_DIR/post-checkout"
POST_REWRITE_HOOK="$GIT_HOOKS_DIR/post-rewrite"
POST_MERGE_HOOK="$GIT_HOOKS_DIR/post-merge"

mkdir -p "$GIT_HOOKS_DIR"
find "$GIT_HOOKS_DIR" -type f ! -name 'pre-commit' -delete
find "$GIT_HOOKS_DIR" -type f ! -name 'post-checkout' -delete
find "$GIT_HOOKS_DIR" -type f ! -name 'post-rewrite' -delete
find "$GIT_HOOKS_DIR" -type f ! -name 'post-merge' -delete

#--------------------
# GIT PRE-COMMIT HOOK
#--------------------

# Create The Pre-Commit File & Make It Executable
cat > "$PRE_COMMIT_HOOK" << 'EOF'
#!/bin/bash

cd Source/fastlane
fastlane lintFormatCorrect
echo '🫠  Pre Commit Validation Completed  ✅'
EOF

if [[ -f "$PRE_COMMIT_HOOK" ]]; then
    echo "pre-commit hook created successfully at $PRE_COMMIT_HOOK."
else
    echo "Failed to create pre-commit hook."
fi

# Make The Pre-Commit Hook Executable
chmod +x "$PRE_COMMIT_HOOK"

#----------
# GITIGNORE
#----------

echo "🫠  Git Pre Commit Hook Succesfully Configured  🫠"

# Create Or Replace The Gitignore If Needed

echo "☁️  Twinkl GitIgnore Running..."

GIT_IGNORE_SOURCE=".gitignore"

if [ -f ".gitignore" ]; then
    rm ".gitignore"
    echo "🗑️  Removing Existing GitIgnore File"
fi

cat > "$GIT_IGNORE_SOURCE" << 'EOF'
# Created by https://www.toptal.com/developers/gitignore/api/xcode,macos,swift
# Edit at https://www.toptal.com/developers/gitignore?templates=xcode,macos,swift

### Fastlane ###
Source/fastlane/report.xml
Source/fastlane/README.md
Source/fastlane/test_output
Source/fastlane/packages_cache
Source/packages_cache
test_output
.env.default
gc_keys.json

### macOS ###
.DS_Store
.AppleDouble
.LSOverride
Icon
._*
.DocumentRevisions-V100
.fseventsd
.Spotlight-V100
.TemporaryItems
.Trashes
.VolumeIcon.icns
.com.apple.timemachine.donotpresent
.AppleDB
.AppleDesktop
Network Trash Folder
Temporary Items
.apdisk

### macOS Patch ###
*.icloud

### Swift ###
# Xcode
xcuserdata/
*.xcscmblueprint
*.xccheckout
build/
DerivedData/
*.moved-aside
*.pbxuser
*.mode1v3
*.mode2v3
*.perspectivev3
*.hmap
*.ipa
*.dSYM.zip
*.dSYM

## Playgrounds
timeline.xctimeline
playground.xcworkspace

### Swift Package Manager ###
.build/

### Carthage ###
Carthage/Build/

### Accio dependency management ###
Dependencies/
.accio/

### fastlane ###
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots/**/*.png
fastlane/test_output

### Code Injection ###
iOSInjectionProject/

### Xcode ###
*.xcworkspace/

### End of https://www.toptal.com/developers/gitignore/api/xcode,macos,swift ###
EOF

echo "🫠  GitIgnore Succesfully Configured  🫠"

#-----------
# PRTEMPLATE
#-----------

# Create Or Replace The PR Template If Needed
echo "☁️  Twinkl PR Template Generator Running..."

GIT_DIR=".github"

PR_TEMPLATE="pull_request_template.md"

if [ ! -d "$GIT_DIR" ]; then
    mkdir "$GIT_DIR"
    echo "📁  Creating $GIT_DIR directory"
fi

if [ -f "$GIT_DIR/$PR_TEMPLATE" ]; then
    rm "$GIT_DIR/$PR_TEMPLATE"
    echo "🗑️  Removing Existing PR Template"
fi

cat > "$GIT_DIR/$PR_TEMPLATE" << 'EOF'
### 🧠 Description of this Pull Request:
What's the context for this Pull Request?

### ✨ Related Jira Task:

### 🥱 Release Sheet:

https://tinyurl.com/2hrpc6y6

### 🥱 QA Sheet (if applicable):

### ⚙️ Changes being made (check all that are applicable):
- [ ] 🍕 Feature
- [ ] 🐛 Bug Fix
- [ ] 📝 Documentation Update
- [ ] 🎨 Style
- [ ] 🧑‍💻 Code Refactor
- [ ] 🔥 Performance Improvements
- [ ] ✅ Test
- [ ] 🤖 Build
- [ ] 🔁 CI
- [ ] 📦 Chore (Release)
- [ ] ⏩ Revert

### 🧪 Testing:
How do you know the changes are safe to ship to production?
What steps should the reviewer(s) take to test this PR?

### 📸 Screenshots/Videos (optional):
If you have made UI changes, what are the before and afters?

### 🚀 Release & Build:
- [ ] I have filled in the appRelease.txt
- [ ] I have updated the build and version numbers.
- [ ] I have updated the Release Notes.

### 🏎 Quality check
- [ ] My code follows the Twinkl Style Guide.
- [ ] My code has been linted and formatted.
- [ ] I have performed a self-review of my own code.
- [ ] I have commented my code where appropriate.
- [ ] I have removed print statements.
- [ ] I have added tests where applicable that prove my fix is effective or that my feature works.
- [ ] New and existing unit tests pass locally with my changes.
EOF
