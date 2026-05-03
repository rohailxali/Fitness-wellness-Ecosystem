import axios from 'axios';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || '/api',
});

// Add a response interceptor to handle network errors globally
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (!error.response) {
      console.error('Network/CORS error. Backend might be offline.');
    }
    return Promise.reject(error);
  }
);

export default api;
