import React from 'react';
import { Link } from 'react-router-dom';
import { Activity, Dumbbell, Users, ArrowRight, Database } from 'lucide-react';

const Home = () => {
  return (
    <div className="min-h-screen bg-slate-50 flex flex-col">
      {/* Navbar */}
      <nav className="bg-white shadow-sm border-b border-slate-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16">
            <div className="flex items-center">
              <Activity className="h-8 w-8 text-brand-600" />
              <span className="ml-2 text-xl font-bold text-slate-900 tracking-tight">Fitness Ecosystem</span>
            </div>
            <div className="flex items-center space-x-4">
              <span className="text-sm font-medium text-slate-500 hidden sm:block">Semester Project Demo</span>
              <Link to="/app" className="btn-primary flex items-center">
                Go to Admin <ArrowRight className="ml-2 w-4 h-4" />
              </Link>
            </div>
          </div>
        </div>
      </nav>

      {/* Hero */}
      <div className="flex-1 flex flex-col justify-center items-center text-center px-4 py-16 sm:px-6 lg:px-8">
        <div className="inline-flex items-center rounded-full px-3 py-1 text-sm font-medium text-brand-700 bg-brand-100 mb-8">
          <Database className="w-4 h-4 mr-2" /> Oracle 11g Powered
        </div>
        <h1 className="text-5xl font-extrabold text-slate-900 tracking-tight mb-6 max-w-3xl">
          Complete Database <span className="text-brand-600">Semester Project</span>
        </h1>
        <p className="text-xl text-slate-600 mb-10 max-w-2xl">
          A production-style fitness and wellness platform demonstrating complex relationships, PL/SQL procedures, triggers, and real-time dashboard analytics.
        </p>
        
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 max-w-4xl w-full text-left mt-8">
          <div className="card p-6 border-t-4 border-t-brand-500">
            <div className="bg-brand-50 w-12 h-12 rounded-lg flex items-center justify-center mb-4 text-brand-600">
              <Users className="w-6 h-6" />
            </div>
            <h3 className="text-lg font-bold text-slate-900 mb-2">Normalized Schema</h3>
            <p className="text-slate-600 text-sm">3NF schema tracking Users, Trainers, Plans, and Subscriptions with robust constraints.</p>
          </div>
          <div className="card p-6 border-t-4 border-t-blue-500">
            <div className="bg-blue-50 w-12 h-12 rounded-lg flex items-center justify-center mb-4 text-blue-600">
              <Dumbbell className="w-6 h-6" />
            </div>
            <h3 className="text-lg font-bold text-slate-900 mb-2">PL/SQL Backend</h3>
            <p className="text-slate-600 text-sm">Automated triggers for BMI and dates. Procedures for clean, atomic operations.</p>
          </div>
          <div className="card p-6 border-t-4 border-t-purple-500">
            <div className="bg-purple-50 w-12 h-12 rounded-lg flex items-center justify-center mb-4 text-purple-600">
              <Database className="w-6 h-6" />
            </div>
            <h3 className="text-lg font-bold text-slate-900 mb-2">Advanced Queries</h3>
            <p className="text-slate-600 text-sm">Over 10 complex queries including multi-table joins, aggregations, and correlated subqueries.</p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Home;
