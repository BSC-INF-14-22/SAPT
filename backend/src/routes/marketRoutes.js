// ============================================================
//  src/routes/marketRoutes.js
//
//  Defines all URL paths related to markets.
//  These will be accessible under: /api/markets/...
// ============================================================

const express = require('express');
const router  = express.Router();

const {
  getMarkets,
  getMarketById,
  createMarket,
} = require('../controllers/marketController');

/**
 * GET /api/markets
 * Fetch all markets (with optional ?region= or ?active= filters)
 */
router.get('/', getMarkets);

/**
 * GET /api/markets/:id
 * Fetch a single market by Firestore document ID
 */
router.get('/:id', getMarketById);

/**
 * POST /api/markets
 * Create a new market (admin use)
 *
 * Body: { name, location, region }
 */
router.post('/', createMarket);

module.exports = router;
