// This is a mock service account configuration
// In production, you should use a real service account JSON file from Firebase console
// This setup uses Firebase Admin SDK's built-in app-default credentials for development
module.exports = {
  setupFirebaseAdmin: (admin) => {
    try {
      // For development, try to use application default credentials
      // The actual implementation depends on your Firebase setup
      const serviceAccount = process.env.GOOGLE_APPLICATION_CREDENTIALS 
        ? require(process.env.GOOGLE_APPLICATION_CREDENTIALS)
        : null;
        
      if (serviceAccount) {
        // Initialize with service account file if available
        admin.initializeApp({
          credential: admin.credential.cert(serviceAccount)
        });
      } else {
        // Fall back to application default credentials
        // This works with environment variables or when running on Google Cloud
        admin.initializeApp({
          credential: admin.credential.applicationDefault()
        });
      }
      
      console.log('Firebase Admin SDK initialized successfully');
      return true;
    } catch (error) {
      console.error('Firebase Admin SDK initialization error:', error);
      
      // Fall back to a non-authenticated version for development
      try {
        admin.initializeApp();
        console.log('Firebase Admin SDK initialized with default app configuration');
        return true;
      } catch (fallbackError) {
        console.error('Failed to initialize Firebase Admin SDK with fallback:', fallbackError);
        return false;
      }
    }
  }
};
