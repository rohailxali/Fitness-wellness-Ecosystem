-- ============================================================
-- FITNESS & WELLNESS ECOSYSTEM
-- File 2: Sample Data (INSERT Statements)
-- Execute AFTER 01_schema_and_sequences.sql
-- ============================================================

-- ============================================================
-- 2.1  ACCOUNT rows  (5 Users + 3 Trainers = 8 accounts)
-- ============================================================
INSERT INTO ACCOUNT VALUES (seq_account.NEXTVAL, 'sara.khan@email.com',    'hashed_pw_001', '0300-1234567', 'USER',    'ACTIVE',   DATE '2024-01-10');
INSERT INTO ACCOUNT VALUES (seq_account.NEXTVAL, 'ali.raza@email.com',     'hashed_pw_002', '0301-2345678', 'USER',    'ACTIVE',   DATE '2024-02-15');
INSERT INTO ACCOUNT VALUES (seq_account.NEXTVAL, 'maryam.noor@email.com',  'hashed_pw_003', '0302-3456789', 'USER',    'ACTIVE',   DATE '2024-03-01');
INSERT INTO ACCOUNT VALUES (seq_account.NEXTVAL, 'hamza.tariq@email.com',  'hashed_pw_004', '0303-4567890', 'USER',    'INACTIVE', DATE '2024-03-20');
INSERT INTO ACCOUNT VALUES (seq_account.NEXTVAL, 'zara.sheikh@email.com',  'hashed_pw_005', '0304-5678901', 'USER',    'ACTIVE',   DATE '2024-04-05');
INSERT INTO ACCOUNT VALUES (seq_account.NEXTVAL, 'coach.arif@fit.com',     'hashed_pw_006', '0311-1112222', 'TRAINER', 'ACTIVE',   DATE '2023-06-01');
INSERT INTO ACCOUNT VALUES (seq_account.NEXTVAL, 'trainer.hina@fit.com',   'hashed_pw_007', '0312-2223333', 'TRAINER', 'ACTIVE',   DATE '2023-07-15');
INSERT INTO ACCOUNT VALUES (seq_account.NEXTVAL, 'coach.bilal@fit.com',    'hashed_pw_008', '0313-3334444', 'TRAINER', 'ACTIVE',   DATE '2023-09-01');


-- ============================================================
-- 2.2  APP_USER rows
-- account_id values are 1001..1005 (first 5 accounts above)
-- ============================================================
INSERT INTO APP_USER VALUES (seq_user.NEXTVAL, 1001, 'Sara',   'Khan',   DATE '1995-04-12', 'Female', 162.0, 65.0, 'Weight Loss');
INSERT INTO APP_USER VALUES (seq_user.NEXTVAL, 1002, 'Ali',    'Raza',   DATE '1990-09-25', 'Male',   175.0, 82.0, 'Muscle Gain');
INSERT INTO APP_USER VALUES (seq_user.NEXTVAL, 1003, 'Maryam', 'Noor',   DATE '1998-01-30', 'Female', 158.0, 58.0, 'Maintenance');
INSERT INTO APP_USER VALUES (seq_user.NEXTVAL, 1004, 'Hamza',  'Tariq',  DATE '1993-07-14', 'Male',   180.0, 90.0, 'Muscle Gain');
INSERT INTO APP_USER VALUES (seq_user.NEXTVAL, 1005, 'Zara',   'Sheikh', DATE '2000-11-05', 'Female', 165.0, 60.0, 'Endurance');


-- ============================================================
-- 2.3  TRAINER rows
-- account_id values are 1006..1008
-- ============================================================
INSERT INTO TRAINER VALUES (seq_trainer.NEXTVAL, 1006, 'Arif',  'Mehmood', 'Strength & Conditioning', 'NASM-CPT',     8,  75.00,
    'Certified strength coach with 8 years of experience helping clients build lean muscle and improve athletic performance.');
INSERT INTO TRAINER VALUES (seq_trainer.NEXTVAL, 1007, 'Hina',  'Baig',    'Nutrition & Weight Loss', 'ACE-CPT',      5,  60.00,
    'Specialist in sustainable weight management through clean nutrition and low-impact cardio programs.');
INSERT INTO TRAINER VALUES (seq_trainer.NEXTVAL, 1008, 'Bilal', 'Shahid',  'HIIT & Functional Fitness', 'ISSA-CSCS', 10, 90.00,
    'Elite functional fitness trainer. Focuses on metabolic conditioning and sport-specific performance gains.');


-- ============================================================
-- 2.4  EXERCISE catalog  (12 exercises across categories)
-- ============================================================
INSERT INTO EXERCISE VALUES (seq_exercise.NEXTVAL, 'Barbell Back Squat',    'Strength',    'Legs',         'Intermediate', 'Compound lower-body movement targeting quads, glutes, and hamstrings.',          8,   45.00, 'Barbell, Rack');
INSERT INTO EXERCISE VALUES (seq_exercise.NEXTVAL, 'Flat Bench Press',      'Strength',    'Chest',        'Intermediate', 'Classic horizontal push targeting the pectoralis major and triceps.',            8,   40.00, 'Barbell, Bench');
INSERT INTO EXERCISE VALUES (seq_exercise.NEXTVAL, 'Pull-Up',               'Strength',    'Back',         'Intermediate', 'Vertical pull using bodyweight; develops lats and biceps.',                       6,   30.00, 'Pull-up Bar');
INSERT INTO EXERCISE VALUES (seq_exercise.NEXTVAL, 'Romanian Deadlift',     'Strength',    'Hamstrings',   'Intermediate', 'Hip-hinge movement focusing on the posterior chain.',                             8,   42.00, 'Barbell');
INSERT INTO EXERCISE VALUES (seq_exercise.NEXTVAL, 'Treadmill Running',     'Cardio',      'Full Body',    'Beginner',     '30-minute steady-state cardio run at moderate pace.',                             30,  200.00,'Treadmill');
INSERT INTO EXERCISE VALUES (seq_exercise.NEXTVAL, 'Cycling (Stationary)',  'Cardio',      'Legs',         'Beginner',     'Low-impact cardio on a stationary bike targeting aerobic capacity.',               25,  180.00,'Stationary Bike');
INSERT INTO EXERCISE VALUES (seq_exercise.NEXTVAL, 'Kettlebell Swing',      'HIIT',        'Full Body',    'Intermediate', 'Explosive hip-hinge movement that elevates heart rate and strengthens posterior chain.', 5, 35.00, 'Kettlebell');
INSERT INTO EXERCISE VALUES (seq_exercise.NEXTVAL, 'Battle Ropes',          'HIIT',        'Shoulders',    'Advanced',     'High-intensity upper-body cardio using heavy ropes.',                             4,   50.00, 'Battle Ropes');
INSERT INTO EXERCISE VALUES (seq_exercise.NEXTVAL, 'Yoga Sun Salutation',   'Flexibility', 'Full Body',    'Beginner',     'Classical yoga sequence improving flexibility, breath control, and mindfulness.', 20,  80.00, 'Yoga Mat');
INSERT INTO EXERCISE VALUES (seq_exercise.NEXTVAL, 'Foam Rolling (ITB)',    'Flexibility', 'Legs',         'Beginner',     'Self-myofascial release targeting the iliotibial band.',                          10,  20.00, 'Foam Roller');
INSERT INTO EXERCISE VALUES (seq_exercise.NEXTVAL, 'Plank Hold',            'Strength',    'Core',         'Beginner',     'Isometric core stability exercise.',                                              5,   15.00, 'None');
INSERT INTO EXERCISE VALUES (seq_exercise.NEXTVAL, 'Box Jump',              'HIIT',        'Legs',         'Advanced',     'Explosive plyometric jump onto a raised platform.',                               6,   40.00, 'Plyo Box');


-- ============================================================
-- 2.5  SUBSCRIPTION tiers
-- ============================================================
INSERT INTO SUBSCRIPTION VALUES (seq_subscription.NEXTVAL, 'Basic Monthly',     'Basic',    999.00,  30,  2, 'NO',
    'Access to workout library, 2 plans, community forum');
INSERT INTO SUBSCRIPTION VALUES (seq_subscription.NEXTVAL, 'Standard Quarterly','Standard', 2499.00, 90,  5, 'YES',
    'All Basic features + trainer messaging, 5 plans, progress tracking');
INSERT INTO SUBSCRIPTION VALUES (seq_subscription.NEXTVAL, 'Premium Annual',    'Premium',  7999.00, 365, 99,'YES',
    'All Standard features + unlimited plans, live sessions, nutrition coaching, priority support');
INSERT INTO SUBSCRIPTION VALUES (seq_subscription.NEXTVAL, 'Basic Quarterly',   'Basic',    2499.00, 90,  2, 'NO',
    'Access to workout library, 2 plans, community forum - 3 month bundle');


-- ============================================================
-- 2.6  WORKOUT_PLAN  (4 plans authored by trainers)
-- trainer_id: 3001=Arif, 3002=Hina, 3003=Bilal
-- ============================================================
INSERT INTO WORKOUT_PLAN VALUES (seq_workout_plan.NEXTVAL, 3001, 'Power Builder 8-Week',        'Muscle Gain',  'Intermediate', 8,  'Progressive overload strength program. 4 days per week focusing on compound lifts.',            DATE '2024-01-15');
INSERT INTO WORKOUT_PLAN VALUES (seq_workout_plan.NEXTVAL, 3002, 'Lean & Light 6-Week',         'Weight Loss',  'Beginner',     6,  'Combination of cardio and bodyweight resistance. 5 days per week with active rest days.',       DATE '2024-02-01');
INSERT INTO WORKOUT_PLAN VALUES (seq_workout_plan.NEXTVAL, 3003, 'HIIT Shred 4-Week',           'Fat Loss',     'Advanced',     4,  'Intense metabolic conditioning using HIIT circuits. Not for beginners. 5 days per week.',       DATE '2024-02-20');
INSERT INTO WORKOUT_PLAN VALUES (seq_workout_plan.NEXTVAL, 3001, 'Functional Athlete 12-Week',  'Endurance',    'Intermediate', 12, 'Sport-specific conditioning plan blending strength and stamina work. 4 days per week.',        DATE '2024-03-10');


-- ============================================================
-- 2.7  WORKOUT_PLAN_EXERCISE (bridge rows)
-- workout_plan_id: 5001=Power Builder, 5002=Lean & Light
--                 5003=HIIT Shred,    5004=Functional Athlete
-- exercise_id:    4001..4012
-- ============================================================
-- Power Builder  (Day 1: Chest/Triceps, Day 2: Back/Biceps, Day 3: Legs)
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5001, 4002, 1, 4, 8,  90, 'Primary chest movement. Increase weight each week.');
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5001, 4011, 1, 3, 60, 45, 'Superset with bench press as finisher.');
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5001, 4003, 2, 4, 6,  90, 'Weighted if possible. Full range of motion.');
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5001, 4001, 3, 5, 5,  120,'Heavy squat. Warm up thoroughly.');
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5001, 4004, 3, 3, 10, 90, 'Romanian deadlift as accessory lift.');

-- Lean & Light  (Day 1: Cardio, Day 2: Flexibility + Core)
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5002, 4005, 1, 1, 1,  0,  '30-min moderate pace run. Keep HR 130-150 bpm.');
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5002, 4011, 2, 3, 30, 30, 'Plank hold for 30 seconds per set.');
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5002, 4009, 2, 2, 1,  0,  'Full sun salutation sequence (12 poses).');
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5002, 4006, 3, 1, 1,  0,  '25-minute cycling interval session.');

-- HIIT Shred  (Day 1: Battle circuits, Day 2: Plyometrics)
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5003, 4007, 1, 4, 20, 30, 'Kettlebell swings in 20-rep bursts. Short rest.');
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5003, 4008, 1, 3, 30, 45, 'Battle ropes 30-sec all-out effort.');
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5003, 4012, 2, 4, 10, 60, 'Box jumps with controlled landing.');

-- Functional Athlete  (Day 1: Lower, Day 2: Upper, Day 3: Conditioning)
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5004, 4001, 1, 4, 6,  120,'Squat with pause at bottom.');
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5004, 4004, 1, 3, 8,  90, 'Hip hinge focus.');
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5004, 4002, 2, 4, 8,  90, 'Bench press moderate load.');
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5004, 4003, 2, 4, 6,  90, 'Weighted pull-ups if possible.');
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5004, 4005, 3, 1, 1,  0,  'Endurance run 30 min.');


-- ============================================================
-- 2.8  MEAL_PLAN
-- ============================================================
INSERT INTO MEAL_PLAN VALUES (seq_meal_plan.NEXTVAL, 3001, 'Muscle Builder Nutrition',   'Muscle Gain',  3200, 200.0, 350.0, 80.0,
    'High-protein, high-calorie plan supporting hypertrophy. Emphasizes lean meats, complex carbs, healthy fats.',        DATE '2024-01-15');
INSERT INTO MEAL_PLAN VALUES (seq_meal_plan.NEXTVAL, 3002, 'Caloric Deficit Clean Eat',  'Weight Loss',  1600, 130.0, 150.0, 45.0,
    'Moderate deficit plan using whole foods. Low sugar, high fibre, lean protein priority.',                              DATE '2024-02-01');
INSERT INTO MEAL_PLAN VALUES (seq_meal_plan.NEXTVAL, 3002, 'Maintenance Balance Plan',   'Maintenance',  2000, 150.0, 220.0, 55.0,
    'Balanced macros for maintaining current weight while supporting moderate activity.',                                  DATE '2024-03-05');
INSERT INTO MEAL_PLAN VALUES (seq_meal_plan.NEXTVAL, 3003, 'Performance Fuel Plan',      'Endurance',    2800, 170.0, 360.0, 65.0,
    'Carb-focused plan designed for athletes with high training volume. Supports glycogen replenishment.',                 DATE '2024-03-10');


-- ============================================================
-- 2.9  USER_SUBSCRIPTION
-- user_id: 2001=Sara, 2002=Ali, 2003=Maryam, 2004=Hamza, 2005=Zara
-- subscription_id: 7001=Basic Monthly, 7002=Standard Quarterly,
--                  7003=Premium Annual, 7004=Basic Quarterly
-- ============================================================
INSERT INTO USER_SUBSCRIPTION VALUES (seq_user_subscription.NEXTVAL, 2001, 7003, DATE '2024-01-10', DATE '2025-01-09', 'ACTIVE',   'Credit Card', 7999.00);
INSERT INTO USER_SUBSCRIPTION VALUES (seq_user_subscription.NEXTVAL, 2002, 7002, DATE '2024-02-15', DATE '2024-05-14', 'EXPIRED',  'Debit Card',  2499.00);
INSERT INTO USER_SUBSCRIPTION VALUES (seq_user_subscription.NEXTVAL, 2002, 7003, DATE '2024-05-15', DATE '2025-05-14', 'ACTIVE',   'Credit Card', 7999.00);
INSERT INTO USER_SUBSCRIPTION VALUES (seq_user_subscription.NEXTVAL, 2003, 7001, DATE '2024-03-01', DATE '2024-03-31', 'EXPIRED',  'JazzCash',    999.00);
INSERT INTO USER_SUBSCRIPTION VALUES (seq_user_subscription.NEXTVAL, 2003, 7002, DATE '2024-04-01', DATE '2024-06-30', 'ACTIVE',   'JazzCash',    2499.00);
INSERT INTO USER_SUBSCRIPTION VALUES (seq_user_subscription.NEXTVAL, 2004, 7004, DATE '2024-03-20', DATE '2024-06-17', 'CANCELLED','EasyPaisa',   2499.00);
INSERT INTO USER_SUBSCRIPTION VALUES (seq_user_subscription.NEXTVAL, 2005, 7002, DATE '2024-04-05', DATE '2024-07-04', 'ACTIVE',   'Credit Card', 2499.00);


-- ============================================================
-- 2.10  USER_WORKOUT_PLAN
-- ============================================================
INSERT INTO USER_WORKOUT_PLAN VALUES (seq_user_workout_plan.NEXTVAL, 2001, 5002, 3002, DATE '2024-01-12', 100.00, 'COMPLETED');
INSERT INTO USER_WORKOUT_PLAN VALUES (seq_user_workout_plan.NEXTVAL, 2001, 5001, 3001, DATE '2024-02-20', 62.50,  'IN_PROGRESS');
INSERT INTO USER_WORKOUT_PLAN VALUES (seq_user_workout_plan.NEXTVAL, 2002, 5001, 3001, DATE '2024-02-18', 87.50,  'IN_PROGRESS');
INSERT INTO USER_WORKOUT_PLAN VALUES (seq_user_workout_plan.NEXTVAL, 2002, 5004, 3001, DATE '2024-03-01', 33.33,  'PAUSED');
INSERT INTO USER_WORKOUT_PLAN VALUES (seq_user_workout_plan.NEXTVAL, 2003, 5002, 3002, DATE '2024-04-05', 50.00,  'IN_PROGRESS');
INSERT INTO USER_WORKOUT_PLAN VALUES (seq_user_workout_plan.NEXTVAL, 2004, 5003, 3003, DATE '2024-03-22', 25.00,  'DROPPED');
INSERT INTO USER_WORKOUT_PLAN VALUES (seq_user_workout_plan.NEXTVAL, 2005, 5004, 3001, DATE '2024-04-10', 41.67,  'IN_PROGRESS');


-- ============================================================
-- 2.11  USER_MEAL_PLAN
-- ============================================================
INSERT INTO USER_MEAL_PLAN VALUES (seq_user_meal_plan.NEXTVAL, 2001, 6002, 3002, DATE '2024-01-12', 'COMPLETED');
INSERT INTO USER_MEAL_PLAN VALUES (seq_user_meal_plan.NEXTVAL, 2001, 6001, 3001, DATE '2024-02-20', 'ACTIVE');
INSERT INTO USER_MEAL_PLAN VALUES (seq_user_meal_plan.NEXTVAL, 2002, 6001, 3001, DATE '2024-02-18', 'ACTIVE');
INSERT INTO USER_MEAL_PLAN VALUES (seq_user_meal_plan.NEXTVAL, 2003, 6003, 3002, DATE '2024-04-05', 'ACTIVE');
INSERT INTO USER_MEAL_PLAN VALUES (seq_user_meal_plan.NEXTVAL, 2004, 6002, 3002, DATE '2024-03-22', 'PAUSED');
INSERT INTO USER_MEAL_PLAN VALUES (seq_user_meal_plan.NEXTVAL, 2005, 6004, 3003, DATE '2024-04-10', 'ACTIVE');


-- ============================================================
-- 2.12  PROGRESS_LOG  (wellness check-ins for active users)
-- ============================================================
INSERT INTO PROGRESS_LOG VALUES (seq_progress_log.NEXTVAL, 2001, DATE '2024-01-15', 65.0, 28.5, 24.8, 'Starting measurement. Feeling motivated.');
INSERT INTO PROGRESS_LOG VALUES (seq_progress_log.NEXTVAL, 2001, DATE '2024-02-15', 63.2, 27.1, 24.1, 'Lost 1.8 kg. Energy levels improving. Sleep better.');
INSERT INTO PROGRESS_LOG VALUES (seq_progress_log.NEXTVAL, 2001, DATE '2024-03-15', 61.5, 25.9, 23.4, 'Consistent progress. Reduced body fat by 2.6% since start.');
INSERT INTO PROGRESS_LOG VALUES (seq_progress_log.NEXTVAL, 2001, DATE '2024-04-15', 60.1, 24.8, 22.9, 'On track for goal. Considering switching to maintenance plan.');
INSERT INTO PROGRESS_LOG VALUES (seq_progress_log.NEXTVAL, 2002, DATE '2024-02-20', 82.0, 18.0, 26.8, 'Baseline. Ready to bulk up. Diet in check.');
INSERT INTO PROGRESS_LOG VALUES (seq_progress_log.NEXTVAL, 2002, DATE '2024-03-20', 83.4, 17.5, 27.2, 'Gained 1.4 kg lean mass. Strength PRs on bench and squat.');
INSERT INTO PROGRESS_LOG VALUES (seq_progress_log.NEXTVAL, 2002, DATE '2024-04-20', 84.8, 17.1, 27.7, 'Excellent progress. Bench press up by 10 kg in 2 months.');
INSERT INTO PROGRESS_LOG VALUES (seq_progress_log.NEXTVAL, 2003, DATE '2024-04-07', 58.0, 22.0, 23.3, 'Initial check-in. Maintenance goal. No major changes expected.');
INSERT INTO PROGRESS_LOG VALUES (seq_progress_log.NEXTVAL, 2005, DATE '2024-04-12', 60.0, 20.5, 22.0, 'Starting endurance program. 5k run time: 32 minutes.');
INSERT INTO PROGRESS_LOG VALUES (seq_progress_log.NEXTVAL, 2005, DATE '2024-04-26', 59.5, 20.0, 21.8, 'Feeling fitter. 5k run time improved to 29 minutes.');

COMMIT;

-- End of File 2
