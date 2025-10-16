# ⏱️ Clock-In App v1: Simple Attendance Tracking System

A mobile application built with **Flutter**, designed to track and manage simple attendance (clock-in/clock-out) for students or employees. This project implements a full **authentication flow** and essential **C.R.U.D.** features on attendance data, with 6 primary pages/features.

---

## ✨ Project Overview

This project serves as a comprehensive assignment for the **Mobile Programming (Flutter)** course, demonstrating proficiency in:

- Application architecture
- State management
- Local data handling (database integration)
- Implementation of full **C.R.U.D.** (Create, Read, Update, Delete) feature set

The core functionality is a **Simple Attendance Tracking System**, allowing authorized users to log their presence and view historical attendance reports.

---

## 🔑 Application Features and Page Structure

| No. | Page / Feature           | Assignment Category | Description                                                                 |
|-----|--------------------------|---------------------|-----------------------------------------------------------------------------|
| 1   | **Login Screen**         | Authentication      | The entry point for existing users to sign into the application.            |
| 2   | **Register Screen**      | Authentication      | The interface for new users to create an account.                           |
| 3   | **Attendance List**      | CRUD - Read         | Main dashboard showing a list of all historical attendance records.         |
| 4   | **Add Attendance**       | CRUD - Create       | A form to submit a new attendance/clock-in record (date and time included). |
| 5   | **Individual Report**    | Info / Report       | Displays a detailed attendance report/history for a specific user.          |
| 6   | **Profile / Role Screen**| Info / Profile      | Shows current user's information and role (e.g., Admin/Employee).           |
| 7   | **Edit/Update Record**   | CRUD - Update       | Flow to modify an existing attendance record.                               |
| 8   | **Delete Record**        | CRUD - Delete       | Delete attendance entries from the attendance list.                         |

---

## 🛠️ Technology Stack and Dependencies

This project is developed using **Flutter** and **Dart**, with a data-centric architecture. Below are key dependencies and their purposes:

| Category            | Dependency (Assumed)      | Purpose                                                        |
|---------------------|---------------------------|----------------------------------------------------------------|
| Framework           | Flutter, Dart             | Primary development environment                                |
| State Management    | Provider                  | Manage app-wide state and auth logic                           |
| Local Data / CRUD   | sqflite / Hive            | Local database for storing attendance records                  |
| Caching / Prefs     | shared_preferences        | Store session/login status and simple user preferences         |
| API / HTTP          | http / dio (optional)     | Manage server-based auth or data sync if implemented           |

---

### 🖥️ Project Screenshots
https://github.com/user-attachments/assets/e8ebe1ed-48b9-4f4d-bc9d-95c7b5fe83ba

---

## 🚀 Installation and Setup

To run this project locally, follow these steps:

### 1. Clone the Repository

```bash
git clone https://github.com/FarahAzhari/clockin_app_v1
cd clockin_app_v1
```

### 2. Get Dependencies

Make sure you have Flutter SDK installed, then run:

```bash
flutter pub get
```

### 3. Run the Application

Connect a device or start an emulator, then run:

```bash
flutter run
```

© 2025 Farah Azhari




