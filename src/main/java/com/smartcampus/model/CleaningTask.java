package com.smartcampus.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Represents a cleaning task assigned to a janitor for a specific facility.
 */
public class CleaningTask {

    public enum Status { pending, in_progress, completed, skipped }

    private int id;
    private int facilityId;
    private String facilityName;        // resolved via JOIN for display
    private int assignedTo;             // janitor user id
    private String assignedToName;      // resolved via JOIN for display
    private LocalDate scheduledDate;
    private Status status;
    private String notes;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public CleaningTask() {}

    // ─── Getters ─────────────────────────────────────────────

    public int getId() { return id; }
    public int getFacilityId() { return facilityId; }
    public String getFacilityName() { return facilityName; }
    public int getAssignedTo() { return assignedTo; }
    public String getAssignedToName() { return assignedToName; }
    public LocalDate getScheduledDate() { return scheduledDate; }
    public Status getStatus() { return status; }
    public String getNotes() { return notes; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }

    // ─── Setters ─────────────────────────────────────────────

    public void setId(int id) { this.id = id; }
    public void setFacilityId(int facilityId) { this.facilityId = facilityId; }
    public void setFacilityName(String facilityName) { this.facilityName = facilityName; }
    public void setAssignedTo(int assignedTo) { this.assignedTo = assignedTo; }
    public void setAssignedToName(String assignedToName) { this.assignedToName = assignedToName; }
    public void setScheduledDate(LocalDate scheduledDate) { this.scheduledDate = scheduledDate; }
    public void setStatus(Status status) { this.status = status; }
    public void setNotes(String notes) { this.notes = notes; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    @Override
    public String toString() {
        return "CleaningTask{id=" + id + ", facilityId=" + facilityId
                + ", scheduledDate=" + scheduledDate + ", status=" + status + '}';
    }
}
