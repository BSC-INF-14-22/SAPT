// ============================================================
//  src/config/firebase.js
//
//  WHAT THIS FILE DOES:
//  - Loads your secret Firebase credentials from the .env file
//  - Initializes the Firebase Admin SDK (server-side Firebase)
//  - Exports the Firestore database so other files can use it
//
//  WHY Firebase Admin SDK?
//  - The normal Firebase SDK is for mobile/web (client-side)
//  - The Admin SDK is for servers - it has full database access
//    without needing a logged-in user
// ============================================================

// Load environment variables from .env file into process.env
const admin = require('firebase-admin');
const path  = require('path');

// Read the path to your service account key from the .env file
const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;

// Build an absolute path so Node.js can find the file correctly
const absolutePath = path.resolve(serviceAccountPath);

// Load the JSON key file (this has your Firebase credentials)
const serviceAccount = require(absolutePath);

// Initialize Firebase Admin — only do this ONCE across the app
// We check if it has already been initialized to avoid errors
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: process.env.FIREBASE_PROJECT_ID,
  });
}

// Get a reference to the Firestore database
const db = admin.firestore();

// Export db so other files (controllers) can import and use it
module.exports = { admin, db };
