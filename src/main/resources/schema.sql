-- SmartCampus Facility Management System - Database Schema
-- Egerton University

CREATE DATABASE IF NOT EXISTS smartcampus CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE smartcampus;

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
-- Seed data – demo accounts (passwords are BCrypt hashes of the
-- values shown in the login page)
-- admin123   => $2a$12$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
-- lecturer123=> $2a$12$GudqsrBbVFVhQ4S49yNy5.T6dSnNfknxjCOcCMlYlDWfk.A05sQoe
-- janitor123 => $2a$12$TqvHfREpMb1fD1WUqZ3ZvuQWzJRf.8FqWAtYOSakLWkmhV1w01VOe
-- super123   => $2a$12$XQ0MNKXH2qPjXbBriuSITOS9z8JqmDL6mfLcPOQYcPAiAIz4hYxkO
-- ─────────────────────────────────────────────────────────────
INSERT IGNORE INTO users (id, name, email, password, role, phone, department) VALUES
(1, 'System Administrator', 'admin@egerton.ac.ke',
 '$2a$12$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
 'admin', '+254700000001', 'ICT'),
(2, 'Dr. Sarah Wanjiku', 'swanjiku@egerton.ac.ke',
 '$2a$12$GudqsrBbVFVhQ4S49yNy5.T6dSnNfknxjCOcCMlYlDWfk.A05sQoe',
 'lecturer', '+254700000002', 'Computer Science'),
(3, 'James Kamau', 'jkamau@egerton.ac.ke',
 '$2a$12$TqvHfREpMb1fD1WUqZ3ZvuQWzJRf.8FqWAtYOSakLWkmhV1w01VOe',
 'janitor', '+254700000003', 'Facilities'),
(4, 'Mary Chebet', 'mchebet@egerton.ac.ke',
 '$2a$12$XQ0MNKXH2qPjXbBriuSITOS9z8JqmDL6mfLcPOQYcPAiAIz4hYxkO',
 'supervisor', '+254700000004', 'Facilities');

INSERT IGNORE INTO facilities (id, name, location, facility_type, capacity, status, description) VALUES
(1, 'SCI 101 – Lecture Hall A', 'Science Complex, Block A', 'classroom', 120, 'available', 'Large lecture hall with projector and AC'),
(2, 'ICT Lab 2', 'Science Complex, Block B', 'lab', 40, 'available', 'Computer laboratory with 40 workstations'),
(3, 'Staff Room – Ground Floor', 'Science Complex, Block A', 'office', 15, 'available', 'Staff common room'),
(4, 'Main Hall', 'Administration Block', 'hall', 500, 'available', 'Main university hall for events'),
(5, 'Restrooms – Block A', 'Science Complex, Block A', 'restroom', 0, 'available', 'Gender-separated restrooms');

INSERT IGNORE INTO maintenance_requests (id, facility_id, reported_by, assigned_to, title, description, priority, status) VALUES
(1, 1, 2, 3, 'Broken projector', 'The projector in SCI 101 stopped working mid-lecture.', 'high', 'pending'),
(2, 3, 2, 3, 'Leaking tap in staff room', 'The kitchen tap in the staff room is leaking.', 'medium', 'in_progress');

INSERT IGNORE INTO cleaning_tasks (id, facility_id, assigned_to, scheduled_date, status, notes) VALUES
(1, 1, 3, CURDATE(), 'pending', 'Regular morning cleaning'),
(2, 5, 3, CURDATE(), 'in_progress', 'Deep clean restrooms');
