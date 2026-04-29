import React, { useState, useEffect } from 'react';
import api from '../api/api';
import { User, Mail, Phone, Target, Calendar } from 'lucide-react';

const Users = () => {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.get('/users').then((res) => {
      setUsers(res.data);
      setLoading(false);
    }).catch(console.error);
  }, []);

  if (loading) return <div className="p-8">Loading users...</div>;

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h2 className="text-2xl font-bold text-slate-900">Platform Members</h2>
        <button className="btn-primary">Add Member</button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
        {users.map((user) => (
          <div key={user.USER_ID} className="card p-6 flex flex-col">
            <div className="flex items-start justify-between mb-4">
              <div className="flex items-center">
                <div className="w-12 h-12 bg-brand-100 text-brand-600 rounded-full flex items-center justify-center font-bold text-lg">
                  {user.FIRST_NAME[0]}{user.LAST_NAME[0]}
                </div>
                <div className="ml-4">
                  <h3 className="text-lg font-bold text-slate-900">{user.FIRST_NAME} {user.LAST_NAME}</h3>
                  <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${
                    user.ACCOUNT_STATUS === 'ACTIVE' ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'
                  }`}>
                    {user.ACCOUNT_STATUS}
                  </span>
                </div>
              </div>
            </div>

            <div className="space-y-2 text-sm text-slate-600 flex-1">
              <div className="flex items-center"><Mail className="w-4 h-4 mr-2 text-slate-400" /> {user.EMAIL}</div>
              <div className="flex items-center"><Phone className="w-4 h-4 mr-2 text-slate-400" /> {user.PHONE || 'N/A'}</div>
              <div className="flex items-center"><Target className="w-4 h-4 mr-2 text-slate-400" /> Goal: <span className="font-medium text-slate-800 ml-1">{user.FITNESS_GOAL}</span></div>
              <div className="flex items-center"><User className="w-4 h-4 mr-2 text-slate-400" /> {user.GENDER} • {user.WEIGHT_KG}kg • {user.HEIGHT_CM}cm</div>
            </div>

            <div className="mt-6 pt-4 border-t border-slate-100 flex justify-end space-x-3">
              <button className="text-sm font-medium text-brand-600 hover:text-brand-700">View Details</button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default Users;
