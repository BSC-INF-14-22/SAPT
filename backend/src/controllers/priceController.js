// ============================================================
//  src/controllers/priceController.js
//
//  WHAT IS A CONTROLLER?
//  A controller is a file that contains the LOGIC for what
//  happens when a specific route is hit. It:
//    1. Reads data from the request (req)
//    2. Talks to the database (Firestore)
//    3. Sends a response back (res)
//
//  Think of it like this:
//    Route   → "Which road do I take?"
//    Controller → "What do I actually DO when I get there?"
//
//  THIS FILE handles all price-related logic:
//    - getPrices    → Read prices from Firestore
//    - submitPrice  → Write a new price to Firestore
// ============================================================

// Import the Firestore database instance we set up in firebase.js
const { db } = require('../config/firebase');

// The Firestore collection name where prices are stored
const PRICES_COLLECTION = 'prices';

// ─────────────────────────────────────────────────────────────
//  GET /api/prices
//  PURPOSE: Fetch all price records from Firestore
//  OPTIONAL QUERY PARAMS:
//    ?marketId=abc123   → filter prices by market
//    ?product=Maize     → filter prices by product name
// ─────────────────────────────────────────────────────────────
const getPrices = async (req, res, next) => {
  try {
    // Start building the Firestore query from the 'prices' collection
    let query = db.collection(PRICES_COLLECTION);

    // --- Optional Filtering ---
    // req.query holds URL parameters like ?marketId=abc
    const { marketId, product } = req.query;

    if (marketId) {
      // Only return prices where the marketId field matches
      query = query.where('marketId', '==', marketId);
    }

    if (product) {
      // Only return prices where productName matches (case-sensitive)
      query = query.where('productName', '==', product);
    }

    // Sort by newest first using the timestamp field
    query = query.orderBy('submittedAt', 'desc');

    // Execute the query — this actually talks to Firestore
    const snapshot = await query.get();

    // If no documents were found, return an empty array (not an error)
    if (snapshot.empty) {
      return res.status(200).json({
        success: true,
        count: 0,
        data: [],
        message: 'No prices found.',
      });
    }

    // Convert Firestore documents into plain JavaScript objects
    // Each document has an `id` (auto-generated key) and `.data()` (the fields)
    const prices = snapshot.docs.map((doc) => ({
      id: doc.id,       // The Firestore document ID
      ...doc.data(),    // Spread all the document's fields
    }));

    // Send the response as JSON
    res.status(200).json({
      success: true,
      count: prices.length,
      data: prices,
    });
  } catch (error) {
    // If anything goes wrong, pass the error to the global error handler
    // This avoids try/catch repetition and keeps code clean
    next(error);
  }
};

// ─────────────────────────────────────────────────────────────
//  POST /api/prices
//  PURPOSE: Add a new price entry to Firestore
//  BODY (JSON): {
//    "productName": "Maize",
//    "price": 35.50,
//    "unit": "kg",
//    "marketId": "market_001",
//    "submittedBy": "user_uid_from_firebase_auth"
//  }
// ─────────────────────────────────────────────────────────────
const submitPrice = async (req, res, next) => {
  try {
    // Extract the validated fields from the request body
    // These fields have already been checked by validateSubmitPrice middleware
    const { productName, price, unit, marketId, submittedBy } = req.body;

    // Build the data object to save to Firestore
    const newPrice = {
      productName: productName.trim(),
      price:       Number(price),      // Ensure it's stored as a number
      unit:        unit.trim(),
      marketId,
      submittedBy,
      // serverTimestamp() tells Firestore to use the server's current time
      // This is safer than using new Date() on the client
      submittedAt: require('firebase-admin').firestore.FieldValue.serverTimestamp(),
      isVerified: false,  // Admin can later mark prices as verified
    };

    // Add the document to Firestore — Firestore auto-generates the document ID
    const docRef = await db.collection(PRICES_COLLECTION).add(newPrice);

    // Send a 201 Created response with the new document's ID
    res.status(201).json({
      success: true,
      message: 'Price submitted successfully.',
      data: {
        id: docRef.id,  // The auto-generated Firestore document ID
        ...newPrice,
        // Note: submittedAt will show as null here because serverTimestamp()
        // is resolved on the Firestore server, not immediately on our end
        submittedAt: new Date().toISOString(), // Approx time for the response
      },
    });
  } catch (error) {
    next(error);
  }
};

// ─────────────────────────────────────────────────────────────
//  GET /api/prices/:id
//  PURPOSE: Get a SINGLE price document by its Firestore ID
//  Example: GET /api/prices/abc123xyz
// ─────────────────────────────────────────────────────────────
const getPriceById = async (req, res, next) => {
  try {
    // req.params holds URL path variables like /:id
    const { id } = req.params;

    // Fetch the specific document from Firestore
    const doc = await db.collection(PRICES_COLLECTION).doc(id).get();

    // If the document doesn't exist, return a 404 error
    if (!doc.exists) {
      return res.status(404).json({
        success: false,
        message: `No price found with ID: ${id}`,
      });
    }

    res.status(200).json({
      success: true,
      data: {
        id: doc.id,
        ...doc.data(),
      },
    });
  } catch (error) {
    next(error);
  }
};

// Export all controller functions so routes can use them
module.exports = { getPrices, submitPrice, getPriceById };
