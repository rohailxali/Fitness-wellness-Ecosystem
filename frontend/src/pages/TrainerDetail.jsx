import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import api from '../api/api';
import { Mail, Phone, ArrowLeft, Loader, AlertCircle, Dumbbell, Award, FileText } from 'lucide-react';

const TrainerDetail = () => {
  const { id } = useParams();
  const [trainer, setTrainer] = useState(null);
  const [plans, setPlans] = useState({ workoutPlans: [], mealPlans: [] });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    setLoading(true);
    Promise.all([
      api.get(`/trainers/${id}`),
      api.get(`/trainers/${id}/plans`)
    ]).then(([resT, resP]) => {
      setTrainer(resT.data);
      setPlans(resP.data);
    }).catch(() => {
      setError('Could not load trainer details.');
    }).finally(() => {
      setLoading(false);
    });
  }, [id]);

  if (loading) return (
    <div className="flex items-center justify-center py-24">
      <Loader className="w-6 h-6 animate-spin text-brand-600" />
      <span className="ml-3 text-slate-500 text-sm">Loading trainer details...</span>
    </div>
  );

  if (error || !trainer) return (
    <div className="flex flex-col items-center justify-center py-24">
      <AlertCircle className="w-10 h-10 text-red-500 mb-4" />
      <p className="text-red-700 font-medium mb-4">{error || 'Trainer not found'}</p>
      <Link to="/app/trainers" className="btn-primary">Back to Trainers</Link>
    </div>
  );

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <Link to="/app/trainers" className="w-8 h-8 flex items-center justify-center rounded-full bg-slate-200 hover:bg-slate-300 transition text-slate-600">
          <ArrowLeft className="w-4 h-4" />
        </Link>
        <h2 className="text-2xl font-bold text-slate-900">Trainer Profile</h2>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Profile Card */}
        <div className="card p-6 lg:col-span-1">
          <div className="flex flex-col items-center text-center pb-6 border-b border-slate-100">
            <div className="w-20 h-20 bg-slate-200 text-slate-700 rounded-full flex items-center justify-center font-bold text-2xl mb-4">
              {trainer.FIRST_NAME?.[0]}{trainer.LAST_NAME?.[0]}
            </div>
            <h3 className="text-xl font-bold text-slate-900">{trainer.FIRST_NAME} {trainer.LAST_NAME}</h3>
            <p className="text-brand-600 font-medium mt-1">{trainer.SPECIALIZATION}</p>
            <span className={`mt-2 text-xs px-3 py-1 rounded-full font-medium ${
              trainer.ACCOUNT_STATUS === 'ACTIVE' ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'
            }`}>
              {trainer.ACCOUNT_STATUS}
            </span>
          </div>
          <div className="pt-6 space-y-4 text-sm text-slate-600">
            <div className="flex items-center gap-3"><Mail className="w-4 h-4 text-slate-400" /> {trainer.EMAIL}</div>
            <div className="flex items-center gap-3"><Phone className="w-4 h-4 text-slate-400" /> {trainer.PHONE || 'N/A'}</div>
            <div className="flex items-center gap-3"><Award className="w-4 h-4 text-slate-400" /> {trainer.CERTIFICATION}</div>
            <div className="flex items-center gap-3"><FileText className="w-4 h-4 text-slate-400" /> {trainer.EXPERIENCE_YEARS} Years Exp.</div>
            <div className="mt-4 p-4 bg-slate-50 rounded-lg text-xs italic text-slate-500">
              "{trainer.BIO}"
            </div>
          </div>
        </div>

        {/* Authored Plans */}
        <div className="lg:col-span-2 space-y-6">
          <div className="card p-6">
            <h3 className="text-lg font-bold text-slate-900 mb-4 flex items-center gap-2">
              <Dumbbell className="w-5 h-5 text-brand-600" /> Authored Plans
            </h3>
            
            {plans.workoutPlans.length === 0 && plans.mealPlans.length === 0 ? (
              <p className="text-slate-500 text-sm">No plans created by this trainer.</p>
            ) : (
              <div className="space-y-4">
                {plans.workoutPlans.map(plan => (
                  <div key={`w-${plan.ID}`} className="flex justify-between items-center p-4 border border-slate-100 rounded-lg bg-slate-50">
                    <div>
                      <span className="text-xs font-bold text-brand-600 bg-brand-50 px-2 py-0.5 rounded uppercase tracking-wide">Workout</span>
                      <p className="font-bold text-slate-900 mt-1">{plan.PLAN_NAME}</p>
                      <p className="text-xs text-slate-500 mt-1">{plan.GOAL} · {plan.DURATION_WEEKS} weeks</p>
                    </div>
                    <div>
                      <span className="text-xs px-2 py-1 rounded bg-slate-200 text-slate-700">{plan.DIFFICULTY}</span>
                    </div>
                  </div>
                ))}
                
                {plans.mealPlans.map(plan => (
                  <div key={`m-${plan.ID}`} className="flex justify-between items-center p-4 border border-slate-100 rounded-lg bg-slate-50">
                    <div>
                      <span className="text-xs font-bold text-blue-600 bg-blue-50 px-2 py-0.5 rounded uppercase tracking-wide">Meal</span>
                      <p className="font-bold text-slate-900 mt-1">{plan.PLAN_NAME}</p>
                      <p className="text-xs text-slate-500 mt-1">{plan.GOAL} · {plan.CALORIES_PER_DAY} kcal/day</p>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default TrainerDetail;
