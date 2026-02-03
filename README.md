# 🎬 Movies App

An iOS application built using **SwiftUI** that allows users to browse movies, view details, save favorites, and write reviews.  
The app follows the **MVVM architecture** and integrates a remote backend using **Airtable API** with a clean and modular networking layer.

---

## ✨ Features
- Browse movies list
- View detailed movie information
- Add and manage reviews
- User authentication (Sign In)
- User profile management (edit info & image)
- Save favorite movies
- Clean and user-friendly SwiftUI interface

---

## 🛠 Technologies & Tools
- Swift
- SwiftUI
- MVVM Architecture
- REST APIs
- Airtable API
- URLSession
- Git & GitHub

---

## 🧱 Architecture
The project follows the **MVVM (Model–View–ViewModel)** design pattern to ensure:
- Clear separation of concerns
- Better state management
- Scalable and maintainable codebase

---

## 📂 Project Structure
MoviesApp_Team4_M
│
├── Model
│ ├── AirtableDTOs
│ ├── AppInfo
│ └── secret
│
├── Networking
│ ├── AirtableAPI
│ ├── AirtableClient
│ └── APIRequester
│
├── View
│ ├── MoviesCenter
│ ├── MovieDetails
│ ├── AddReviewView
│ ├── SigninView
│ ├── ProfileView
│ ├── ProfileEditView
│ ├── ProfileImageView
│ └── ProfileInfoView
│
├── ViewModel
│ ├── MovieCenterVM
│ ├── MovieDetailsVM
│ ├── ProfileViewModel
│ ├── SavedMoviesViewModel
│ └── SignInViewModel
│
├── Assets
│ └── Assets.xcassets
│
├── .gitignore
└── MoviesApp_Team4_MApp.swift

## 🌐 API Integration
- Integrated **Airtable API** as a backend service
- Implemented a reusable networking layer using:
  - `APIRequester`
  - `AirtableClient`
  - `AirtableAPI`
- Used DTOs to map API responses into app models
