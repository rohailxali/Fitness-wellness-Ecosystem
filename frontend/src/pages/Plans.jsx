import React, { useState, useEffect } from 'react';
import api from '../api/api';
import { Dumbbell, Utensils, Clock, Flame, ChevronDown, ChevronUp, AlertCircle, Loader } from 'lucide-react';

const DifficultyBadge = ({ level }) => {
  const colors = {
    Beginner: 'bg-green-100 text-green-700',
    Intermediate: 'bg-yellow-100 text-yellow-700',
    Advanced: 'bg-red-100 text-red-700',
  };
  return (
    <span className={`px-2 py-0.5 rounded-full text-xs font-semibold ${colors[level] || 'bg-slate-100 text-slate-600'}`}>
      {level}
    </span>
  );
};

const ErrorState = ({ message }) => (
  <div className="flex items-center gap-2 bg-red-50 border border-red-200 text-red-700 p-4 rounded-lg text-sm">
    <AlertCircle className="w-4 h-4 shrink-0" />
    <span>{message}</span>
  </div>
);

const LoadingState = () => (
  <div className="flex items-center justify-center py-20">
    <Loader className="w-6 h-6 animate-spin text-brand-600" />
    <span className="ml-2 text-slate-500 text-sm">Loading from Oracle 11g...</span>
  </div>
);

const Plans = () => {
  const [workoutPlans, setWorkoutPlans] = useState([]);
  const [mealPlans, setMealPlans] = useState([]);
  const [loadingW, setLoadingW] = useState(true);
  const [loadingM, setLoadingM] = useState(true);
  const [errorW, setErrorW] = useState('');
  const [errorM, setErrorM] = useState('');
  const [expandedW, setExpandedW] = useState(null);
  const [expandedM, setExpandedM] = useState(null);
  const [activeTab, setActiveTab] = useState('workout');

  useEffect(() => {
    api.get('/workout-plans')
      .then(res => setWorkoutPlans(res.data))
      .catch(() => setErrorW('Could not load workout plans. Backend may be offline.'))
      .finally(() => setLoadingW(false));

    api.get('/meal-plans')
      .then(res => setMealPlans(res.data))
      .catch(() => setErrorM('Could not load meal plans. Backend may be offline.'))
      .finally(() => setLoadingM(false));
  }, []);

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold text-slate-900">Plans Library</h2>
        <div className="flex bg-slate-100 rounded-lg p-1 gap-1">
          <button
            onClick={() => setActiveTab('workout')}
            className={`flex items-center gap-2 px-4 py-2 rounded-md text-sm font-medium transition-all ${activeTab === 'workout' ? 'bg-white shadow text-brand-700' : 'text-slate-500 hover:text-slate-700'}`}
          >
            <Dumbbell className="w-4 h-4" /> Workout Plans
          </button>
          <button
            onClick={() => setActiveTab('meal')}
            className={`flex items-center gap-2 px-4 py-2 rounded-md text-sm font-medium transition-all ${activeTab === 'meal' ? 'bg-white shadow text-blue-700' : 'text-slate-500 hover:text-slate-700'}`}
          >
            <Utensils className="w-4 h-4" /> Meal Plans
          </button>
        </div>
      </div>

      {/* Workout Plans Tab */}
      {activeTab === 'workout' && (
        <div>
          {loadingW && <LoadingState />}
          {errorW && <ErrorState message={errorW} />}
          {!loadingW && !errorW && workoutPlans.length === 0 && (
            <div className="text-center text-slate-500 py-16">No workout plans found.</div>
          )}
          {!loadingW && !errorW && (
            <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
              {workoutPlans.map((plan) => (
                <div key={plan.WORKOUT_PLAN_ID || plan.workout_plan_id} className="card p-5 hover:shadow-md transition-shadow">
                  <div className="flex items-start justify-between mb-3">
                    <div className="w-10 h-10 bg-brand-50 rounded-lg flex items-center justify-center">
                      <Dumbbell className="w-5 h-5 text-brand-600" />
                    </div>
                    <DifficultyBadge level={plan.DIFFICULTY || plan.difficulty} />
                  </div>
                  <h3 className="font-bold text-slate-900 mb-1">{plan.PLAN_NAME || plan.plan_name}</h3>
                  <p className="text-sm text-brand-600 font-medium mb-3">{plan.GOAL || plan.goal}</p>
                  <div className="flex items-center gap-4 text-xs text-slate-500">
                    <span className="flex items-center gap-1"><Clock className="w-3 h-3" />{plan.DURATION_WEEKS || plan.duration_weeks} weeks</span>
                    {plan.TRAINER_NAME && <span>👤 {plan.TRAINER_NAME}</span>}
                  </div>
                  <button
                    onClick={() => setExpandedW(expandedW === plan.WORKOUT_PLAN_ID ? null : plan.WORKOUT_PLAN_ID)}
                    className="mt-3 w-full flex items-center justify-center gap-1 text-xs text-slate-400 hover:text-brand-600 transition-colors pt-3 border-t border-slate-100"
                  >
                    {expandedW === plan.WORKOUT_PLAN_ID ? <><ChevronUp className="w-3 h-3" />Less</> : <><ChevronDown className="w-3 h-3" />Details</>}
                  </button>
                  {expandedW === plan.WORKOUT_PLAN_ID && (
                    <div className="mt-3 text-xs text-slate-500 bg-slate-50 rounded p-3 space-y-1">
                      <p><span className="font-medium">Plan ID:</span> {plan.WORKOUT_PLAN_ID || plan.workout_plan_id}</p>
                      <p><span className="font-medium">Trainer ID:</span> {plan.TRAINER_ID || plan.trainer_id || 'N/A'}</p>
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {/* Meal Plans Tab */}
      {activeTab === 'meal' && (
        <div>
          {loadingM && <LoadingState />}
          {errorM && <ErrorState message={errorM} />}
          {!loadingM && !errorM && mealPlans.length === 0 && (
            <div className="text-center text-slate-500 py-16">No meal plans found.</div>
          )}
          {!loadingM && !errorM && (
            <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
              {mealPlans.map((plan) => (
                <div key={plan.MEAL_PLAN_ID || plan.meal_plan_id} className="card p-5 hover:shadow-md transition-shadow">
                  <div className="flex items-start justify-between mb-3">
                    <div className="w-10 h-10 bg-blue-50 rounded-lg flex items-center justify-center">
                      <Utensils className="w-5 h-5 text-blue-600" />
                    </div>
                    <span className="text-xs font-semibold text-blue-700 bg-blue-50 px-2 py-0.5 rounded-full">Meal Plan</span>
                  </div>
                  <h3 className="font-bold text-slate-900 mb-1">{plan.PLAN_NAME || plan.plan_name}</h3>
                  <p className="text-sm text-blue-600 font-medium mb-3">{plan.GOAL || plan.goal}</p>
                  <div className="flex items-center gap-4 text-xs text-slate-500">
                    <span className="flex items-center gap-1"><Flame className="w-3 h-3 text-orange-400" />{plan.CALORIES_PER_DAY || plan.calories_per_day} kcal/day</span>
                  </div>
                  <button
                    onClick={() => setExpandedM(expandedM === plan.MEAL_PLAN_ID ? null : plan.MEAL_PLAN_ID)}
                    className="mt-3 w-full flex items-center justify-center gap-1 text-xs text-slate-400 hover:text-blue-600 transition-colors pt-3 border-t border-slate-100"
                  >
                    {expandedM === plan.MEAL_PLAN_ID ? <><ChevronUp className="w-3 h-3" />Less</> : <><ChevronDown className="w-3 h-3" />Nutrition</>}
                  </button>
                  {expandedM === plan.MEAL_PLAN_ID && (
                    <div className="mt-3 text-xs text-slate-600 bg-slate-50 rounded p-3 grid grid-cols-3 gap-2 text-center">
                      <div><p className="font-bold text-slate-900">{plan.PROTEIN_G || plan.protein_g}g</p><p className="text-slate-400">Protein</p></div>
                      <div><p className="font-bold text-slate-900">{plan.CARBS_G || plan.carbs_g}g</p><p className="text-slate-400">Carbs</p></div>
                      <div><p className="font-bold text-slate-900">{plan.FATS_G || plan.fats_g}g</p><p className="text-slate-400">Fats</p></div>
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default Plans;
