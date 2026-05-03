# Fitness & Wellness Ecosystem - Deployment & Viva Guide

This document is intended for evaluators and students presenting the "Fitness & Wellness Ecosystem" full-stack project. It outlines the architectural constraints of the project and instructions for both local demonstration and cloud deployment.

## Architecture Overview
- **Frontend**: React (Vite) + Tailwind CSS v4
- **Backend**: Node.js + Express
- **Database**: Oracle Database 11g Express Edition (Local)

---

## 1. Local Demonstration (Recommended for Viva)
This project is built around a legacy **Oracle 11g Database**. Due to the nature of Oracle 11g Thick Mode drivers, the application relies on Oracle Instant Client binaries installed natively on your local machine.

Therefore, the most robust, error-free way to demonstrate this project is **locally**.

### Steps to Run Locally:
1. **Start the Database Script**:
   Open Windows Command Prompt, run `sqlplus system/yourpassword`, and execute the master script:
   `SQL> @"C:\Projects\Fitness and wellness ecosystem\db_project\00_master_run.sql"`
2. **Start the Backend**:
   Open a new terminal, navigate to the `backend` folder, and run:
   ```bash
   npm install
   npm run dev
   ```
3. **Start the Frontend**:
   Open a new terminal, navigate to the `frontend` folder, and run:
   ```bash
   npm run dev
   ```
4. **Access the Application**:
   Open your browser to `http://localhost:3000`.

---

## 2. Cloud Deployment (The Reality Check)

### The Cloud Database Problem
Deploying this application completely to the cloud (like Render, Heroku, or Vercel) introduces a massive architectural hurdle: **Cloud servers cannot access your laptop's local Oracle database.**

Furthermore, installing Oracle Instant Client binaries into standard Linux cloud containers (necessary to connect Node.js to Oracle 11g) is extremely difficult on free-tier platforms.

### The Solution: Hybrid Cloud Tunneling (Ngrok)
If you **must** provide a live, shareable URL to your professors, use a hybrid approach: host the frontend on the cloud, but keep the backend and database local.

1. **Deploy Frontend to Vercel**:
   - Push your entire repository to GitHub.
   - Go to Vercel.com, import your repository, and select the `frontend` directory as the Root Directory.
   - Deploy.

2. **Expose your Local Backend using Ngrok**:
   - Download and install [Ngrok](https://ngrok.com/).
   - Start your local backend (`node server.js` on port 5000).
   - In a new terminal, run: `ngrok http 5000`
   - Ngrok will give you a public Forwarding URL (e.g., `https://a1b2c3d4.ngrok-free.app`).

3. **Connect Frontend to Ngrok**:
   - Go to your Vercel project settings -> Environment Variables.
   - Add a new variable: `VITE_API_URL` = `https://a1b2c3d4.ngrok-free.app/api`.
   - Redeploy the frontend.

Now, anyone on the internet can visit your Vercel URL, which will securely tunnel to your laptop's Node.js server, which talks to your local Oracle 11g database!

*(Note: Your laptop must be awake and running the backend/ngrok for the live link to work).*

---

## Security & Hardening Applied
This project has undergone a production-minded audit:
- **Helmet.js** secures HTTP headers.
- **Morgan** logs all API requests for debugging.
- **Bind Variables** (`:id`) are used strictly across all SQL queries to prevent SQL Injection.
- **Input Validation** middleware ensures numeric constraints on URL parameters.
- **Graceful Error Handling**: The React frontend intercepts network failures and displays an intuitive "Backend Offline" state rather than crashing.
