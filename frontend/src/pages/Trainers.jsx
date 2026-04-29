import React, { useState, useEffect } from 'react';
import api from '../api/api';
import { Award, Clock, DollarSign, Mail } from 'lucide-react';

const Trainers = () => {
  const [trainers, setTrainers] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.get('/trainers').then((res) => {
      setTrainers(res.data);
      setLoading(false);
    }).catch(console.error);
  }, []);

  if (loading) return <div className="p-8">Loading trainers...</div>;

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h2 className="text-2xl font-bold text-slate-900">Certified Trainers</h2>
        <button className="btn-primary">Onboard Trainer</button>
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-2 gap-6">
        {trainers.map((trainer) => (
          <div key={trainer.TRAINER_ID} className="card p-6 flex flex-col md:flex-row gap-6">
            <div className="flex-shrink-0 flex flex-col items-center">
              <div className="w-24 h-24 bg-slate-200 rounded-full flex items-center justify-center text-3xl font-bold text-slate-400 mb-3">
                {trainer.FIRST_NAME[0]}{trainer.LAST_NAME[0]}
              </div>
              <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${
                trainer.ACCOUNT_STATUS === 'ACTIVE' ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'
              }`}>
                {trainer.ACCOUNT_STATUS}
              </span>
            </div>

            <div className="flex-1">
              <div className="flex justify-between items-start">
                <div>
                  <h3 className="text-xl font-bold text-slate-900">{trainer.FIRST_NAME} {trainer.LAST_NAME}</h3>
                  <p className="text-brand-600 font-medium text-sm">{trainer.SPECIALIZATION}</p>
                </div>
                <div className="text-right">
                  <span className="text-lg font-bold text-slate-800">PKR {trainer.HOURLY_RATE}</span>
                  <p className="text-xs text-slate-500">/ hour</p>
                </div>
              </div>

              <p className="text-sm text-slate-600 mt-3 line-clamp-2">{trainer.BIO}</p>

              <div className="grid grid-cols-2 gap-3 mt-4 text-sm text-slate-600">
                <div className="flex items-center"><Award className="w-4 h-4 mr-2 text-slate-400" /> {trainer.CERTIFICATION}</div>
                <div className="flex items-center"><Clock className="w-4 h-4 mr-2 text-slate-400" /> {trainer.EXPERIENCE_YEARS} Years Exp.</div>
                <div className="flex items-center col-span-2"><Mail className="w-4 h-4 mr-2 text-slate-400" /> {trainer.EMAIL}</div>
              </div>
              
              <div className="mt-4 flex gap-2">
                 <button className="btn-secondary text-sm flex-1">View Profile & Plans</button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default Trainers;
