# Fitness & Wellness Ecosystem

This project is a complete end-to-end demonstration of a relational database system powered by **Oracle 11g**. It includes a Node.js API backend and a modern React/Tailwind frontend to visualize and interact with the data.

## Project Structure

- `db_project/` - The complete Oracle 11g SQL/PLSQL script (`COMPLETE_PROJECT.sql`) and documentation.
- `backend/` - Node.js/Express REST API that connects to Oracle.
- `frontend/` - React & Tailwind CSS web application.

---

## 1. Database Setup (Oracle 11g)

1. Open `db_project/COMPLETE_PROJECT.sql` in **Oracle SQL Developer** or SQL*Plus.
2. Run the script against your desired schema (press **F5** in SQL Developer to run as script).
3. Ensure your Oracle listener is running.

## 2. Backend Setup (Node.js)

The backend exposes REST APIs using the `oracledb` npm package.

1. Open a terminal and navigate to the backend folder:
   ```bash
   cd backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Configure the Database Connection:
   Edit the `.env` file in the `backend` folder and add your Oracle credentials:
   ```env
   DB_USER=your_oracle_username
   DB_PASSWORD=your_oracle_password
   DB_CONNECT_STRING=localhost/XE
   PORT=5000
   ```
4. Start the server:
   ```bash
   npm run dev
   ```
   *(The server will run on http://localhost:5000)*

## 3. Frontend Setup (React + Tailwind)

The frontend is a Vite + React application styled with Tailwind CSS.

1. Open a new terminal and navigate to the frontend folder:
   ```bash
   cd frontend
   ```
2. Start the development server:
   ```bash
   npm run dev
   ```
   *(The frontend will run on http://localhost:3000)*

---

## Features Displayed in the App

1. **Dashboard:** Pulls aggregate counts and recent subscriptions using `COUNT()` and `FETCH FIRST N ROWS`.
2. **Users & Trainers:** Pulls normalized data with a JOIN between `APP_USER`/`TRAINER` and `ACCOUNT`.
3. **Exercises:** Master catalog mapping.
4. **Subscriptions:** Displays the output of the `VW_ACTIVE_SUBSCRIPTIONS` view, including auto-calculated days remaining.
5. **Demo Queries Page:** A dedicated analytics page that executes and formats output for all complex JOINs, SUBQUERIES, VIEWS, and REPORTS defined in the semester project requirements.
