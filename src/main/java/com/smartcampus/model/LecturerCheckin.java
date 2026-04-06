package com.smartcampus.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Represents a lecturer's daily check-in to their assigned office/facility.
 */
public class LecturerCheckin {

    private int id;
    private int lecturerId;
    private int facilityId;
    private LocalDate checkinDate;
    private LocalDateTime createdAt;

    public LecturerCheckin() {}

    // ─── Getters ─────────────────────────────────────────────

    public int getId() { return id; }
    public int getLecturerId() { return lecturerId; }
    public int getFacilityId() { return facilityId; }
    public LocalDate getCheckinDate() { return checkinDate; }
    public LocalDateTime getCreatedAt() { return createdAt; }

    // ─── Setters ─────────────────────────────────────────────

    public void setId(int id) { this.id = id; }
    public void setLecturerId(int lecturerId) { this.lecturerId = lecturerId; }
    public void setFacilityId(int facilityId) { this.facilityId = facilityId; }
    public void setCheckinDate(LocalDate checkinDate) { this.checkinDate = checkinDate; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    @Override
    public String toString() {
        return "LecturerCheckin{id=" + id + ", lecturerId=" + lecturerId
                + ", facilityId=" + facilityId + ", checkinDate=" + checkinDate + '}';
    }
}
