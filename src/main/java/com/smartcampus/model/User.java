package com.smartcampus.model;

import java.time.LocalDateTime;

/**
 * Represents a system user (Admin, Lecturer, Janitor, or Supervisor).
 */
public class User {

    public enum Role {
        admin, lecturer, janitor, supervisor
    }

    private int id;
    private String name;
    private String email;
    private String password;        // BCrypt hash – never expose in responses
    private Role role;
    private String phone;
    private String department;
    private boolean active;
    private LocalDateTime createdAt;

    public User() {}

    public User(int id, String name, String email, String password,
                Role role, String phone, String department,
                boolean active, LocalDateTime createdAt) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.password = password;
        this.role = role;
        this.phone = phone;
        this.department = department;
        this.active = active;
        this.createdAt = createdAt;
    }

    // ─── Getters ─────────────────────────────────────────────

    public int getId() { return id; }
    public String getName() { return name; }
    public String getEmail() { return email; }
    public String getPassword() { return password; }
    public Role getRole() { return role; }
    public String getPhone() { return phone; }
    public String getDepartment() { return department; }
    public boolean isActive() { return active; }
    public LocalDateTime getCreatedAt() { return createdAt; }

    // ─── Setters ─────────────────────────────────────────────

    public void setId(int id) { this.id = id; }
    public void setName(String name) { this.name = name; }
    public void setEmail(String email) { this.email = email; }
    public void setPassword(String password) { this.password = password; }
    public void setRole(Role role) { this.role = role; }
    public void setPhone(String phone) { this.phone = phone; }
    public void setDepartment(String department) { this.department = department; }
    public void setActive(boolean active) { this.active = active; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    @Override
    public String toString() {
        return "User{id=" + id + ", name='" + name + "', email='" + email
                + "', role=" + role + '}';
    }
}
