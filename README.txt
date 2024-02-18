# Wallet Wizard

## Overview
Wallet Wizard is a mobile application designed to simplify financial transactions and account management with a focus on security and user convenience.
This document outlines the functionalities implemented in the app, especially emphasizing login features, persistent user sessions, settings management,
and logout capabilities.

Features

Existing Features
Launch Screen: Displays the app's icon and name on a custom-designed screen.
Login View: Allows users to log in using their US phone number.
Country Code Display: Automatically shows "+1" for US numbers.
Phone Number Input: Users can input their phone number.
OTP Authentication: Sends a One-Time Password for account verification.
Error Handling: Informs users of any input errors or verification issues.

New Features
Persistent User Sessions
Automatic Login: Users with a stored authentication token bypass the login and verification screens, directly accessing their accounts.
User Model: Manages user-related data including the authentication token and user info, facilitating tasks such as loading user data, setting usernames,
and logging out.

Settings Page
User Information Display: Shows the username (editable) and phone number (non-editable).
Username Update: Users can edit their name and save changes, which are then reflected across the app.

Logout Functionality
Session Termination: Allows users to log out, clearing the stored authentication token and resetting the app to its initial state.

Technical Implementation
Login and Verification.
Utilizes PhoneNumberKit for phone number formatting and validation.
Converts phone numbers to E164 format for backend compatibility.
Implements auto-focus management for OTP entry and auto-verification upon complete OTP entry.

User Model and Data Persistence
Uses UserDefaults.standard for persistent storage of the authentication token.
Implements asynchronous data loading with Swift's concurrency features.
Manages user-related operations through a dedicated user model.

Settings and User Management
Provides an interface for viewing and editing user information.
Updates user names asynchronously, reflecting changes immediately in the app.
Utilizes environment objects and UserDefaults for managing user data and preferences.

Navigation
Leverages NavigationStack for seamless transitions between the Login, Verification, and Home views.
Ensures that users cannot navigate back to the loading screen after successful login.

 Developers Information
- **Name**: [Agam Bhullar] 
- **Student ID**: [921637853] 
