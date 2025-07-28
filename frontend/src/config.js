// API Configuration
export const API_CONFIG = {
  // Use environment variable for production, fallback to localhost for development
  // BASE_URL: import.meta.env.VITE_API_URL || '',
  BASE_URL: 'https://order-entry-backend-production.up.railway.app',
  
  // API endpoints
  ENDPOINTS: {
    TEST: '/api/test',
    CREATE_ORDER: '/api/orders/create/save',
    LOOKUP_CUSTOMER: '/api/orders/create/lookup_customer',
    LOOKUP_PRODUCT: '/api/orders/create/lookup_product'
  }
};

// Helper function to build full API URLs
export const buildApiUrl = (endpoint) => {
  return `${API_CONFIG.BASE_URL}${endpoint}`;
};

// Helper function to make API calls
export const apiCall = async (endpoint, options = {}) => {
  console.log('API_CONFIG.BASE_URL (DEBUG):', API_CONFIG.BASE_URL);
  const url = buildApiUrl(endpoint);
  
  try {
    console.log('API call (DEBUG):', url, options);
    const response = await fetch(url, options);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    return response
  } catch (error) {
    console.error('API call failed:', error);
    throw error;
  }
}; 