package com.smartcampus.model;

import java.time.LocalDateTime;

/**
 * Represents a physical facility on campus (classroom, lab, office, etc.).
 */
public class Facility {

    public enum FacilityType {
        classroom, lab, office, hall, restroom, other
    }

    public enum Status {
        available, occupied, maintenance, closed
    }

    private int id;
    private String name;
    private String location;
    private FacilityType facilityType;
    private int capacity;
    private Status status;
    private String description;
    private LocalDateTime createdAt;
    private Integer assignedLecturerId;

    public Facility() {}

    public Facility(int id, String name, String location, FacilityType facilityType,
                    int capacity, Status status, String description, LocalDateTime createdAt) {
        this.id = id;
        this.name = name;
        this.location = location;
        this.facilityType = facilityType;
        this.capacity = capacity;
        this.status = status;
        this.description = description;
        this.createdAt = createdAt;
    }

    // ─── Getters ─────────────────────────────────────────────

    public int getId() { return id; }
    public String getName() { return name; }
    public String getLocation() { return location; }
    public FacilityType getFacilityType() { return facilityType; }
    public int getCapacity() { return capacity; }
    public Status getStatus() { return status; }
    public String getDescription() { return description; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public Integer getAssignedLecturerId() { return assignedLecturerId; }

    // ─── Setters ─────────────────────────────────────────────

    public void setId(int id) { this.id = id; }
    public void setName(String name) { this.name = name; }
    public void setLocation(String location) { this.location = location; }
    public void setFacilityType(FacilityType facilityType) { this.facilityType = facilityType; }
    public void setCapacity(int capacity) { this.capacity = capacity; }
    public void setStatus(Status status) { this.status = status; }
    public void setDescription(String description) { this.description = description; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public void setAssignedLecturerId(Integer assignedLecturerId) { this.assignedLecturerId = assignedLecturerId; }

    @Override
    public String toString() {
        return "Facility{id=" + id + ", name='" + name + "', location='" + location
                + "', type=" + facilityType + ", status=" + status + '}';
    }
}
