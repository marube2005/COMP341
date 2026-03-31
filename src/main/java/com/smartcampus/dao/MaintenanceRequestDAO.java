package com.smartcampus.dao;

import com.smartcampus.model.MaintenanceRequest;
import com.smartcampus.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data-access object for {@link MaintenanceRequest} entities.
 */
public class MaintenanceRequestDAO {

    private static final String BASE_SELECT =
        "SELECT mr.*, f.name AS facility_name, "
      + "       r.name AS reporter_name, "
      + "       a.name AS assignee_name "
      + "FROM   maintenance_requests mr "
      + "JOIN   facilities f ON mr.facility_id = f.id "
      + "JOIN   users r      ON mr.reported_by  = r.id "
      + "LEFT JOIN users a   ON mr.assigned_to   = a.id ";

    /** Returns all maintenance requests ordered by created_at descending. */
    public List<MaintenanceRequest> findAll() throws SQLException {
        List<MaintenanceRequest> list = new ArrayList<>();
        String sql = BASE_SELECT + "ORDER BY mr.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    /** Returns maintenance requests reported by a specific user. */
    public List<MaintenanceRequest> findByReporter(int userId) throws SQLException {
        List<MaintenanceRequest> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE mr.reported_by = ? ORDER BY mr.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    /** Returns maintenance requests assigned to a specific user. */
    public List<MaintenanceRequest> findByAssignee(int userId) throws SQLException {
        List<MaintenanceRequest> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE mr.assigned_to = ? ORDER BY mr.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    /** Returns maintenance requests with a specific status. */
    public List<MaintenanceRequest> findByStatus(MaintenanceRequest.Status status) throws SQLException {
        List<MaintenanceRequest> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE mr.status = ? ORDER BY mr.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status.name());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    /** Finds a maintenance request by primary key, or returns {@code null}. */
    public MaintenanceRequest findById(int id) throws SQLException {
        String sql = BASE_SELECT + "WHERE mr.id = ?";
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
     * Creates a new maintenance request.
     *
     * @return the generated primary key
     */
    public int create(MaintenanceRequest mr) throws SQLException {
        String sql = "INSERT INTO maintenance_requests "
                   + "(facility_id, reported_by, assigned_to, title, description, priority, status) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, mr.getFacilityId());
            ps.setInt(2, mr.getReportedBy());
            if (mr.getAssignedTo() != null) {
                ps.setInt(3, mr.getAssignedTo());
            } else {
                ps.setNull(3, Types.INTEGER);
            }
            ps.setString(4, mr.getTitle());
            ps.setString(5, mr.getDescription());
            ps.setString(6, mr.getPriority().name());
            ps.setString(7, mr.getStatus().name());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        throw new SQLException("Failed to obtain generated key after maintenance_request insert");
    }

    /** Updates an existing maintenance request (all fields). */
    public boolean update(MaintenanceRequest mr) throws SQLException {
        String sql = "UPDATE maintenance_requests SET facility_id=?, assigned_to=?, title=?, "
                   + "description=?, priority=?, status=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, mr.getFacilityId());
            if (mr.getAssignedTo() != null) {
                ps.setInt(2, mr.getAssignedTo());
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            ps.setString(3, mr.getTitle());
            ps.setString(4, mr.getDescription());
            ps.setString(5, mr.getPriority().name());
            ps.setString(6, mr.getStatus().name());
            ps.setInt(7, mr.getId());
            return ps.executeUpdate() > 0;
        }
    }

    /** Updates only the status of a maintenance request. */
    public boolean updateStatus(int id, MaintenanceRequest.Status status) throws SQLException {
        String sql = "UPDATE maintenance_requests SET status=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status.name());
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        }
    }

    /** Assigns a maintenance request to a user. */
    public boolean assign(int requestId, int assigneeId) throws SQLException {
        String sql = "UPDATE maintenance_requests SET assigned_to=?, status='in_progress' WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, assigneeId);
            ps.setInt(2, requestId);
            return ps.executeUpdate() > 0;
        }
    }

    /** Deletes a maintenance request by primary key. */
    public boolean delete(int id) throws SQLException {
        String sql = "DELETE FROM maintenance_requests WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    /** Returns the total number of maintenance requests. */
    public int count() throws SQLException {
        String sql = "SELECT COUNT(*) FROM maintenance_requests";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    /** Returns the count for a specific status. */
    public int countByStatus(MaintenanceRequest.Status status) throws SQLException {
        String sql = "SELECT COUNT(*) FROM maintenance_requests WHERE status=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status.name());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    // ─── Helpers ──────────────────────────────────────────────

    private MaintenanceRequest mapRow(ResultSet rs) throws SQLException {
        MaintenanceRequest mr = new MaintenanceRequest();
        mr.setId(rs.getInt("id"));
        mr.setFacilityId(rs.getInt("facility_id"));
        mr.setFacilityName(rs.getString("facility_name"));
        mr.setReportedBy(rs.getInt("reported_by"));
        mr.setReportedByName(rs.getString("reporter_name"));
        int assignedTo = rs.getInt("assigned_to");
        mr.setAssignedTo(rs.wasNull() ? null : assignedTo);
        mr.setAssignedToName(rs.getString("assignee_name"));
        mr.setTitle(rs.getString("title"));
        mr.setDescription(rs.getString("description"));
        mr.setPriority(MaintenanceRequest.Priority.valueOf(rs.getString("priority")));
        mr.setStatus(MaintenanceRequest.Status.valueOf(rs.getString("status")));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) mr.setCreatedAt(ts.toLocalDateTime());
        ts = rs.getTimestamp("updated_at");
        if (ts != null) mr.setUpdatedAt(ts.toLocalDateTime());
        return mr;
    }
}
