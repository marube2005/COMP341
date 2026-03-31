package com.smartcampus.model;

import java.time.LocalDateTime;

/**
 * Represents a maintenance request raised for a facility.
 */
public class MaintenanceRequest {

    public enum Priority { low, medium, high, urgent }
    public enum Status { pending, in_progress, resolved, closed }

    private int id;
    private int facilityId;
    private String facilityName;        // resolved via JOIN for display
    private int reportedBy;
    private String reportedByName;      // resolved via JOIN for display
    private Integer assignedTo;         // nullable
    private String assignedToName;      // resolved via JOIN for display
    private String title;
    private String description;
    private Priority priority;
    private Status status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public MaintenanceRequest() {}

    // ─── Getters ─────────────────────────────────────────────

    public int getId() { return id; }
    public int getFacilityId() { return facilityId; }
    public String getFacilityName() { return facilityName; }
    public int getReportedBy() { return reportedBy; }
    public String getReportedByName() { return reportedByName; }
    public Integer getAssignedTo() { return assignedTo; }
    public String getAssignedToName() { return assignedToName; }
    public String getTitle() { return title; }
    public String getDescription() { return description; }
    public Priority getPriority() { return priority; }
    public Status getStatus() { return status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }

    // ─── Setters ─────────────────────────────────────────────

    public void setId(int id) { this.id = id; }
    public void setFacilityId(int facilityId) { this.facilityId = facilityId; }
    public void setFacilityName(String facilityName) { this.facilityName = facilityName; }
    public void setReportedBy(int reportedBy) { this.reportedBy = reportedBy; }
    public void setReportedByName(String reportedByName) { this.reportedByName = reportedByName; }
    public void setAssignedTo(Integer assignedTo) { this.assignedTo = assignedTo; }
    public void setAssignedToName(String assignedToName) { this.assignedToName = assignedToName; }
    public void setTitle(String title) { this.title = title; }
    public void setDescription(String description) { this.description = description; }
    public void setPriority(Priority priority) { this.priority = priority; }
    public void setStatus(Status status) { this.status = status; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    @Override
    public String toString() {
        return "MaintenanceRequest{id=" + id + ", title='" + title
                + "', priority=" + priority + ", status=" + status + '}';
    }
}
