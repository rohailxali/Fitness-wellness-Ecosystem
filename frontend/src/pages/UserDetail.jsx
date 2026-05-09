import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import api from '../api/api';
import { User, Mail, Phone, Target, ArrowLeft, Loader, AlertCircle, Dumbbell, Utensils, Activity } from 'lucide-react';

const UserDetail = () => {
  const { id } = useParams();
  const [user, setUser] = useState(null);
  const [workoutPlans, setWorkoutPlans] = useState([]);
  const [mealPlans, setMealPlans] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    setLoading(true);
    Promise.all([
      api.get(`/users/${id}`),
      api.get(`/users/${id}/workout-plans`),
      api.get(`/users/${id}/meal-plans`)
    ]).then(([resUser, resW, resM]) => {
      setUser(resUser.data);
      setWorkoutPlans(resW.data);
      setMealPlans(resM.data);
    }).catch(() => {
      setError('Could not load user details.');
    }).finally(() => {
      setLoading(false);
    });
  }, [id]);

  if (loading) return (
    <div className="flex items-center justify-center py-24">
      <Loader className="w-6 h-6 animate-spin text-brand-600" />
      <span className="ml-3 text-slate-500 text-sm">Loading user details...</span>
    </div>
  );

  if (error || !user) return (
    <div className="flex flex-col items-center justify-center py-24">
      <AlertCircle className="w-10 h-10 text-red-500 mb-4" />
      <p className="text-red-700 font-medium mb-4">{error || 'User not found'}</p>
      <Link to="/app/users" className="btn-primary">Back to Users</Link>
    </div>
  );

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <Link to="/app/users" className="w-8 h-8 flex items-center justify-center rounded-full bg-slate-200 hover:bg-slate-300 transition text-slate-600">
          <ArrowLeft className="w-4 h-4" />
        </Link>
        <h2 className="text-2xl font-bold text-slate-900">User Profile</h2>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Profile Card */}
        <div className="card p-6 lg:col-span-1">
          <div className="flex flex-col items-center text-center pb-6 border-b border-slate-100">
            <div className="w-20 h-20 bg-brand-100 text-brand-700 rounded-full flex items-center justify-center font-bold text-2xl mb-4">
              {user.FIRST_NAME?.[0]}{user.LAST_NAME?.[0]}
            </div>
            <h3 className="text-xl font-bold text-slate-900">{user.FIRST_NAME} {user.LAST_NAME}</h3>
            <span className={`mt-2 text-xs px-3 py-1 rounded-full font-medium ${
              user.ACCOUNT_STATUS === 'ACTIVE' ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'
            }`}>
              {user.ACCOUNT_STATUS}
            </span>
          </div>
          <div className="pt-6 space-y-4 text-sm text-slate-600">
            <div className="flex items-center gap-3"><Mail className="w-4 h-4 text-slate-400" /> {user.EMAIL}</div>
            <div className="flex items-center gap-3"><Phone className="w-4 h-4 text-slate-400" /> {user.PHONE || 'N/A'}</div>
            <div className="flex items-center gap-3"><Target className="w-4 h-4 text-slate-400" /> <span className="font-medium text-slate-800">{user.FITNESS_GOAL}</span></div>
            <div className="flex items-center gap-3"><User className="w-4 h-4 text-slate-400" /> {user.GENDER}</div>
            <div className="flex items-center gap-3"><Activity className="w-4 h-4 text-slate-400" /> {user.HEIGHT_CM}cm · {user.WEIGHT_KG}kg</div>
          </div>
        </div>

        {/* Plans */}
        <div className="lg:col-span-2 space-y-6">
          <div className="card p-6">
            <h3 className="text-lg font-bold text-slate-900 mb-4 flex items-center gap-2">
              <Dumbbell className="w-5 h-5 text-brand-600" /> Assigned Workout Plans
            </h3>
            {workoutPlans.length === 0 ? (
              <p className="text-slate-500 text-sm">No workout plans assigned.</p>
            ) : (
              <div className="space-y-4">
                {workoutPlans.map(plan => (
                  <div key={plan.UWP_ID} className="flex justify-between items-center p-4 border border-slate-100 rounded-lg bg-slate-50">
                    <div>
                      <p className="font-bold text-slate-900">{plan.PLAN_NAME}</p>
                      <p className="text-xs text-slate-500 mt-1">{plan.GOAL} · {plan.DURATION_WEEKS} weeks</p>
                      <p className="text-xs text-brand-600 mt-1">Trainer: {plan.TRAINER_NAME || 'None'}</p>
                    </div>
                    <div className="text-right">
                      <span className="text-xs font-semibold px-2 py-1 rounded bg-slate-200 text-slate-700">{plan.STATUS}</span>
                      <p className="text-sm font-bold mt-2">{plan.COMPLETION_PCT}% complete</p>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          <div className="card p-6">
            <h3 className="text-lg font-bold text-slate-900 mb-4 flex items-center gap-2">
              <Utensils className="w-5 h-5 text-blue-600" /> Assigned Meal Plans
            </h3>
            {mealPlans.length === 0 ? (
              <p className="text-slate-500 text-sm">No meal plans assigned.</p>
            ) : (
              <div className="space-y-4">
                {mealPlans.map(plan => (
                  <div key={plan.UMP_ID} className="flex justify-between items-center p-4 border border-slate-100 rounded-lg bg-slate-50">
                    <div>
                      <p className="font-bold text-slate-900">{plan.PLAN_NAME}</p>
                      <p className="text-xs text-slate-500 mt-1">{plan.CALORIES_PER_DAY} kcal/day</p>
                    </div>
                    <div>
                      <span className="text-xs font-semibold px-2 py-1 rounded bg-slate-200 text-slate-700">{plan.STATUS}</span>
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

export default UserDetail;
