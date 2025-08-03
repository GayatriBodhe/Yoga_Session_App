# Yoga Session App

Welcome to the **Yoga Session App**, a Flutter-based mobile application developed as part of the RevoltronX Proof of Concept (POC) assignment. This app delivers an immersive yoga experience by dynamically rendering yoga sequences from a `poses.json` file, complete with synchronized audio, visual pose displays, and interactive features. Designed with a modern UI and robust functionality, it’s optimized for Android and ready to enhance your yoga practice.

## Table of Contents

- [Project Overview](#project-overview)
- [Technologies Used](#technologies-used)
- [App Information](#app-information)
- [Features](#features)
- [Screenshots](#screenshots)
- [Video Demo](#video-demo)
- [File Structure](#file-structure)
- [Limitations](#limitations)
- [License](#license)
- [Acknowledgments](#acknowledgments)


## Project Overview

The Yoga Session App is a mobile application built to demonstrate Flutter development skills for RevoltronX's POC assignment. It parses a JSON file to create a structured yoga session with three main sequences: "intro", "breath_cycle" (with 4 iterations), and "outro". The app features a custom gradient UI, real-time progress tracking, and interactive controls, making it a practical tool for guided yoga practice. Developed and tested on an Android device (CPH2423), it was completed by the deadline of August 3, 2025, 11:59 PM IST.

## Technologies Used

- **Framework**: Flutter 3.x (Cross-platform mobile development)
- **Language**: Dart
- **Dependencies**:
  - `audioplayers: ^5.2.0` (For audio playback and synchronization)
- **Tools**:
  - Android Studio / VS Code (IDE)
  - Flutter SDK
  - Git (Version control)
- **Asset Management**: Local assets (images and audio files) managed via `pubspec.yaml`
- **State Management**: `setState` for simple state updates

## App Information

- **Name**: Yoga Session App
- **Version**: 1.0.0
- **Platform**: Android (Primary), Web (Limited support)
- **Purpose**: Educational POC for RevoltronX, demonstrating Flutter capabilities
- **Developer**: Gayatri Bodhe (Submitted as part of RevoltronX assignment)
- **Release Date**: August 3, 2025
- **Size**: Approximately 10-15 MB (varies with assets)
- **Target Audience**: Yoga practitioners, Flutter developers (POC context)

## Features

### 1. Dynamic Sequence Rendering
- Parses `poses.json` to render "intro" (0-23s), "breath_cycle" (4 iterations, 20s each), and "outro" (0-18s).
- Displays pose images (e.g., `Base.png`, `Cat.png`, `Cow.png`) synced with audio.

### 2. Audio Playback
- Plays audio files (e.g., `CatCowIntro.mp3`, `CatCowLoop.mp3`, `CatCowOutro.mp3`) using the `audioplayers` package.
- Ensures seamless synchronization with pose changes.

### 3. Play/Pause Control
- Allows pausing and resuming from the exact point in any sequence.
- Preserves progress state for a smooth experience.

### 4. Progress Tracking
- Features a progress bar and real-time time counter (e.g., "Time: Xs").

### 5. Skip Functionality
- Enables skipping to the next sequence with full playback of remaining segments.

### 6. Iteration Feedback
- Displays iteration numbers ("1st iteration", "2nd iteration", "3rd iteration", "last iteration") during the "breath_cycle" loop for user awareness.

### 7. Segment Selection
- Allows starting from any sequence via the `PreviewScreen`.

### 8. Custom UI
- Utilizes a gradient background (ARGB 161,168,248 to white).
- Includes animated opacity transitions and touch-responsive buttons (play/pause, skip).

### 9. Navigation
- Returns to `PreviewScreen` after session completion with a styled dialog.

## Screenshots

Include visual proof of the app’s interface. Add these images to the `assets/screenshots/` folder and reference them here:

- **[Preview Screen]**  

![preview_page](https://github.com/user-attachments/assets/072e237f-9d72-46d0-a3ac-8be58e6ea8d7)

  _The initial screen showing available sequences with a gradient UI._

- **[Session Screen - Intro]**

![Session_Intro (1)](https://github.com/user-attachments/assets/d0653209-721c-4f07-b8c9-e89d0092618e)
  _The "intro" sequence with pose image._

- **[Session Screen - Breath Cycle]**  

![Session_loop (1)](https://github.com/user-attachments/assets/dab84e91-67a3-4481-bc5d-7ab51da232e9)
  _The "breath_cycle" sequence showing "2nd iteration" text._

- **[Session Screen - Outro]**
  
![Session_Outro (1)](https://github.com/user-attachments/assets/ae0e838d-3b8d-4b8e-a312-cd73834cbfb9)
  _The "outro" sequence with pose image._

  
- **[Session Complete Dialog]**
- 
![Session_complete (1)](https://github.com/user-attachments/assets/cc965bed-2f42-436f-a99d-c2a27bf38bea)
  _The completion dialog with navigation option._

## Video Demo

Watch the app in action! A 30-45 second video demonstrating key features is included:

- **[Demo Video]**  
  ![Yoga Session App Demo](https://github.com/GayatriBodhe/Yoga_Session_App/blob/main/assets/video/Yoga_App.mp4)  
  _Shows navigation from PreviewScreen, iteration text during breath_cycle, play/pause, skip, and completion dialog._

*Note*: Upload the `demo.mp4` file to the `assets/video/` folder in your repository and update the URL with your GitHub username and repository name.

## File Structure

YogaSessionApp/

├── android/              # Android configuration

├── assets/               # Asset directory

│   ├── images/           # Pose images (Base.png, Cat.png, Cow.png)

│   ├── audio/            # Audio files (CatCowIntro.mp3, CatCowLoop.mp3, CatCowOutro.mp3)

│   ├── screenshots/      # Screenshots for README

│   └── video/            # Video demo

├── lib/                  # Source code

│   ├── models/           # Data models (pose.dart)

│   ├── screens/          # UI screens (preview_screen.dart, session_screen.dart)

│   └── main.dart         # Entry point

├── pubspec.yaml          # Project configuration

├── README.md             # This file

└── ...                   # Other Flutter-generated files



## Limitations
- Asset Dependency: Requires manual addition of audio and image files to the assets/ folder.

## License
- This project is submitted as part of the RevoltronX POC assignment for educational purposes only. No commercial use is authorized.

## Acknowledgments

- Built with Flutter and the audioplayers package.
- Thanks to RevoltronX for the assignment and the Flutter community for resources.
