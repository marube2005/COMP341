package com.smartcampus.dao;

import com.smartcampus.model.JanitorReport;
import com.smartcampus.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data-access object for {@link JanitorReport} entities.
 */
public class JanitorReportDAO {

    private static final String BASE_SELECT =
        "SELECT jr.*, u.name AS lecturer_name "
      + "FROM   janitor_reports jr "
      + "JOIN   users u ON jr.lecturer_id = u.id ";

    /** Returns all reports ordered by most recent first. */
    public List<JanitorReport> findAll() throws SQLException {
        List<JanitorReport> list = new ArrayList<>();
        String sql = BASE_SELECT + "ORDER BY jr.reported_at DESC";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    /** Returns all reports filed by a specific lecturer. */
    public List<JanitorReport> findByLecturer(int lecturerId) throws SQLException {
        List<JanitorReport> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE jr.lecturer_id = ? ORDER BY jr.reported_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, lecturerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    /**
     * Persists a new janitor report.
     *
     * @return the generated primary key
     */
    public int create(JanitorReport report) throws SQLException {
        String sql = "INSERT INTO janitor_reports (lecturer_id, task_name, activity_name, rating, reason, notes) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, report.getLecturerId());
            ps.setString(2, report.getTaskName());
            ps.setString(3, report.getActivityName());
            ps.setInt(4, report.getRating());
            ps.setString(5, report.getReason());
            ps.setString(6, report.getNotes());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        throw new SQLException("Failed to obtain generated key after janitor_report insert");
    }

    /** Returns the total number of reports. */
    public int count() throws SQLException {
        String sql = "SELECT COUNT(*) FROM janitor_reports";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    // ─── Helpers ──────────────────────────────────────────────

    private JanitorReport mapRow(ResultSet rs) throws SQLException {
        JanitorReport r = new JanitorReport();
        r.setId(rs.getInt("id"));
        r.setLecturerId(rs.getInt("lecturer_id"));
        r.setLecturerName(rs.getString("lecturer_name"));
        r.setTaskName(rs.getString("task_name"));
        r.setActivityName(rs.getString("activity_name"));
        r.setRating(rs.getInt("rating"));
        r.setReason(rs.getString("reason"));
        r.setNotes(rs.getString("notes"));
        Timestamp ts = rs.getTimestamp("reported_at");
        if (ts != null) r.setReportedAt(ts.toLocalDateTime());
        return r;
    }
}
