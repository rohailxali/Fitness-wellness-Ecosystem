import React, { useState, useEffect } from 'react';
import api from '../api/api';
import { Database, PlayCircle } from 'lucide-react';

const DemoQueries = () => {
  const [queries, setQueries] = useState({});
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('join-user-subscriptions');

  const endpoints = [
    { id: 'join-user-subscriptions', label: 'JOIN 1: User Subscriptions', path: '/queries/join/user-subscriptions' },
    { id: 'join-trainer-plans', label: 'JOIN 2: Trainer Plans', path: '/queries/join/trainer-plans' },
    { id: 'join-plan-exercises', label: 'JOIN 3: Plan Exercises', path: '/queries/join/plan-exercises' },
    { id: 'join-user-active-plans', label: 'JOIN 4: User Active Plans', path: '/queries/join/user-active-plans' },
    { id: 'join-trainer-meal-users', label: 'JOIN 5: Trainer Meal Users', path: '/queries/join/trainer-meal-users' },
    { id: 'sub-active-subs', label: 'SUB 1: Active Subs (IN)', path: '/queries/subquery/active-subscribers' },
    { id: 'sub-above-avg', label: 'SUB 2: Above Avg Payers', path: '/queries/subquery/above-avg-payers' },
    { id: 'sub-full-trainers', label: 'SUB 3: Full Trainers (EXISTS)', path: '/queries/subquery/full-trainers' },
    { id: 'sub-no-progress', label: 'SUB 4: No Progress (NOT EXISTS)', path: '/queries/subquery/no-progress' },
    { id: 'sub-plan-ex-count', label: 'SUB 5: Plan Exercise Count (HAVING)', path: '/queries/subquery/plan-exercise-count' },
    { id: 'view-wellness', label: 'VIEW 1: Wellness Overview', path: '/queries/view/wellness-overview' },
    { id: 'view-trainer-summary', label: 'VIEW 2: Trainer Summary', path: '/queries/view/trainer-summary' },
    { id: 'report-progress', label: 'REPORT: Progress Trend', path: '/queries/report/progress-trend' }
  ];

  useEffect(() => {
    // Fetch all queries in parallel
    Promise.all(endpoints.map(ep => api.get(ep.path).then(res => ({ id: ep.id, data: res.data }))))
      .then(results => {
        const queryMap = {};
        results.forEach(r => { queryMap[r.id] = r.data; });
        setQueries(queryMap);
        setLoading(false);
      }).catch(console.error);
  }, []);

  if (loading) return <div className="p-8">Executing queries against Oracle 11g...</div>;

  const activeData = queries[activeTab];

  return (
    <div className="flex h-full flex-col">
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-2xl font-bold text-slate-900 flex items-center">
          <Database className="w-6 h-6 mr-2 text-brand-600" /> Database Query Output
        </h2>
      </div>

      <div className="flex flex-1 overflow-hidden bg-white rounded-xl shadow-sm border border-slate-200">
        {/* Sidebar Nav */}
        <div className="w-64 bg-slate-50 border-r border-slate-200 overflow-y-auto">
          {endpoints.map(ep => (
            <button
              key={ep.id}
              onClick={() => setActiveTab(ep.id)}
              className={`w-full text-left px-4 py-3 text-sm font-medium border-l-4 transition-colors ${
                activeTab === ep.id 
                  ? 'border-brand-500 bg-white text-brand-700 shadow-sm' 
                  : 'border-transparent text-slate-600 hover:bg-slate-100 hover:text-slate-900'
              }`}
            >
              <div className="flex items-center">
                <PlayCircle className={`w-4 h-4 mr-2 ${activeTab === ep.id ? 'text-brand-500' : 'text-slate-400'}`} />
                <span className="truncate">{ep.label}</span>
              </div>
            </button>
          ))}
        </div>

        {/* Output Area */}
        <div className="flex-1 flex flex-col overflow-hidden bg-white">
          <div className="p-4 border-b border-slate-200 bg-slate-50 flex items-center justify-between">
            <h3 className="text-lg font-bold text-slate-800">{activeData?.title}</h3>
            <span className="px-3 py-1 bg-slate-200 text-slate-700 text-xs font-bold rounded">
              {activeData?.rows?.length || 0} rows
            </span>
          </div>
          
          <div className="flex-1 overflow-auto p-4">
            {activeData?.rows?.length > 0 ? (
              <table className="min-w-full divide-y divide-slate-200 text-sm">
                <thead className="bg-slate-50 sticky top-0">
                  <tr>
                    {Object.keys(activeData.rows[0]).map(key => (
                      <th key={key} className="px-4 py-3 text-left font-semibold text-slate-600 uppercase tracking-wider bg-slate-50">
                        {key}
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-200">
                  {activeData.rows.map((row, idx) => (
                    <tr key={idx} className="hover:bg-slate-50">
                      {Object.values(row).map((val, vIdx) => (
                        <td key={vIdx} className="px-4 py-3 whitespace-nowrap text-slate-700">
                          {val !== null ? String(val) : <span className="text-slate-400 italic">null</span>}
                        </td>
                      ))}
                    </tr>
                  ))}
                </tbody>
              </table>
            ) : (
              <div className="flex items-center justify-center h-full text-slate-500">No data returned</div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default DemoQueries;
