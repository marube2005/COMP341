package com.smartcampus.dao;

import com.smartcampus.model.LecturerCheckin;
import com.smartcampus.util.DBConnection;

import java.sql.*;
import java.time.LocalDate;

/**
 * Data-access object for {@link LecturerCheckin} entities.
 */
public class LecturerCheckinDAO {

    /**
     * Records a check-in for the given lecturer and facility on today's date.
     * Silently ignores duplicate check-ins (unique constraint on lecturer+facility+date).
     *
     * @return the generated primary key, or -1 if already checked in today
     */
    public int checkIn(int lecturerId, int facilityId) throws SQLException {
        String sql = "INSERT IGNORE INTO lecturer_checkins (lecturer_id, facility_id, checkin_date) "
                   + "VALUES (?, ?, CURDATE())";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, lecturerId);
            ps.setInt(2, facilityId);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        return -1;
    }

    /**
     * Returns {@code true} if the lecturer has checked in to the given facility on the
     * given date.
     */
    public boolean hasCheckedIn(int lecturerId, int facilityId, LocalDate date) throws SQLException {
        String sql = "SELECT 1 FROM lecturer_checkins "
                   + "WHERE lecturer_id=? AND facility_id=? AND checkin_date=? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, lecturerId);
            ps.setInt(2, facilityId);
            ps.setDate(3, Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * Returns {@code true} if any lecturer has checked in to the given facility on the
     * given date (used when determining activity scope without knowing the lecturer ID).
     */
    public boolean anyCheckedInToFacility(int facilityId, LocalDate date) throws SQLException {
        String sql = "SELECT 1 FROM lecturer_checkins WHERE facility_id=? AND checkin_date=? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, facilityId);
            ps.setDate(2, Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }
}
