// ============================================================
//  src/controllers/marketController.js
//
//  THIS FILE handles all market-related logic:
//    - getMarkets    → Fetch all markets from Firestore
//    - getMarketById → Fetch a single market by ID
//    - createMarket  → Add a new market (admin use)
//
//  FIRESTORE STRUCTURE (markets collection):
//  markets/
//    └── {marketId}/
//          ├── name:     "Lusaka City Market"
//          ├── location: "Lusaka, Zambia"
//          ├── region:   "Central"
//          ├── isActive: true
//          └── createdAt: Timestamp
// ============================================================

const { db, admin } = require('../config/firebase');

const MARKETS_COLLECTION = 'markets';

// ─────────────────────────────────────────────────────────────
//  GET /api/markets
//  PURPOSE: Fetch all markets from Firestore
//  OPTIONAL QUERY PARAMS:
//    ?region=Central  → filter by region
//    ?active=true     → only return active markets
// ─────────────────────────────────────────────────────────────
const getMarkets = async (req, res, next) => {
  try {
    let query = db.collection(MARKETS_COLLECTION);

    // --- Optional Filters ---
    const { region, active } = req.query;

    if (region) {
      query = query.where('region', '==', region);
    }

    // If the client sends ?active=true, only return active markets
    if (active === 'true') {
      query = query.where('isActive', '==', true);
    }

    // Sort alphabetically by market name
    query = query.orderBy('name', 'asc');

    const snapshot = await query.get();

    if (snapshot.empty) {
      return res.status(200).json({
        success: true,
        count: 0,
        data: [],
        message: 'No markets found.',
      });
    }

    // Map Firestore documents to plain objects
    const markets = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    res.status(200).json({
      success: true,
      count: markets.length,
      data: markets,
    });
  } catch (error) {
    next(error);
  }
};

// ─────────────────────────────────────────────────────────────
//  GET /api/markets/:id
//  PURPOSE: Get ONE market by its Firestore document ID
// ─────────────────────────────────────────────────────────────
const getMarketById = async (req, res, next) => {
  try {
    const { id } = req.params;

    const doc = await db.collection(MARKETS_COLLECTION).doc(id).get();

    if (!doc.exists) {
      return res.status(404).json({
        success: false,
        message: `No market found with ID: ${id}`,
      });
    }

    res.status(200).json({
      success: true,
      data: { id: doc.id, ...doc.data() },
    });
  } catch (error) {
    next(error);
  }
};

// ─────────────────────────────────────────────────────────────
//  POST /api/markets
//  PURPOSE: Create a new market (admin-only use)
//  BODY (JSON): {
//    "name": "Kitwe Central Market",
//    "location": "Kitwe, Zambia",
//    "region": "Copperbelt"
//  }
// ─────────────────────────────────────────────────────────────
const createMarket = async (req, res, next) => {
  try {
    const { name, location, region } = req.body;

    // Basic validation
    if (!name || !location || !region) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: name, location, region.',
      });
    }

    const newMarket = {
      name:      name.trim(),
      location:  location.trim(),
      region:    region.trim(),
      isActive:  true,  // New markets are active by default
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    const docRef = await db.collection(MARKETS_COLLECTION).add(newMarket);

    res.status(201).json({
      success: true,
      message: 'Market created successfully.',
      data: {
        id: docRef.id,
        ...newMarket,
        createdAt: new Date().toISOString(),
      },
    });
  } catch (error) {
    next(error);
  }
};

module.exports = { getMarkets, getMarketById, createMarket };
