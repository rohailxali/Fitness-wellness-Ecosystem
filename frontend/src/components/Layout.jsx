import React, { useState } from 'react';
import { Outlet, NavLink, useNavigate } from 'react-router-dom';
import { Activity, Users, UserSquare2, Dumbbell, CreditCard, Database, LayoutDashboard, LogOut, ChevronRight } from 'lucide-react';

const Layout = () => {
  const navigate = useNavigate();
  const auth = JSON.parse(localStorage.getItem('fw_auth') || '{}');
  const [dbStatus] = useState(true); // Assume connected; Dashboard will show real state

  const navItems = [
    { to: '/app',              icon: LayoutDashboard, label: 'Dashboard',     end: true },
    { to: '/app/users',        icon: Users,           label: 'Users'                   },
    { to: '/app/trainers',     icon: UserSquare2,     label: 'Trainers'                },
    { to: '/app/exercises',    icon: Activity,        label: 'Exercises'               },
    { to: '/app/plans',        icon: Dumbbell,        label: 'Plans'                   },
    { to: '/app/subscriptions',icon: CreditCard,      label: 'Subscriptions'           },
    { to: '/app/queries',      icon: Database,        label: 'Demo Queries'            },
  ];

  const handleLogout = () => {
    localStorage.removeItem('fw_auth');
    navigate('/login');
  };

  return (
    <div className="flex h-screen bg-slate-100 overflow-hidden">
      {/* Sidebar */}
      <aside className="w-64 bg-slate-900 text-slate-300 flex flex-col shrink-0">
        {/* Brand */}
        <div className="h-16 flex items-center px-5 border-b border-slate-700/60 gap-2.5">
          <div className="w-8 h-8 bg-brand-600 rounded-lg flex items-center justify-center shrink-0">
            <Activity className="w-4 h-4 text-white" />
          </div>
          <span className="text-white font-bold text-base tracking-tight leading-tight">
            Fitness<br />
            <span className="text-brand-400 font-normal text-xs tracking-wide">Ecosystem</span>
          </span>
        </div>

        {/* Nav */}
        <nav className="flex-1 py-4 space-y-0.5 overflow-y-auto px-2">
          {navItems.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.end}
              className={({ isActive }) =>
                `flex items-center px-3 py-2.5 rounded-lg text-sm font-medium transition-all ${
                  isActive
                    ? 'bg-brand-600 text-white shadow'
                    : 'text-slate-400 hover:bg-slate-800 hover:text-white'
                }`
              }
            >
              <item.icon className="w-4 h-4 mr-3 shrink-0" />
              {item.label}
              <ChevronRight className="w-3 h-3 ml-auto opacity-0 group-hover:opacity-100" />
            </NavLink>
          ))}
        </nav>

        {/* User + Logout */}
        <div className="p-3 border-t border-slate-700/60">
          <div className="flex items-center gap-3 px-2 py-2 rounded-lg hover:bg-slate-800 cursor-pointer group">
            <div className="w-8 h-8 rounded-full bg-brand-700 flex items-center justify-center shrink-0">
              <span className="text-white text-xs font-bold uppercase">{(auth.username || 'A')[0]}</span>
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-white text-xs font-semibold truncate">{auth.username || 'Admin'}</p>
              <p className="text-slate-500 text-xs truncate">{auth.role || 'Administrator'}</p>
            </div>
            <button
              onClick={handleLogout}
              title="Logout"
              className="text-slate-500 hover:text-red-400 transition-colors"
            >
              <LogOut className="w-4 h-4" />
            </button>
          </div>
          <p className="text-slate-600 text-xs text-center mt-2">Powered by Oracle 11g</p>
        </div>
      </aside>

      {/* Main */}
      <main className="flex-1 flex flex-col overflow-hidden">
        {/* Topbar */}
        <header className="h-14 bg-white border-b border-slate-200 flex items-center justify-between px-6 shrink-0 shadow-sm">
          <h1 className="text-base font-semibold text-slate-700 tracking-tight">Admin Console</h1>
          <div className="flex items-center gap-2">
            <span className="text-xs text-slate-500">DB Status:</span>
            <span className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-emerald-50 text-emerald-700 text-xs font-semibold border border-emerald-200">
              <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse" />
              Connected
            </span>
          </div>
        </header>

        {/* Page Content */}
        <div className="flex-1 overflow-auto p-6">
          <Outlet />
        </div>
      </main>
    </div>
  );
};

export default Layout;
