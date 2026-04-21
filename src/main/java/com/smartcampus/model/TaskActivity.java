package com.smartcampus.model;

import java.time.LocalDateTime;

/**
 * Represents one checklist activity for a {@link CleaningTask}.
 * Activities are auto-generated when the janitor first views the task:
 * - If the lecturer of the assigned office checked in that day → all 4 cleaning activities are listed.
 * - Otherwise → only "Dust surfaces" is listed.
 */
public class TaskActivity {

    /** Full set of activities performed when the lecturer has checked in. */
    public static final String[] ALL_ACTIVITIES = {
        "Sweep floor",
        "Mop floor",
        "Dust surfaces",
        "Empty trash"
    };

    /** Minimal activity performed when the lecturer has NOT checked in. */
    public static final String[] DUST_ONLY = { "Dust surfaces" };

    private int id;
    private int taskId;
    private String activity;
    private boolean done;
    private LocalDateTime updatedAt;

    public TaskActivity() {}

    // ─── Getters ─────────────────────────────────────────────

    public int getId() { return id; }
    public int getTaskId() { return taskId; }
    public String getActivity() { return activity; }
    public boolean isDone() { return done; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }

    // ─── Setters ─────────────────────────────────────────────

    public void setId(int id) { this.id = id; }
    public void setTaskId(int taskId) { this.taskId = taskId; }
    public void setActivity(String activity) { this.activity = activity; }
    public void setDone(boolean done) { this.done = done; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    @Override
    public String toString() {
        return "TaskActivity{id=" + id + ", taskId=" + taskId
                + ", activity='" + activity + "', done=" + done + '}';
    }
}
