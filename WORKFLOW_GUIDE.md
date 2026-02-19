# CI/CD Workflow Guide

This document provides an overview of the Continuous Integration and Continuous Deployment (CI/CD) workflow for this project, which is managed by GitHub Actions.

## Overview

The workflow automates the process of building, signing, and releasing the application. When a new tag matching the pattern `v*.*.*` is pushed to the repository, it automatically triggers a process that results in:

1.  A new **GitHub Release** containing the Android APK, Android App Bundle (AAB), and a zipped version of the Windows application.
2.  A new build being uploaded to the **Google Play Store** for production.

## Workflow Trigger

The workflow is automatically triggered on every `push` of a new tag that matches the pattern `v*.*.*` (e.g., `v1.2.3`).

## Workflow Breakdown

The pipeline is divided into three distinct jobs that run in parallel where possible:

### 1. `build_android`

This job is responsible for creating the Android release.

- **Environment**: Runs on an `ubuntu-latest` virtual machine.
- **Steps**:
    1.  **Setup**: Checks out the code, sets up Java, and installs the correct Flutter version using FVM.
    2.  **Caching**: Caches Flutter dependencies to speed up future builds.
    3.  **Get dependencies**: Runs `flutter pub get`.
    4.  **Signing**: Securely creates the `key.properties` and keystore files from GitHub Secrets to sign the application.
    5.  **Build APK**: Compiles the Android Application Package (`.apk`) using the `prod` flavor.
    6.  **Build App Bundle**: Compiles the Android App Bundle (`.aab`) using the `prod` flavor.
    7.  **Rename Artifacts**: Renames the APK and AAB to include the version number.
    8.  **Artifact Upload**: Uploads the generated `.apk` and `.aab` files as artifacts to be used in the final release creation step.
    9.  **Zip Debug Symbols**: Zips the native debug symbols for the Android build.
    10. **Upload to Google Play**: Publishes the App Bundle (`.aab`) to the `production` track on the Google Play Store, using the release notes from the `distribution/whatsnew` directory.

### 2. `build_windows`

This job is responsible for creating the Windows release.

- **Environment**: Runs on a `windows-latest` virtual machine.
- **Steps**:
    1.  **Setup**: Checks out the code and installs the correct Flutter version using FVM.
    2.  **Get dependencies**: Runs `flutter pub get`.
    3.  **Build**: Compiles the Windows application.
    4.  **Packaging**: Takes the output of the build and compresses it into a `hisnelmoslem_${version}_windows.zip` file.
    5.  **Artifact Upload**: Uploads the generated `.zip` file as an artifact.

### 3. `create_release`

This job runs only after both `build_android` and `build_windows` have completed successfully. It finalizes the release.

- **Environment**: Runs on an `ubuntu-latest` virtual machine.
- **Steps**:
    1.  **Download Artifacts**: Downloads the `.apk`, `.aab`, and `.zip` files that were created in the previous jobs.
    2.  **Create GitHub Release**: Creates a new public release on GitHub associated with the tag that triggered the workflow.
        - The release notes are populated from `CHANGELOG.md`.
        - The Android `.apk`, Android `.aab`, and Windows `.zip` files are attached as downloadable assets.

## Required Secrets

For the workflow to run successfully, the following secrets must be configured in the repository at **Settings > Secrets and variables > Actions**:

- **`SERVICE_ACCOUNT_JSON`**: The JSON key for the Google Cloud service account used to authenticate with the Google Play Store.
- **`KEYSTORE_BASE64`**: The Android keystore file, encoded in Base64 format.
- **`KEY_ALIAS`**: The alias for the signing key.
- **`KEY_PASSWORD`**: The password for the signing key.
- **`STORE_PASSWORD`**: The password for the keystore itself.
