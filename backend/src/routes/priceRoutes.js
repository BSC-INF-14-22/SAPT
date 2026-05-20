// ============================================================
//  src/routes/priceRoutes.js
//
//  WHAT ARE ROUTES?
//  Routes define the "addresses" (URLs) of your API.
//  They map an HTTP method + URL path → to a controller function.
//
//  Think of it like a receptionist at a building:
//    "GET /api/prices"  → "Go to getPrices in the price department"
//    "POST /api/prices" → "Go to submitPrice in the price department"
//
//  HOW EXPRESS ROUTER WORKS:
//  express.Router() creates a mini-app that only handles routes.
//  We attach middleware and controllers to specific paths here.
//  The router is then mounted onto the main app in routes/index.js
// ============================================================

const express = require('express');

// Create a new Router instance (a mini Express app for prices)
const router = express.Router();

// Import the controller functions (the actual logic)
const {
  getPrices,
  submitPrice,
  getPriceById,
} = require('../controllers/priceController');

// Import the validation middleware
const { validateSubmitPrice } = require('../middleware/validatePrice');

// ─────────────────────────────────────────────────────────────
//  ROUTE DEFINITIONS
//
//  router.get(path, ...middlewares, controllerFunction)
//  router.post(path, ...middlewares, controllerFunction)
//
//  Middleware runs LEFT → RIGHT before the controller.
//  If middleware calls next(), the request moves forward.
//  If middleware calls res.json(), the request STOPS there.
// ─────────────────────────────────────────────────────────────

/**
 * GET /api/prices
 * Fetch all prices (with optional ?marketId= or ?product= filters)
 *
 * Flow: Request → getPrices controller → Firestore → Response
 */
router.get('/', getPrices);

/**
 * GET /api/prices/:id
 * Fetch a single price by its Firestore document ID
 *
 * Example: GET /api/prices/abc123xyz
 */
router.get('/:id', getPriceById);

/**
 * POST /api/prices
 * Submit a new price entry
 *
 * Flow: Request → validateSubmitPrice middleware → submitPrice controller → Firestore → Response
 *
 * The middleware runs FIRST and validates the request body.
 * If validation fails, it sends an error response immediately.
 * If validation passes, it calls next() → submitPrice runs.
 */
router.post('/', validateSubmitPrice, submitPrice);

// Export the router so it can be used in routes/index.js
module.exports = router;
