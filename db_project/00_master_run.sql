-- ============================================================
-- FITNESS & WELLNESS ECOSYSTEM
-- 00_master_run.sql — Single Entry Point
--
-- Run this file from SQL*Plus while connected to your schema:
--   SQL> @C:\Projects\Fitness & wellness ecosystem\db_project\00_master_run.sql
--
-- Or open in SQL Developer and press F5 (Run Script).
-- ============================================================

SET DEFINE OFF;
PROMPT ============================================================
PROMPT  Fitness and Wellness Ecosystem — Database Semester Project
PROMPT  Oracle 11g Compatible
PROMPT ============================================================
PROMPT

PROMPT [Step 1/5] Creating schema: sequences, tables, constraints...
@@01_schema_and_sequences.sql
PROMPT [Step 1/5] DONE.
PROMPT

PROMPT [Step 2/5] Inserting sample data...
@@02_sample_data.sql
PROMPT [Step 2/5] DONE.
PROMPT

PROMPT [Step 3/5] Creating views and triggers...
@@03_views_and_triggers.sql
PROMPT [Step 3/5] DONE.
PROMPT

PROMPT [Step 4/5] Compiling stored procedures and functions...
SET SERVEROUTPUT ON
@@04_procedures_and_functions.sql
PROMPT [Step 4/5] DONE.
PROMPT

PROMPT [Step 5/5] Running demo queries...
@@05_demo_queries.sql
PROMPT [Step 5/5] DONE.
PROMPT

PROMPT ============================================================
PROMPT  All steps completed successfully.
PROMPT  Open 06_documentation.md for full schema reference.
PROMPT ============================================================
