# Task Manager App – Flutter CRUD with Back4App

A robust Task Management application built using **Flutter** and powered by **Back4App (Parse Server)** as a Backend-as-a-Service (BaaS). This project demonstrates secure user authentication, real-time cloud database integration, and full CRUD (Create, Read, Update, Delete) functionality.

## 🚀 Features

### 🔐 User Authentication
- **Secure Registration:** Users can create an account using a unique username and password.
- **Student Verification:** The app includes a logic gate requiring a valid **Student Email ID** (containing `@student`) for registration.
- **Persistent Login:** Users stay logged in across sessions until they choose to sign out.
- **Secure Logout:** Invalidate the user session and return safely to the authentication screen.

### 📝 Task Management (CRUD)
- **Create:** Add new tasks with a title and detailed description stored directly in the Back4App Cloud.
- **Read:** Fetch and display tasks dynamically in a scrollable list view.
- **Update:** Edit existing tasks to update titles or descriptions with real-time syncing.
- **Delete:** Remove tasks permanently from the cloud database with a single tap.

### ☁️ Backend Architecture
- **Back4App Integration:** Utilizes the Parse SDK to manage data without a custom-built server.
- **Cloud Database:** Data is stored in a scalable, hosted MongoDB/PostgreSQL environment.

## 🛠️ Technology Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Back4App (Parse Server)
- **Database:** Back4App Cloud Database
- **Development Environment:** Project IDX (Cloud-based Linux VM)
- **Version Control:** Git & GitHub

## 📂 Project Structure
```text
lib/
 ┣ main.dart           # Entry point, SDK initialization, and App Logic
 ┣ (Logic includes):
 ┃ ┣ AuthScreen        # Registration & Login logic
 ┃ ┣ TaskListScreen    # Displaying and Deleting tasks
 ┃ ┗ EditTaskScreen    # Form for Creating and Updating tasks
