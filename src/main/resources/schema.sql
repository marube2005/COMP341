-- SmartCampus Facility Management System - Database Schema
-- Egerton University
--
-- Quick-start (run once as MySQL root):
--   mysql -u root -p < schema.sql
--
-- The script is fully idempotent (IF NOT EXISTS / INSERT IGNORE) and
-- safe to re-run.  It also creates a dedicated application user
-- 'scm_app'@'localhost' with no password for use in development /
-- demo environments.  For production, replace with a strong password.

CREATE DATABASE IF NOT EXISTS smartcampus CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE smartcampus;

-- ─────────────────────────────────────────────────────────────
-- Application database user (example only, NOT executed)
-- For security reasons, this schema file no longer creates a
-- database user with a default or empty password.
--
-- Create a dedicated application user separately (for example):
--   CREATE USER 'scm_app'@'localhost' IDENTIFIED BY 'your_strong_password_here';
--   GRANT SELECT, INSERT, UPDATE, DELETE ON smartcampus.* TO 'scm_app'@'localhost';
--   FLUSH PRIVILEGES;
--
-- In production, use a strong, unique password and configure
-- DB_USER / DB_PASSWORD environment variables (or equivalent)
-- for the application instead of relying on defaults.
-- ─────────────────────────────────────────────────────────────

-- ─────────────────────────────────────────────────────────────
-- Users table: stores all system users
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(120)  NOT NULL,
    email       VARCHAR(150)  NOT NULL UNIQUE,
    password    VARCHAR(255)  NOT NULL,          -- BCrypt hash
    role        ENUM('admin','lecturer','janitor','supervisor') NOT NULL,
    phone       VARCHAR(20),
    department  VARCHAR(100),
    staff_id    VARCHAR(20),                     -- e.g. JAN-2024-001, ADM-2023-002, SUP-2021-134
    active      TINYINT(1)    NOT NULL DEFAULT 1,
    created_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Add staff_id column to existing installations (safe no-op if already present)
ALTER TABLE users ADD COLUMN IF NOT EXISTS staff_id VARCHAR(20);

-- ─────────────────────────────────────────────────────────────
-- Facilities table
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS facilities (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(150)  NOT NULL,
    location        VARCHAR(200)  NOT NULL,
    facility_type   ENUM('classroom','lab','office','hall','restroom','other') NOT NULL DEFAULT 'classroom',
    capacity        INT           NOT NULL DEFAULT 0,
    status          ENUM('available','occupied','maintenance','closed') NOT NULL DEFAULT 'available',
    description     TEXT,
    created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────────────────────
-- Cleaning tasks table
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS cleaning_tasks (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    facility_id     INT           NOT NULL,
    assigned_to     INT           NOT NULL,          -- janitor user id
    scheduled_date  DATE          NOT NULL,
    status          ENUM('pending','in_progress','completed','skipped') NOT NULL DEFAULT 'pending',
    notes           TEXT,
    created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_ct_facility FOREIGN KEY (facility_id) REFERENCES facilities(id) ON DELETE CASCADE,
    CONSTRAINT fk_ct_janitor  FOREIGN KEY (assigned_to) REFERENCES users(id)
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────────────────────
-- Seed data – demo accounts for local development/demo only.
-- WARNING: Remove or replace these accounts and their passwords
-- before deploying to production environments.
--
-- Passwords (BCrypt cost 12, jBCrypt 0.4):
--   admin.admin@egerton.ac.ke        → admin123
--   swanjiku.lecturer@egerton.ac.ke  → lecturer123
--   jkamau.janitor@egerton.ac.ke     → janitor123
--   mchebet.supervisor@egerton.ac.ke → super123
-- ─────────────────────────────────────────────────────────────
INSERT IGNORE INTO users (id, name, email, password, role, phone, department, staff_id) VALUES
(1, 'System Administrator', 'admin.admin@egerton.ac.ke',
 '$2a$12$8dvqkQCV/XismkxR6/sEt.M5UR3269RycFU/prN/uMaIULYwu4sqm',
 'admin', '+254700000001', 'ICT', 'ADM-2023-001'),
(2, 'Dr. Sarah Wanjiku', 'swanjiku.lecturer@egerton.ac.ke',
 '$2a$12$Jo/.e/mrsszbM1pAil4Qk.1rcYqT/qEqSwEYb8BZ7WvRXQeoLN4MO',
 'lecturer', '+254700000002', 'Computer Science', NULL),
(3, 'James Kamau', 'jkamau.janitor@egerton.ac.ke',
 '$2a$12$uRwWXOUEHz7Ot6kCmozKcOeJN9OHQRRzyOiQ1HvlnvhPbEyy4dxou',
 'janitor', '+254700000003', 'Facilities', 'JAN-2021-001'),
(4, 'Mary Chebet', 'mchebet.supervisor@egerton.ac.ke',
 '$2a$12$YylEmtjkMbs1sVkRyCiRa.h4GWkd7t5RKaQU1ep8NfwxR9TAmKF6G',
 'supervisor', '+254700000004', 'Facilities', 'SUP-2022-001');

-- Ensure demo account passwords are always correct (idempotent – safe to re-run).
-- These UPDATE statements run unconditionally so that any existing database with
-- incorrect hashes is automatically fixed when the schema is re-applied.
UPDATE users SET password = '$2a$12$8dvqkQCV/XismkxR6/sEt.M5UR3269RycFU/prN/uMaIULYwu4sqm',
                email = 'admin.admin@egerton.ac.ke', staff_id = 'ADM-2023-001'
    WHERE id = 1;
UPDATE users SET password = '$2a$12$Jo/.e/mrsszbM1pAil4Qk.1rcYqT/qEqSwEYb8BZ7WvRXQeoLN4MO',
                email = 'swanjiku.lecturer@egerton.ac.ke'
    WHERE id = 2;
UPDATE users SET password = '$2a$12$uRwWXOUEHz7Ot6kCmozKcOeJN9OHQRRzyOiQ1HvlnvhPbEyy4dxou',
                email = 'jkamau.janitor@egerton.ac.ke', staff_id = 'JAN-2021-001'
    WHERE id = 3;
UPDATE users SET password = '$2a$12$YylEmtjkMbs1sVkRyCiRa.h4GWkd7t5RKaQU1ep8NfwxR9TAmKF6G',
                email = 'mchebet.supervisor@egerton.ac.ke', staff_id = 'SUP-2022-001'
    WHERE id = 4;

INSERT IGNORE INTO facilities (id, name, location, facility_type, capacity, status, description) VALUES
(1, 'A101', 'Wing A', 'office', 10, 'available', 'Wing A ground floor office'),
(2, 'A201', 'Wing A', 'office', 10, 'available', 'Wing A second floor office'),
(3, 'B101', 'Wing B', 'office', 10, 'available', 'Wing B ground floor office'),
(4, 'B102', 'Wing B', 'office', 10, 'available', 'Wing B ground floor office'),
(5, 'C101', 'Wing C', 'office', 10, 'available', 'Wing C ground floor office');

INSERT IGNORE INTO cleaning_tasks (id, facility_id, assigned_to, scheduled_date, status, notes) VALUES
(1, 1, 3, CURDATE(), 'pending', 'Regular morning cleaning of A101'),
(2, 3, 3, CURDATE(), 'in_progress', 'Deep clean B101 office');

-- ─────────────────────────────────────────────────────────────
-- Lecturer reports table: ratings and reports submitted by
-- lecturers after a janitor completes a cleaning task
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS lecturer_reports (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    task_id     INT           NOT NULL,
    lecturer_id INT           NOT NULL,
    rating      INT           NOT NULL,              -- 1 (poor) to 5 (excellent)
    report_text TEXT          NOT NULL,
    created_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_lr_task     FOREIGN KEY (task_id)     REFERENCES cleaning_tasks(id) ON DELETE CASCADE,
    CONSTRAINT fk_lr_lecturer FOREIGN KEY (lecturer_id) REFERENCES users(id),
    CONSTRAINT uq_lr_task_lecturer UNIQUE (task_id, lecturer_id)
) ENGINE=InnoDB;
