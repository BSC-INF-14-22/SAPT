// ============================================================
//  src/middleware/errorHandler.js
//
//  WHAT IS MIDDLEWARE?
//  Middleware is a function that runs BETWEEN the request
//  arriving and the response being sent. Think of it as a
//  "checkpoint" that every request must pass through.
//
//  WHAT THIS FILE DOES:
//  This is the GLOBAL ERROR HANDLER middleware.
//  If ANY route or controller throws an error, Express will
//  automatically call this function instead of crashing.
//
//  HOW EXPRESS KNOWS THIS IS AN ERROR HANDLER:
//  It has 4 parameters: (err, req, res, next)
//  Normal middleware has 3: (req, res, next)
// ============================================================

/**
 * Global Error Handler Middleware
 *
 * @param {Error}    err  - The error object that was thrown
 * @param {Request}  req  - The incoming HTTP request
 * @param {Response} res  - The outgoing HTTP response
 * @param {Function} next - The next middleware (not used here, but required by Express)
 */
const errorHandler = (err, req, res, next) => {
  // Print the error stack trace to the terminal (for debugging)
  console.error('❌ Error:', err.stack);

  // Decide what HTTP status code to return
  // If the error already has a status code, use it. Otherwise use 500 (Server Error)
  const statusCode = err.statusCode || 500;

  // Send a JSON error response to the client (your Flutter app)
  res.status(statusCode).json({
    success: false,
    message: err.message || 'An unexpected server error occurred.',
    // Only show the full error stack in development mode (not in production)
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
};

module.exports = errorHandler;
