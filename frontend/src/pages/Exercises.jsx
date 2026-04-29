import React, { useState, useEffect } from 'react';
import api from '../api/api';
import { Activity, Clock, Flame } from 'lucide-react';

const Exercises = () => {
  const [exercises, setExercises] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.get('/exercises').then((res) => {
      setExercises(res.data);
      setLoading(false);
    }).catch(console.error);
  }, []);

  if (loading) return <div className="p-8">Loading exercises...</div>;

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h2 className="text-2xl font-bold text-slate-900">Exercise Library</h2>
        <button className="btn-primary">Add Exercise</button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
        {exercises.map((ex) => (
          <div key={ex.EXERCISE_ID} className="card p-5 hover:shadow-md transition-shadow">
            <div className="flex justify-between items-start mb-3">
              <span className="text-xs font-bold uppercase tracking-wider text-brand-600 bg-brand-50 px-2 py-1 rounded">
                {ex.CATEGORY}
              </span>
              <span className={`text-xs px-2 py-1 rounded font-medium ${
                ex.DIFFICULTY === 'Beginner' ? 'bg-green-100 text-green-700' :
                ex.DIFFICULTY === 'Intermediate' ? 'bg-yellow-100 text-yellow-700' :
                'bg-red-100 text-red-700'
              }`}>
                {ex.DIFFICULTY}
              </span>
            </div>
            
            <h3 className="text-lg font-bold text-slate-900 mb-1">{ex.EXERCISE_NAME}</h3>
            <p className="text-sm font-medium text-slate-500 mb-3">{ex.MUSCLE_GROUP} Focus</p>
            
            <p className="text-sm text-slate-600 line-clamp-2 mb-4 h-10">{ex.DESCRIPTION}</p>
            
            <div className="flex items-center justify-between text-sm text-slate-500 border-t border-slate-100 pt-3">
              <div className="flex items-center" title="Duration per set/session">
                <Clock className="w-4 h-4 mr-1" /> {ex.DURATION_MINUTES}m
              </div>
              <div className="flex items-center" title="Calories burned">
                <Flame className="w-4 h-4 mr-1 text-orange-500" /> {ex.CALORIES_PER_SET} cal
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default Exercises;
