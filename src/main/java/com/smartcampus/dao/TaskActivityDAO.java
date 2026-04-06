package com.smartcampus.dao;

import com.smartcampus.model.CleaningTask;
import com.smartcampus.model.Facility;
import com.smartcampus.model.TaskActivity;
import com.smartcampus.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data-access object for {@link TaskActivity} entities.
 * Handles auto-generation of activities per task based on lecturer check-in status.
 */
public class TaskActivityDAO {

    private final LecturerCheckinDAO checkinDAO = new LecturerCheckinDAO();
    private final FacilityDAO        facilityDAO = new FacilityDAO();

    /**
     * Returns all activities for the given task, generating them first if none exist yet.
     *
     * <p>Generation rules (applied to the task's scheduled date):
     * <ul>
     *   <li>If the facility has an assigned lecturer who checked in on the scheduled date
     *       → generate the full activity list (all 7 activities).</li>
     *   <li>Otherwise → generate only "Dust surfaces".</li>
     * </ul>
     */
    public List<TaskActivity> findOrGenerateForTask(CleaningTask task) throws SQLException {
        List<TaskActivity> existing = findByTask(task.getId());
        if (!existing.isEmpty()) return existing;

        // No activities yet – determine the appropriate activity set
        boolean fullClean = false;
        try {
            Facility facility = facilityDAO.findById(task.getFacilityId());
            if (facility != null && facility.getAssignedLecturerId() != null) {
                fullClean = checkinDAO.hasCheckedIn(
                        facility.getAssignedLecturerId(),
                        facility.getId(),
                        task.getScheduledDate());
            }
        } catch (SQLException e) {
            // Fall back to dust-only on error
        }

        String[] names = fullClean ? TaskActivity.ALL_ACTIVITIES : TaskActivity.DUST_ONLY;
        return createActivities(task.getId(), names);
    }

    /** Returns all activities for the given task ID. */
    public List<TaskActivity> findByTask(int taskId) throws SQLException {
        List<TaskActivity> list = new ArrayList<>();
        String sql = "SELECT * FROM task_activities WHERE task_id=? ORDER BY id";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    /**
     * Marks a single activity as done or undone.
     *
     * @return {@code true} if a row was updated
     */
    public boolean setDone(int activityId, boolean done) throws SQLException {
        String sql = "UPDATE task_activities SET is_done=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, done);
            ps.setInt(2, activityId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Inserts a batch of activity records for a task and returns them.
     */
    private List<TaskActivity> createActivities(int taskId, String[] names) throws SQLException {
        List<TaskActivity> created = new ArrayList<>();
        String sql = "INSERT INTO task_activities (task_id, activity) VALUES (?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            for (String name : names) {
                ps.setInt(1, taskId);
                ps.setString(2, name);
                ps.addBatch();
            }
            ps.executeBatch();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                int i = 0;
                while (keys.next()) {
                    TaskActivity ta = new TaskActivity();
                    ta.setId(keys.getInt(1));
                    ta.setTaskId(taskId);
                    ta.setActivity(names[i++]);
                    ta.setDone(false);
                    created.add(ta);
                }
            }
        }
        // If generated keys weren't returned fully, fall back to a fresh query
        if (created.size() != names.length) {
            return findByTask(taskId);
        }
        return created;
    }

    // ─── Helpers ──────────────────────────────────────────────

    private TaskActivity mapRow(ResultSet rs) throws SQLException {
        TaskActivity ta = new TaskActivity();
        ta.setId(rs.getInt("id"));
        ta.setTaskId(rs.getInt("task_id"));
        ta.setActivity(rs.getString("activity"));
        ta.setDone(rs.getBoolean("is_done"));
        Timestamp ts = rs.getTimestamp("updated_at");
        if (ts != null) ta.setUpdatedAt(ts.toLocalDateTime());
        return ta;
    }
}
