import { Routes, Route } from 'react-router-dom';
import Layout from './components/Layout';
import Dashboard from './pages/Dashboard';
import Users from './pages/Users';
import { UserDetail, TrainerDetail } from './pages/index';
import Trainers from './pages/Trainers';
import Exercises from './pages/Exercises';
import Subscriptions from './pages/Subscriptions';
import DemoQueries from './pages/DemoQueries';
import Home from './pages/Home';

function App() {
  return (
    <Routes>
      <Route path="/" element={<Home />} />
      <Route path="/app" element={<Layout />}>
        <Route index element={<Dashboard />} />
        <Route path="users" element={<Users />} />
        <Route path="users/:id" element={<UserDetail />} />
        <Route path="trainers" element={<Trainers />} />
        <Route path="trainers/:id" element={<TrainerDetail />} />
        <Route path="exercises" element={<Exercises />} />
        <Route path="subscriptions" element={<Subscriptions />} />
        <Route path="queries" element={<DemoQueries />} />
      </Route>
    </Routes>
  );
}

export default App;
