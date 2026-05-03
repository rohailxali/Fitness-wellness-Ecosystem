import React, { useState, useEffect } from 'react';
import api from '../api/api';
import { Users, UserSquare2, Dumbbell, CreditCard, Activity } from 'lucide-react';

const Dashboard = () => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchDashboard = async () => {
      try {
        const res = await api.get('/dashboard');
        setData(res.data);
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    };
    fetchDashboard();
  }, []);

  if (loading) return <div className="p-8 text-slate-500">Loading metrics...</div>;
  if (!data) return (
    <div className="p-8">
      <div className="bg-red-50 border border-red-200 text-red-700 p-4 rounded-lg">
        <h3 className="font-bold mb-1">Backend Connection Failed</h3>
        <p>Could not load dashboard data. Please ensure the Node.js backend is running and Oracle 11g is connected.</p>
      </div>
    </div>
  );

  const stats = [
    { name: 'Total Users', value: data.counts.users, icon: Users, color: 'text-blue-600', bg: 'bg-blue-50' },
    { name: 'Active Subscriptions', value: data.counts.activeSubs, icon: CreditCard, color: 'text-green-600', bg: 'bg-green-50' },
    { name: 'Trainers', value: data.counts.trainers, icon: UserSquare2, color: 'text-purple-600', bg: 'bg-purple-50' },
    { name: 'Workout Plans', value: data.counts.plans, icon: Dumbbell, color: 'text-orange-600', bg: 'bg-orange-50' },
    { name: 'Exercises', value: data.counts.exercises, icon: Activity, color: 'text-pink-600', bg: 'bg-pink-50' },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold text-slate-900">Platform Overview</h2>
        <span className="text-sm text-slate-500">Live data from Oracle 11g</span>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4">
        {stats.map((stat) => (
          <div key={stat.name} className="card p-5 flex flex-col justify-center items-center text-center">
            <div className={`w-12 h-12 rounded-full ${stat.bg} ${stat.color} flex items-center justify-center mb-3`}>
              <stat.icon className="w-6 h-6" />
            </div>
            <p className="text-3xl font-extrabold text-slate-900">{stat.value || 0}</p>
            <p className="text-sm font-medium text-slate-500 uppercase tracking-wider mt-1">{stat.name}</p>
          </div>
        ))}
      </div>

      {/* Recent Activity */}
      <div className="card mt-8">
        <div className="px-6 py-4 border-b border-slate-200">
          <h3 className="text-lg font-semibold text-slate-800">Recent Subscriptions</h3>
        </div>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-slate-200">
            <thead className="bg-slate-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Member</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Plan</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Start Date</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Status</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Amount Paid</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-slate-200">
              {data.recentSubscriptions?.map((sub) => (
                <tr key={sub.USER_SUB_ID} className="hover:bg-slate-50 transition-colors">
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-slate-900">{sub.FULL_NAME}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-slate-600">{sub.PLAN_NAME}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-slate-600">{new Date(sub.START_DATE).toLocaleDateString()}</td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`px-2.5 py-0.5 inline-flex text-xs leading-5 font-semibold rounded-full ${
                      sub.STATUS === 'ACTIVE' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                    }`}>
                      {sub.STATUS}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-slate-600">PKR {sub.AMOUNT_PAID}</td>
                </tr>
              ))}
              {!data.recentSubscriptions?.length && (
                <tr>
                  <td colSpan="5" className="px-6 py-4 text-center text-slate-500 text-sm">No recent subscriptions found.</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
