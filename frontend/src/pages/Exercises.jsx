import React, { useState, useEffect } from 'react';
import api from '../api/api';
import { Activity, Clock, Flame, Loader, AlertCircle, Search } from 'lucide-react';

const Exercises = () => {
  const [exercises, setExercises] = useState([]);
  const [filtered, setFiltered] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [search, setSearch] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('All');

  useEffect(() => {
    api.get('/exercises')
      .then((res) => { setExercises(res.data); setFiltered(res.data); })
      .catch(() => setError('Could not load exercises. Ensure the backend and Oracle DB are running.'))
      .finally(() => setLoading(false));
  }, []);

  useEffect(() => {
    let result = exercises;
    if (categoryFilter !== 'All') result = result.filter(e => e.CATEGORY === categoryFilter);
    if (search) result = result.filter(e => e.EXERCISE_NAME?.toLowerCase().includes(search.toLowerCase()));
    setFiltered(result);
  }, [search, categoryFilter, exercises]);

  const categories = ['All', ...new Set(exercises.map(e => e.CATEGORY).filter(Boolean))];

  if (loading) return (
    <div className="flex items-center justify-center py-24">
      <Loader className="w-6 h-6 animate-spin text-brand-600" />
      <span className="ml-3 text-slate-500 text-sm">Loading exercises from Oracle 11g...</span>
    </div>
  );

  if (error) return (
    <div className="flex items-center gap-2 bg-red-50 border border-red-200 text-red-700 p-4 rounded-lg text-sm">
      <AlertCircle className="w-4 h-4 shrink-0" /><span>{error}</span>
    </div>
  );

  return (
    <div className="space-y-5">
      <div className="flex justify-between items-center">
        <div>
          <h2 className="text-2xl font-bold text-slate-900">Exercise Library</h2>
          <p className="text-sm text-slate-500 mt-0.5">{filtered.length} of {exercises.length} exercises</p>
        </div>
        <button className="btn-primary">Add Exercise</button>
      </div>

      {/* Filters */}
      <div className="flex flex-wrap gap-3 items-center">
        <div className="relative">
          <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
          <input
            type="text"
            placeholder="Search exercises..."
            value={search}
            onChange={e => setSearch(e.target.value)}
            className="pl-9 pr-4 py-2 text-sm border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-brand-500 bg-white"
          />
        </div>
        <div className="flex gap-2 flex-wrap">
          {categories.map(cat => (
            <button
              key={cat}
              onClick={() => setCategoryFilter(cat)}
              className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all ${categoryFilter === cat ? 'bg-brand-600 text-white' : 'bg-white border border-slate-200 text-slate-600 hover:border-brand-400'}`}
            >
              {cat}
            </button>
          ))}
        </div>
      </div>

      {filtered.length === 0 ? (
        <div className="text-center text-slate-500 py-16 card">No exercises match your filter.</div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          {filtered.map((ex) => (
            <div key={ex.EXERCISE_ID} className="card p-4 hover:shadow-md transition-shadow">
              <div className="flex justify-between items-start mb-3">
                <span className="text-xs font-bold uppercase tracking-wide text-brand-700 bg-brand-50 px-2 py-0.5 rounded">{ex.CATEGORY}</span>
                <span className={`text-xs px-2 py-0.5 rounded font-semibold ${
                  ex.DIFFICULTY === 'Beginner' ? 'bg-green-100 text-green-700' :
                  ex.DIFFICULTY === 'Intermediate' ? 'bg-yellow-100 text-yellow-700' :
                  'bg-red-100 text-red-700'}`}>{ex.DIFFICULTY}
                </span>
              </div>
              <h3 className="font-bold text-slate-900 mb-0.5 text-sm leading-tight">{ex.EXERCISE_NAME}</h3>
              <p className="text-xs font-medium text-slate-500 mb-2">{ex.MUSCLE_GROUP} Focus</p>
              <p className="text-xs text-slate-500 line-clamp-2 mb-3 min-h-[2rem]">{ex.DESCRIPTION}</p>
              <div className="flex items-center justify-between text-xs text-slate-500 border-t border-slate-100 pt-2">
                <span className="flex items-center gap-1"><Clock className="w-3 h-3" />{ex.DURATION_MINUTES}m</span>
                <span className="flex items-center gap-1"><Flame className="w-3 h-3 text-orange-400" />{ex.CALORIES_PER_SET} cal</span>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default Exercises;
