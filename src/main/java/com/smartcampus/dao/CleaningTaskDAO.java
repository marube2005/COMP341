package com.smartcampus.dao;

import com.smartcampus.model.CleaningTask;
import com.smartcampus.util.DBConnection;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Data-access object for {@link CleaningTask} entities.
 */
public class CleaningTaskDAO {

    private static final String BASE_SELECT =
        "SELECT ct.*, f.name AS facility_name, u.name AS janitor_name "
      + "FROM   cleaning_tasks ct "
      + "JOIN   facilities f ON ct.facility_id = f.id "
      + "JOIN   users u      ON ct.assigned_to  = u.id ";

    /** Returns all cleaning tasks ordered by scheduled_date descending. */
    public List<CleaningTask> findAll() throws SQLException {
        List<CleaningTask> list = new ArrayList<>();
        String sql = BASE_SELECT + "ORDER BY ct.scheduled_date DESC";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    /** Returns cleaning tasks assigned to a specific janitor. */
    public List<CleaningTask> findByJanitor(int janitorId) throws SQLException {
        List<CleaningTask> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE ct.assigned_to = ? ORDER BY ct.scheduled_date DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, janitorId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    /** Returns tasks scheduled on a specific date. */
    public List<CleaningTask> findByDate(LocalDate date) throws SQLException {
        List<CleaningTask> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE ct.scheduled_date = ? ORDER BY ct.id";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    /** Finds a cleaning task by primary key, or returns {@code null}. */
    public CleaningTask findById(int id) throws SQLException {
        String sql = BASE_SELECT + "WHERE ct.id = ?";
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
     * Creates a new cleaning task.
     *
     * @return the generated primary key
     */
    public int create(CleaningTask task) throws SQLException {
        String sql = "INSERT INTO cleaning_tasks (facility_id, assigned_to, scheduled_date, status, notes) "
                   + "VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, task.getFacilityId());
            ps.setInt(2, task.getAssignedTo());
            ps.setDate(3, Date.valueOf(task.getScheduledDate()));
            ps.setString(4, task.getStatus().name());
            ps.setString(5, task.getNotes());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        throw new SQLException("Failed to obtain generated key after cleaning_task insert");
    }

    /** Updates all mutable fields of a cleaning task. */
    public boolean update(CleaningTask task) throws SQLException {
        String sql = "UPDATE cleaning_tasks SET facility_id=?, assigned_to=?, scheduled_date=?, "
                   + "status=?, notes=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, task.getFacilityId());
            ps.setInt(2, task.getAssignedTo());
            ps.setDate(3, Date.valueOf(task.getScheduledDate()));
            ps.setString(4, task.getStatus().name());
            ps.setString(5, task.getNotes());
            ps.setInt(6, task.getId());
            return ps.executeUpdate() > 0;
        }
    }

    /** Updates only the status of a cleaning task. */
    public boolean updateStatus(int id, CleaningTask.Status status) throws SQLException {
        String sql = "UPDATE cleaning_tasks SET status=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status.name());
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        }
    }

    /** Deletes a cleaning task by primary key. */
    public boolean delete(int id) throws SQLException {
        String sql = "DELETE FROM cleaning_tasks WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    /** Returns the total number of cleaning tasks. */
    public int count() throws SQLException {
        String sql = "SELECT COUNT(*) FROM cleaning_tasks";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    /** Returns the count of cleaning tasks with the given status. */
    public int countByStatus(CleaningTask.Status status) throws SQLException {
        String sql = "SELECT COUNT(*) FROM cleaning_tasks WHERE status=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status.name());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    /** Returns the count of cleaning tasks completed today (all janitors). */
    public int countCompletedToday() throws SQLException {
        String sql = "SELECT COUNT(*) FROM cleaning_tasks WHERE status=? AND scheduled_date=CURDATE()";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, CleaningTask.Status.completed.name());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    /** Returns the count for today's tasks assigned to a specific janitor. */
    public int countTodayByJanitor(int janitorId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM cleaning_tasks WHERE assigned_to=? AND scheduled_date=CURDATE()";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, janitorId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    // ─── Helpers ──────────────────────────────────────────────

    private CleaningTask mapRow(ResultSet rs) throws SQLException {
        CleaningTask t = new CleaningTask();
        t.setId(rs.getInt("id"));
        t.setFacilityId(rs.getInt("facility_id"));
        t.setFacilityName(rs.getString("facility_name"));
        t.setAssignedTo(rs.getInt("assigned_to"));
        t.setAssignedToName(rs.getString("janitor_name"));
        Date d = rs.getDate("scheduled_date");
        if (d != null) t.setScheduledDate(d.toLocalDate());
        t.setStatus(CleaningTask.Status.valueOf(rs.getString("status")));
        t.setNotes(rs.getString("notes"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) t.setCreatedAt(ts.toLocalDateTime());
        ts = rs.getTimestamp("updated_at");
        if (ts != null) t.setUpdatedAt(ts.toLocalDateTime());
        return t;
    }
}
