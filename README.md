# Eli – AI Coding Companion

## Setup Steps

### 1. Create Firebase Project
- Go to console.firebase.google.com
- Create project "Eli"
- Add iOS app with bundle ID `com.eli.app`
- Download `GoogleService-Info.plist` and place in `Eli/`
- Enable Email/Password sign-in in Authentication
- Generate a service account key (Project Settings > Service Accounts) and save as `server/firebase-service-account.json`

### 2. Add GitHub Secrets
- `HF_TOKEN`: Your Hugging Face API token
- `GOOGLE_SERVICE_BASE64`: base64 of `GoogleService-Info.plist` (optional for build)

### 3. Push to GitHub
- Create repo, push all files
- GitHub Actions will build unsigned IPA

### 4. Sideload with Portal
- Download IPA from Actions
- Import into Portal → Sign → Install

## Features
- Sign-up / Login with Firebase
- AI code generation via Hugging Face
- Live Activity lockscreen widget
- Push notifications (local + remote)
- Liquid Glass UI
