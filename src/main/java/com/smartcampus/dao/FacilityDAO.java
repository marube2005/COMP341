package com.smartcampus.dao;

import com.smartcampus.model.Facility;
import com.smartcampus.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data-access object for {@link Facility} entities.
 */
public class FacilityDAO {

    /** Returns all facilities ordered by name. */
    public List<Facility> findAll() throws SQLException {
        List<Facility> list = new ArrayList<>();
        String sql = "SELECT * FROM facilities ORDER BY name";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    /** Returns all facilities with a specific status. */
    public List<Facility> findByStatus(Facility.Status status) throws SQLException {
        List<Facility> list = new ArrayList<>();
        String sql = "SELECT * FROM facilities WHERE status = ? ORDER BY name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status.name());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    /** Finds a facility by primary key, or returns {@code null}. */
    public Facility findById(int id) throws SQLException {
        String sql = "SELECT * FROM facilities WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    /**
     * Inserts a new facility.
     *
     * @return the generated primary key
     */
    public int create(Facility facility) throws SQLException {
        String sql = "INSERT INTO facilities (name, location, facility_type, capacity, status, description) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, facility.getName());
            ps.setString(2, facility.getLocation());
            ps.setString(3, facility.getFacilityType().name());
            ps.setInt(4, facility.getCapacity());
            ps.setString(5, facility.getStatus().name());
            ps.setString(6, facility.getDescription());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        throw new SQLException("Failed to obtain generated key after facility insert");
    }

    /** Updates an existing facility record. */
    public boolean update(Facility facility) throws SQLException {
        String sql = "UPDATE facilities SET name=?, location=?, facility_type=?, capacity=?, "
                   + "status=?, description=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, facility.getName());
            ps.setString(2, facility.getLocation());
            ps.setString(3, facility.getFacilityType().name());
            ps.setInt(4, facility.getCapacity());
            ps.setString(5, facility.getStatus().name());
            ps.setString(6, facility.getDescription());
            ps.setInt(7, facility.getId());
            return ps.executeUpdate() > 0;
        }
    }

    /** Deletes a facility by primary key. */
    public boolean delete(int id) throws SQLException {
        String sql = "DELETE FROM facilities WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    /** Returns the total number of facilities. */
    public int count() throws SQLException {
        String sql = "SELECT COUNT(*) FROM facilities";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    /** Returns the facility assigned to the given lecturer, or {@code null} if none. */
    public Facility findByLecturerId(int lecturerId) throws SQLException {
        String sql = "SELECT * FROM facilities WHERE assigned_lecturer_id = ? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, lecturerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    /** Returns the count of facilities with a specific status. */
    public int countByStatus(Facility.Status status) throws SQLException {
        String sql = "SELECT COUNT(*) FROM facilities WHERE status = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status.name());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    // ─── Helpers ──────────────────────────────────────────────

    private Facility mapRow(ResultSet rs) throws SQLException {
        Facility f = new Facility();
        f.setId(rs.getInt("id"));
        f.setName(rs.getString("name"));
        f.setLocation(rs.getString("location"));
        f.setFacilityType(Facility.FacilityType.valueOf(rs.getString("facility_type")));
        f.setCapacity(rs.getInt("capacity"));
        f.setStatus(Facility.Status.valueOf(rs.getString("status")));
        f.setDescription(rs.getString("description"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) f.setCreatedAt(ts.toLocalDateTime());
        int lecId = rs.getInt("assigned_lecturer_id");
        if (!rs.wasNull()) f.setAssignedLecturerId(lecId);
        return f;
    }
}
