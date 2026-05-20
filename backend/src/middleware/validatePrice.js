// ============================================================
//  src/middleware/validatePrice.js
//
//  WHAT THIS FILE DOES:
//  This middleware validates the request body BEFORE it reaches
//  the controller. It checks that the required fields exist and
//  have the correct data types.
//
//  WHY VALIDATE IN MIDDLEWARE?
//  - Keeps controllers clean (they only handle business logic)
//  - Reusable — you can attach this to any route that needs it
//  - Gives users clear error messages instead of crashes
// ============================================================

/**
 * Validates the body of a "submitPrice" request.
 * Required fields: productName, price, unit, marketId, submittedBy
 */
const validateSubmitPrice = (req, res, next) => {
  // Destructure fields from the request body
  const { productName, price, unit, marketId, submittedBy } = req.body;

  // --- Check that all required fields are present ---
  if (!productName || !price || !unit || !marketId || !submittedBy) {
    return res.status(400).json({
      success: false,
      message: 'Missing required fields.',
      required: ['productName', 'price', 'unit', 'marketId', 'submittedBy'],
      // Tell the user exactly what was received
      received: { productName, price, unit, marketId, submittedBy },
    });
  }

  // --- Check that price is a positive number ---
  if (typeof price !== 'number' || price <= 0) {
    return res.status(400).json({
      success: false,
      message: '`price` must be a positive number (e.g. 25.50)',
    });
  }

  // --- Check that productName and unit are non-empty strings ---
  if (typeof productName !== 'string' || productName.trim() === '') {
    return res.status(400).json({
      success: false,
      message: '`productName` must be a non-empty string.',
    });
  }

  // All checks passed — call next() to move to the controller
  next();
};

module.exports = { validateSubmitPrice };
