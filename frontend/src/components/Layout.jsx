import React from 'react';
import { Outlet, NavLink } from 'react-router-dom';
import { Activity, Users, UserSquare2, Dumbbell, Utensils, CreditCard, Database, Home } from 'lucide-react';

const Layout = () => {
  const navItems = [
    { to: '/app', icon: <Home className="w-5 h-5" />, label: 'Dashboard' },
    { to: '/app/users', icon: <Users className="w-5 h-5" />, label: 'Users' },
    { to: '/app/trainers', icon: <UserSquare2 className="w-5 h-5" />, label: 'Trainers' },
    { to: '/app/exercises', icon: <Activity className="w-5 h-5" />, label: 'Exercises' },
    // { to: '/app/workout-plans', icon: <Dumbbell className="w-5 h-5" />, label: 'Workout Plans' },
    // { to: '/app/meal-plans', icon: <Utensils className="w-5 h-5" />, label: 'Meal Plans' },
    { to: '/app/subscriptions', icon: <CreditCard className="w-5 h-5" />, label: 'Subscriptions' },
    { to: '/app/queries', icon: <Database className="w-5 h-5" />, label: 'Demo Queries' },
  ];

  return (
    <div className="flex h-screen bg-slate-50">
      {/* Sidebar */}
      <aside className="w-64 bg-dark-900 text-slate-300 flex flex-col">
        <div className="h-16 flex items-center px-6 bg-dark-800 border-b border-slate-700">
          <Activity className="w-6 h-6 text-brand-500 mr-2" />
          <span className="text-white font-bold text-lg tracking-tight">Fitness Ecosystem</span>
        </div>
        
        <nav className="flex-1 py-4 space-y-1 overflow-y-auto">
          {navItems.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.to === '/app'}
              className={({ isActive }) =>
                `flex items-center px-6 py-3 text-sm font-medium transition-colors ${
                  isActive
                    ? 'bg-brand-600 text-white'
                    : 'hover:bg-slate-800 hover:text-white'
                }`
              }
            >
              {item.icon}
              <span className="ml-3">{item.label}</span>
            </NavLink>
          ))}
        </nav>
        
        <div className="p-4 bg-dark-800 text-xs text-slate-500 text-center">
          Oracle 11g Semester Project
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 flex flex-col overflow-hidden">
        <header className="h-16 bg-white border-b border-slate-200 flex items-center justify-between px-8 shadow-sm z-10">
          <h1 className="text-xl font-semibold text-slate-800">Admin Console</h1>
          <div className="flex items-center space-x-4">
             <span className="text-sm font-medium text-slate-600">DB Status:</span>
             <span className="px-2.5 py-0.5 rounded-full bg-brand-100 text-brand-700 text-xs font-semibold flex items-center">
               <span className="w-2 h-2 rounded-full bg-brand-500 mr-1.5"></span>
               Connected
             </span>
          </div>
        </header>
        <div className="flex-1 overflow-auto p-8">
          <Outlet />
        </div>
      </main>
    </div>
  );
};

export default Layout;
