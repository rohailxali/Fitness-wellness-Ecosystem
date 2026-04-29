import React, { useState, useEffect } from 'react';
import api from '../api/api';
import { CreditCard, CheckCircle } from 'lucide-react';

const Subscriptions = () => {
  const [subs, setSubs] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.get('/subscriptions').then((res) => {
      setSubs(res.data);
      setLoading(false);
    }).catch(console.error);
  }, []);

  if (loading) return <div className="p-8">Loading subscriptions...</div>;

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h2 className="text-2xl font-bold text-slate-900">Member Subscriptions</h2>
      </div>

      <div className="card overflow-hidden">
        <table className="min-w-full divide-y divide-slate-200">
          <thead className="bg-slate-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Member</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Tier</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Type</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Status</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Time Remaining</th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-slate-200">
            {subs.map((sub) => (
              <tr key={sub.USER_SUB_ID} className="hover:bg-slate-50">
                <td className="px-6 py-4 whitespace-nowrap font-medium text-slate-900">{sub.FULL_NAME}</td>
                <td className="px-6 py-4 whitespace-nowrap text-slate-600">{sub.PLAN_NAME}</td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span className="inline-flex items-center text-sm text-slate-600">
                    <CreditCard className="w-4 h-4 mr-2 text-slate-400" /> {sub.PAYMENT_METHOD} (PKR {sub.AMOUNT_PAID})
                  </span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span className={`px-2.5 py-0.5 rounded-full text-xs font-semibold ${
                    sub.STATUS === 'ACTIVE' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                  }`}>
                    {sub.STATUS}
                  </span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-slate-600">
                  {sub.STATUS === 'ACTIVE' ? (
                    <span className="flex items-center text-brand-600 font-medium">
                      <CheckCircle className="w-4 h-4 mr-1" /> {Math.ceil(sub.DAYS_REMAINING)} days left
                    </span>
                  ) : 'Expired'}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default Subscriptions;
