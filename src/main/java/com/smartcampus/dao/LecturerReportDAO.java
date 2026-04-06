package com.smartcampus.dao;

import com.smartcampus.model.LecturerReport;
import com.smartcampus.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data-access object for {@link LecturerReport} entities.
 */
public class LecturerReportDAO {

    private static final String BASE_SELECT =
        "SELECT lr.*, "
      + "       f.name  AS facility_name, "
      + "       u.name  AS lecturer_name "
      + "FROM   lecturer_reports lr "
      + "JOIN   cleaning_tasks ct ON lr.task_id     = ct.id "
      + "JOIN   facilities      f  ON ct.facility_id = f.id "
      + "JOIN   users           u  ON lr.lecturer_id  = u.id ";

    /** Returns all lecturer reports ordered by most recent first. */
    public List<LecturerReport> findAll() throws SQLException {
        List<LecturerReport> list = new ArrayList<>();
        String sql = BASE_SELECT + "ORDER BY lr.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    /** Returns all reports submitted by the given lecturer. */
    public List<LecturerReport> findByLecturer(int lecturerId) throws SQLException {
        List<LecturerReport> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE lr.lecturer_id = ? ORDER BY lr.created_at DESC";
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
     * Returns {@code true} if the lecturer has already submitted a report
     * for the given cleaning task.
     */
    public boolean existsForTask(int taskId, int lecturerId) throws SQLException {
        String sql = "SELECT 1 FROM lecturer_reports WHERE task_id = ? AND lecturer_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            ps.setInt(2, lecturerId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * Saves a new lecturer report and returns the generated primary key.
     */
    public int create(LecturerReport report) throws SQLException {
        String sql = "INSERT INTO lecturer_reports (task_id, lecturer_id, rating, report_text) "
                   + "VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, report.getTaskId());
            ps.setInt(2, report.getLecturerId());
            ps.setInt(3, report.getRating());
            ps.setString(4, report.getReportText());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        throw new SQLException("Failed to obtain generated key after lecturer_report insert");
    }

    // ─── Helpers ──────────────────────────────────────────────

    private LecturerReport mapRow(ResultSet rs) throws SQLException {
        LecturerReport r = new LecturerReport();
        r.setId(rs.getInt("id"));
        r.setTaskId(rs.getInt("task_id"));
        r.setTaskFacilityName(rs.getString("facility_name"));
        r.setLecturerId(rs.getInt("lecturer_id"));
        r.setLecturerName(rs.getString("lecturer_name"));
        r.setRating(rs.getInt("rating"));
        r.setReportText(rs.getString("report_text"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) r.setCreatedAt(ts.toLocalDateTime());
        return r;
    }
}
