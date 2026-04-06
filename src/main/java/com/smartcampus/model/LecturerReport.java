package com.smartcampus.model;

import java.time.LocalDateTime;

/**
 * Represents a rating and report submitted by a lecturer after a
 * janitor has completed a cleaning task.
 */
public class LecturerReport {

    private int id;
    private int taskId;
    private String taskFacilityName;    // resolved via JOIN for display
    private int lecturerId;
    private String lecturerName;        // resolved via JOIN for display
    private int rating;                 // 1 (poor) to 5 (excellent)
    private String reportText;
    private LocalDateTime createdAt;

    public LecturerReport() {}

    // ─── Getters ─────────────────────────────────────────────

    public int getId() { return id; }
    public int getTaskId() { return taskId; }
    public String getTaskFacilityName() { return taskFacilityName; }
    public int getLecturerId() { return lecturerId; }
    public String getLecturerName() { return lecturerName; }
    public int getRating() { return rating; }
    public String getReportText() { return reportText; }
    public LocalDateTime getCreatedAt() { return createdAt; }

    // ─── Setters ─────────────────────────────────────────────

    public void setId(int id) { this.id = id; }
    public void setTaskId(int taskId) { this.taskId = taskId; }
    public void setTaskFacilityName(String taskFacilityName) { this.taskFacilityName = taskFacilityName; }
    public void setLecturerId(int lecturerId) { this.lecturerId = lecturerId; }
    public void setLecturerName(String lecturerName) { this.lecturerName = lecturerName; }
    public void setRating(int rating) { this.rating = rating; }
    public void setReportText(String reportText) { this.reportText = reportText; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    @Override
    public String toString() {
        return "LecturerReport{id=" + id + ", taskId=" + taskId
                + ", lecturerId=" + lecturerId + ", rating=" + rating + '}';
    }
}
