package com.smartcampus.model;

import java.time.LocalDateTime;

/**
 * Represents a quality report filed by a lecturer about cleaning work done by a janitor.
 * A rating from 1 (poor) to 5 (excellent) is included along with a textual reason
 * and optional notes.
 */
public class JanitorReport {

    private int           id;
    private int           lecturerId;
    private String        lecturerName;
    private String        taskName;
    private String        activityName;
    private int           rating;
    private String        reason;
    private String        notes;
    private LocalDateTime reportedAt;

    public JanitorReport() {}

    // ─── Getters & Setters ────────────────────────────────────

    public int getId()                        { return id; }
    public void setId(int id)                 { this.id = id; }

    public int getLecturerId()                { return lecturerId; }
    public void setLecturerId(int lecturerId) { this.lecturerId = lecturerId; }

    public String getLecturerName()                       { return lecturerName; }
    public void   setLecturerName(String lecturerName)    { this.lecturerName = lecturerName; }

    public String getTaskName()                  { return taskName; }
    public void   setTaskName(String taskName)   { this.taskName = taskName; }

    public String getActivityName()                     { return activityName; }
    public void   setActivityName(String activityName)   { this.activityName = activityName; }

    public int  getRating()              { return rating; }
    public void setRating(int rating)    { this.rating = rating; }

    public String getReason()                { return reason; }
    public void   setReason(String reason)   { this.reason = reason; }

    public String getNotes()               { return notes; }
    public void   setNotes(String notes)   { this.notes = notes; }

    public LocalDateTime getReportedAt()                        { return reportedAt; }
    public void          setReportedAt(LocalDateTime reportedAt) { this.reportedAt = reportedAt; }
}
