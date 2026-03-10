# 📄 AI Resume Craft (Flutter)

A powerful Flutter application that helps users **build, enhance, and refine professional resumes** using **AI‑assisted guidance**, rich UI, and Firebase backend support.

---

##  Features

 **AI Resume Generator**  
Craft professional resumes using smart AI content improvement logic.

 **AI Chat Assistant**  
Get career advice and resume recommendations in real time.

 **Resume CRUD**  
Create, read, update, and delete resumes from your account.

 **Secure Authentication**  
User signup/login via Firebase (email and Google OAuth support).

 **Dark & Light Theme**  
Seamlessly switch between themes with persistence.

 **PDF Export & Share**  
Download or share generated resumes.

---

##  Tech Stack

| Technology | Purpose |
|------------|---------|
| Flutter     | Cross‑platform UI |
| Firebase    | Auth & Data Storage |
| Riverpod    | State Management |
| REST/AI API | AI resume enhancement |

---

## Installation

 **Clone the repository**
```bash
git clone https://github.com/Muaz2004/AI-Resume-Craft-Flutter.git
cd AI-Resume-Craft-Flutter

Install dependencies

flutter pub get

Firebase Setup


Enable Email/Password + Google sign-in in Firebase Console.

Update Android config

In android/app/build.gradle, set:

minSdkVersion 23
ndkVersion "27.0.12077973"

Run the app

flutter clean
flutter pub get
flutter run
