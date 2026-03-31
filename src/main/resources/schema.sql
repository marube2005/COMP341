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
    active      TINYINT(1)    NOT NULL DEFAULT 1,
    created_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

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
-- Maintenance requests table
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS maintenance_requests (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    facility_id     INT           NOT NULL,
    reported_by     INT           NOT NULL,          -- user id
    assigned_to     INT,                             -- janitor/supervisor user id
    title           VARCHAR(200)  NOT NULL,
    description     TEXT          NOT NULL,
    priority        ENUM('low','medium','high','urgent') NOT NULL DEFAULT 'medium',
    status          ENUM('pending','in_progress','resolved','closed') NOT NULL DEFAULT 'pending',
    created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_mr_facility FOREIGN KEY (facility_id) REFERENCES facilities(id) ON DELETE CASCADE,
    CONSTRAINT fk_mr_reporter FOREIGN KEY (reported_by) REFERENCES users(id),
    CONSTRAINT fk_mr_assignee FOREIGN KEY (assigned_to)  REFERENCES users(id)
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
--   admin@egerton.ac.ke    → admin123
--   swanjiku@egerton.ac.ke → lecturer123
--   jkamau@egerton.ac.ke   → janitor123
--   mchebet@egerton.ac.ke  → super123
-- ─────────────────────────────────────────────────────────────
INSERT IGNORE INTO users (id, name, email, password, role, phone, department) VALUES
(1, 'System Administrator', 'admin@egerton.ac.ke',
 '$2a$12$8dvqkQCV/XismkxR6/sEt.M5UR3269RycFU/prN/uMaIULYwu4sqm',
 'admin', '+254700000001', 'ICT'),
(2, 'Dr. Sarah Wanjiku', 'swanjiku@egerton.ac.ke',
 '$2a$12$Jo/.e/mrsszbM1pAil4Qk.1rcYqT/qEqSwEYb8BZ7WvRXQeoLN4MO',
 'lecturer', '+254700000002', 'Computer Science'),
(3, 'James Kamau', 'jkamau@egerton.ac.ke',
 '$2a$12$uRwWXOUEHz7Ot6kCmozKcOeJN9OHQRRzyOiQ1HvlnvhPbEyy4dxou',
 'janitor', '+254700000003', 'Facilities'),
(4, 'Mary Chebet', 'mchebet@egerton.ac.ke',
 '$2a$12$YylEmtjkMbs1sVkRyCiRa.h4GWkd7t5RKaQU1ep8NfwxR9TAmKF6G',
 'supervisor', '+254700000004', 'Facilities');

-- Ensure demo account passwords are always correct (idempotent – safe to re-run).
-- These UPDATE statements run unconditionally so that any existing database with
-- incorrect hashes is automatically fixed when the schema is re-applied.
UPDATE users SET password = '$2a$12$8dvqkQCV/XismkxR6/sEt.M5UR3269RycFU/prN/uMaIULYwu4sqm'
    WHERE id = 1 AND email = 'admin@egerton.ac.ke';
UPDATE users SET password = '$2a$12$Jo/.e/mrsszbM1pAil4Qk.1rcYqT/qEqSwEYb8BZ7WvRXQeoLN4MO'
    WHERE id = 2 AND email = 'swanjiku@egerton.ac.ke';
UPDATE users SET password = '$2a$12$uRwWXOUEHz7Ot6kCmozKcOeJN9OHQRRzyOiQ1HvlnvhPbEyy4dxou'
    WHERE id = 3 AND email = 'jkamau@egerton.ac.ke';
UPDATE users SET password = '$2a$12$YylEmtjkMbs1sVkRyCiRa.h4GWkd7t5RKaQU1ep8NfwxR9TAmKF6G'
    WHERE id = 4 AND email = 'mchebet@egerton.ac.ke';

INSERT IGNORE INTO facilities (id, name, location, facility_type, capacity, status, description) VALUES
(1, 'A101', 'Wing A', 'office', 10, 'available', 'Wing A ground floor office'),
(2, 'A201', 'Wing A', 'office', 10, 'available', 'Wing A second floor office'),
(3, 'B101', 'Wing B', 'office', 10, 'available', 'Wing B ground floor office'),
(4, 'B102', 'Wing B', 'office', 10, 'available', 'Wing B ground floor office'),
(5, 'C101', 'Wing C', 'office', 10, 'available', 'Wing C ground floor office');

INSERT IGNORE INTO maintenance_requests (id, facility_id, reported_by, assigned_to, title, description, priority, status) VALUES
(1, 1, 2, 3, 'Broken projector', 'The projector in office A101 stopped working.', 'high', 'pending'),
(2, 3, 2, 3, 'Leaking tap', 'The tap in office B101 is leaking.', 'medium', 'in_progress');

INSERT IGNORE INTO cleaning_tasks (id, facility_id, assigned_to, scheduled_date, status, notes) VALUES
(1, 1, 3, CURDATE(), 'pending', 'Regular morning cleaning of A101'),
(2, 3, 3, CURDATE(), 'in_progress', 'Deep clean B101 office');
