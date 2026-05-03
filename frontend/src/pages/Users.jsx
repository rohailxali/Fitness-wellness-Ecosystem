import React, { useState, useEffect } from 'react';
import api from '../api/api';
import { User, Mail, Phone, Target, Loader, AlertCircle } from 'lucide-react';

const Users = () => {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    api.get('/users')
      .then((res) => setUsers(res.data))
      .catch(() => setError('Could not load users. Ensure the backend and Oracle DB are running.'))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return (
    <div className="flex items-center justify-center py-24">
      <Loader className="w-6 h-6 animate-spin text-brand-600" />
      <span className="ml-3 text-slate-500 text-sm">Loading users from Oracle 11g...</span>
    </div>
  );

  if (error) return (
    <div className="flex items-center gap-2 bg-red-50 border border-red-200 text-red-700 p-4 rounded-lg text-sm">
      <AlertCircle className="w-4 h-4 shrink-0" />
      <span>{error}</span>
    </div>
  );

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h2 className="text-2xl font-bold text-slate-900">Platform Members</h2>
          <p className="text-sm text-slate-500 mt-0.5">{users.length} members registered</p>
        </div>
        <button className="btn-primary">Add Member</button>
      </div>

      {users.length === 0 ? (
        <div className="text-center text-slate-500 py-16 card">No users found in database.</div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-5">
          {users.map((user) => (
            <div key={user.USER_ID} className="card p-5 flex flex-col hover:shadow-md transition-shadow">
              <div className="flex items-start justify-between mb-4">
                <div className="flex items-center">
                  <div className="w-11 h-11 bg-brand-100 text-brand-700 rounded-full flex items-center justify-center font-bold text-base shrink-0">
                    {user.FIRST_NAME?.[0]}{user.LAST_NAME?.[0]}
                  </div>
                  <div className="ml-3">
                    <h3 className="font-bold text-slate-900 leading-tight">{user.FIRST_NAME} {user.LAST_NAME}</h3>
                    <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${
                      user.ACCOUNT_STATUS === 'ACTIVE' ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'
                    }`}>
                      {user.ACCOUNT_STATUS}
                    </span>
                  </div>
                </div>
              </div>

              <div className="space-y-1.5 text-sm text-slate-600 flex-1">
                <div className="flex items-center gap-2"><Mail className="w-3.5 h-3.5 text-slate-400 shrink-0" /> {user.EMAIL}</div>
                <div className="flex items-center gap-2"><Phone className="w-3.5 h-3.5 text-slate-400 shrink-0" /> {user.PHONE || 'N/A'}</div>
                <div className="flex items-center gap-2"><Target className="w-3.5 h-3.5 text-slate-400 shrink-0" /> Goal: <span className="font-medium text-slate-800">{user.FITNESS_GOAL}</span></div>
                <div className="flex items-center gap-2"><User className="w-3.5 h-3.5 text-slate-400 shrink-0" /> {user.GENDER} · {user.WEIGHT_KG}kg · {user.HEIGHT_CM}cm</div>
              </div>

              <div className="mt-4 pt-3 border-t border-slate-100 flex justify-end">
                <button className="text-xs font-semibold text-brand-600 hover:text-brand-800 transition-colors">View Details →</button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default Users;
