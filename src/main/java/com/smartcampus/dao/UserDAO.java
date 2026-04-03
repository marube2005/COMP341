package com.smartcampus.dao;

import com.smartcampus.model.User;
import com.smartcampus.util.DBConnection;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Data-access object for {@link User} entities.
 * All password storage uses BCrypt hashing.
 */
public class UserDAO {

    // ─── Authentication ───────────────────────────────────────

    /**
     * Validates credentials and returns the matching {@link User}, or {@code null}
     * when the email is unknown or the password is incorrect.
     */
    public User authenticate(String email, String plainPassword) throws SQLException {
        if (email == null || plainPassword == null) return null;

        String sql = "SELECT * FROM users WHERE email = ? AND active = 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email.trim().toLowerCase());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String storedHash = rs.getString("password");
                    if (BCrypt.checkpw(plainPassword, storedHash)) {
                        return mapRow(rs);
                    }
                }
            }
        }
        return null;
    }

    // ─── CRUD ─────────────────────────────────────────────────

    /** Returns all users ordered by name. */
    public List<User> findAll() throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users ORDER BY name";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                users.add(mapRow(rs));
            }
        }
        return users;
    }

    /** Returns users with a specific role. */
    public List<User> findByRole(User.Role role) throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE role = ? AND active = 1 ORDER BY name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, role.name());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    users.add(mapRow(rs));
                }
            }
        }
        return users;
    }

    /** Finds a user by primary key, or returns {@code null}. */
    public User findById(int id) throws SQLException {
        String sql = "SELECT * FROM users WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    /** Finds a user by email (case-insensitive), or returns {@code null}. */
    public User findByEmail(String email) throws SQLException {
        String sql = "SELECT * FROM users WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email.trim().toLowerCase());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    /**
     * Inserts a new user.  The {@code plainPassword} is hashed before storage.
     *
     * @return the generated primary key
     * @throws IllegalArgumentException if the email is already registered
     */
    public int create(User user, String plainPassword) throws SQLException {
        if (findByEmail(user.getEmail()) != null) {
            throw new IllegalArgumentException("Email already registered: " + user.getEmail());
        }
        String hashed = BCrypt.hashpw(plainPassword, BCrypt.gensalt(12));
        String sql = "INSERT INTO users (name, email, password, role, phone, department, staff_id, active) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail().trim().toLowerCase());
            ps.setString(3, hashed);
            ps.setString(4, user.getRole().name());
            ps.setString(5, user.getPhone());
            ps.setString(6, user.getDepartment());
            ps.setString(7, user.getStaffId());
            ps.setBoolean(8, user.isActive());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        throw new SQLException("Failed to obtain generated key after user insert");
    }

    /** Updates a user's profile details (name, phone, department, role, active). */
    public boolean update(User user) throws SQLException {
        String sql = "UPDATE users SET name=?, phone=?, department=?, role=?, active=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getName());
            ps.setString(2, user.getPhone());
            ps.setString(3, user.getDepartment());
            ps.setString(4, user.getRole().name());
            ps.setBoolean(5, user.isActive());
            ps.setInt(6, user.getId());
            return ps.executeUpdate() > 0;
        }
    }

    /** Updates a user's password using a new plain-text password (will be BCrypt-hashed). */
    public boolean updatePassword(int userId, String newPlainPassword) throws SQLException {
        String hashed = BCrypt.hashpw(newPlainPassword, BCrypt.gensalt(12));
        String sql = "UPDATE users SET password=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, hashed);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    /** Soft-deletes (deactivates) a user. */
    public boolean deactivate(int userId) throws SQLException {
        String sql = "UPDATE users SET active=0 WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        }
    }

    /** Returns the total number of users. */
    public int count() throws SQLException {
        String sql = "SELECT COUNT(*) FROM users";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    // ─── Helpers ──────────────────────────────────────────────

    private User mapRow(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setName(rs.getString("name"));
        u.setEmail(rs.getString("email"));
        u.setPassword(rs.getString("password"));
        u.setRole(User.Role.valueOf(rs.getString("role")));
        u.setPhone(rs.getString("phone"));
        u.setDepartment(rs.getString("department"));
        u.setStaffId(rs.getString("staff_id"));
        u.setActive(rs.getBoolean("active"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) u.setCreatedAt(ts.toLocalDateTime());
        return u;
    }
}
