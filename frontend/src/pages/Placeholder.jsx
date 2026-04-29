import React from 'react';

// Create placeholders for the remaining pages so routing doesn't break
export default function Placeholder({ title }) {
  return (
    <div className="p-8 text-center text-slate-500">
      <h2 className="text-2xl font-bold text-slate-900 mb-2">{title}</h2>
      <p>This page is part of the UI shell. Backend endpoints exist.</p>
    </div>
  );
}
