# ⚖️ Lawyer Appointment Booking App

A complete Flutter application for booking lawyer appointments with secure payments, real-time notifications, rich UI interactions, and backend integration.

## 📝 Overview

The Lawyer Booking App is a full-featured Flutter application that allows clients to explore available lawyers, view their profiles, book appointments through an interactive calendar, securely pay using Stripe, and manage their bookings smoothly.

The app follows clean architecture principles, uses **Cubit** for state management, integrates with a real backend, and provides a polished user-friendly UI.

## 🚀 Features

### 🔐 Authentication
- User Login & Signup
- Backend-integrated authentication
- Validation & error handling
- Secure token/session management

### 👨‍⚖️ Lawyer Management
- List of lawyers fetched from backend
- **Filtering by:**
  - Specialty
  - Rating
  - Price
  - Location
- Search by lawyer name
- **Sorting by:**
  - Rating (High → Low)
  - Price
  - Experience

### 📅 Booking System
- Beautiful Calendar Picker (choose date & time)
- Real-time availability checking
- Confirmation screen
- Booking history

### 💳 Payment Integration (Stripe)
- Integrated secure Stripe payment flow
- Opens Google payment link directly
- Processes the payment seamlessly
- Returns back to the app
- Full success & failure handling

### 🏛️ Lawyer Profile Page
Each lawyer page includes:
- Lawyer image
- Name, specialty, experience
- Rating display
- Price information
- About section
- List of reviews
- Button to book appointment
- Button to upload user documents (image upload)

### 💬 Real-Time Chat (SignalR)
- Real-time messaging between client and lawyer
- Instant message delivery using SignalR
- Chat history
- Online/offline status

### 📝 Comments & Rating
- Add comment on lawyer profile
- Rate lawyer
- Like / dislike comments
- Backend synced

### 🔔 Notifications
- Push notifications (via backend or FCM)
- Alerts for:
  - Successful booking
  - Payment confirmation
  - Upcoming appointment reminder

### 🖼️ Media Handling
- Upload user documents (images)
- View uploaded files
- Lawyer can also have multiple images/gallery (optional)

### 📱 UI & UX
- Responsive layout for all screen sizes
- Supports landscape mode
- Smooth animations (buttons, transitions, list updates)
- User-friendly clean interface



## 🧠 State Management

The app uses **native Flutter state management** with StatefulWidget and setState for simple, efficient state handling across the application.

## 🗄️ Backend Integration

- All data fetched from real backend
- JWT / token handling
- Secure login system
- **CRUD operations:**
  - Fetch lawyers
  - Add booking
  - Add comment
  - Add rating
  - Upload image
- Payment confirmation callback

## 📦 Packages Used

| Package | Why Used |
|---------|----------|
| `dio` | Powerful HTTP client for API calls |
| `signalr_netcore` | Real-time chat with SignalR |
| `image_picker` | Upload user documents and images |
| `file_picker` | Pick files from device storage |
| `shared_preferences` | Local data storage |
| `jwt_decoder` | JWT token decoding for authentication |
| `intl` | Date formatting and internationalization |
| `url_launcher` | Launch URLs (Stripe payment links) |
| `multi_select_flutter` | Multi-selection for filters |
| `font_awesome_flutter` | Beautiful icons |
| `http` | HTTP requests |
| `logging` | App logging and debugging |

![WhatsApp Image 2025-12-16 at 11 33 41 PM (2)](https://github.com/user-attachments/assets/5480c721-ce29-46ae-9766-f4edb134b613)
![WhatsApp Image 2025-12-16 at 11 33 41 PM (1)](https://github.com/user-attachments/assets/41ed62ee-d0b6-4c87-a217-0d5c6506ca46)
![WhatsApp Image 2025-12-16 at 11 33 41 PM](https://github.com/user-attachments/assets/0b3002f4-b1b6-4277-b34b-db6b1e642901)


---

Made with ❤️ using Flutter



