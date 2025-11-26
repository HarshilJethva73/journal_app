Memoir – A Simple & Beautiful Flutter Journal App

Memoir is a minimal, elegant, and fast journal/notes-taking application built using Flutter.
It allows users to quickly create notes, edit them, organize them with beautiful gradient backgrounds, and store everything locally using SharedPreferences.

This app is designed to be lightweight, responsive, and easy to use — perfect for quick journaling, writing ideas, or saving daily thoughts.

🚀 Features
✔ Create New Journals

Add notes with a title and a full description. Notes are stored locally and persist even after closing the app.

✔ Edit Existing Journals

Tap any journal to modify title, description, or background color.

✔ Auto-Save

Changes are automatically saved when the user exits the detail screen — ensuring nothing is lost.

✔ Beautiful Gradient Backgrounds

Each journal can have a custom gradient background chosen from a predefined set of themes.

✔ Improved UX

Auto-focus removed from search when returning from detail screen

Smart update detection: shows “Journal updated” only when something actually changed

First-time note creation shows “Journal created”

Proper validation: empty title/description are not saved

✔ Local Storage

All notes are stored using SharedPreferences, serialized as JSON.

✔ Clean UI

Soft colors, rounded cards, and a minimal layout inspired by modern note apps.

📲 Screens

Home Screen :

Displays all journals in a scrollable list

Floating Action Button to add new journal

Each journal shows title + short preview of description

Popup menu for Edit/Delete options

Detail Screen :

Title input

Description editor with unlimited text

Color picker for gradient backgrounds

Auto-save + manual save

“Last updated” date shown in AppBar

Tech Stack

Flutter (UI + state management)

Dart

SharedPreferences (local storage)

JSON encoding/decoding

Material Design Components
