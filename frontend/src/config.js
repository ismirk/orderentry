// API Configuration
export const API_CONFIG = {
  // Use environment variable for production, fallback to localhost for development
  BASE_URL: import.meta.env.VITE_API_URL || 'http://localhost:8080',
  
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
  const url = buildApiUrl(endpoint);
  
  const defaultOptions = {
    headers: {
      'Content-Type': 'application/json',
      ...options.headers
    }
  };
  
  const finalOptions = { ...defaultOptions, ...options };
  
  try {
    console.log('API call (DEBUG):', url, finalOptions);
    const response = await fetch(url, finalOptions);
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    return await response.json();
  } catch (error) {
    console.error('API call failed:', error);
    throw error;
  }
}; 