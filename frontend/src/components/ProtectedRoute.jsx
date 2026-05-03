import React from 'react';
import { Navigate } from 'react-router-dom';

/**
 * ProtectedRoute — wraps any route that requires authentication.
 * If no session exists in localStorage, redirects to /login.
 */
const ProtectedRoute = ({ children }) => {
  const auth = localStorage.getItem('fw_auth');
  if (!auth) return <Navigate to="/login" replace />;
  return children;
};

export default ProtectedRoute;
