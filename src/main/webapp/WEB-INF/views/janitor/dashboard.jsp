<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartcampus.model.*,java.util.*" %>
<%
    request.setAttribute("activePage", "dashboard");
    User currentUser = (User) session.getAttribute("loggedInUser");
    String ctx = request.getContextPath();

    @SuppressWarnings("unchecked")
    List<CleaningTask> myTasks = (List<CleaningTask>) request.getAttribute("myTasks");
    if (myTasks == null) myTasks = Collections.emptyList();

    @SuppressWarnings("unchecked")
    List<MaintenanceRequest> assignedRequests = (List<MaintenanceRequest>) request.getAttribute("assignedRequests");
    if (assignedRequests == null) assignedRequests = Collections.emptyList();

    int todayCount = request.getAttribute("todayCount") != null ? (int) request.getAttribute("todayCount") : 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Janitor Dashboard | SmartCampus</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <style>
        :root { --egerton-green:#00A651; --egerton-green-dark:#008a43; --egerton-gold:#D2AC67;
                --sidebar-bg:#1a472a; --sidebar-hover:#2a5a3a; }
        body { background:#F8F9FC; font-family:'Inter',sans-serif; }
        .sidebar { background:linear-gradient(180deg,var(--sidebar-bg) 0%,#007624 100%);
                   min-height:100vh; color:white; position:relative; }
        .nav-link-custom { color:rgba(255,255,255,.85); padding:.7rem 1.2rem; margin:.2rem .8rem;
                           border-radius:12px; transition:all .2s; font-weight:500; font-size:.9rem;
                           display:flex; align-items:center; gap:10px; text-decoration:none; }
        .nav-link-custom:hover { background:var(--sidebar-hover); color:white; }
        .nav-link-custom.active { background:var(--egerton-gold); color:#007624; font-weight:600; }
        .nav-link-custom i { font-size:1.1rem; width:22px; }
        .stat-card { background:#fff; border-radius:16px; padding:1.2rem;
                     box-shadow:0 2px 8px rgba(0,0,0,.04); border:1px solid #e9ecef; }
        .table-container { background:#fff; border-radius:16px; padding:1.5rem;
                           box-shadow:0 2px 8px rgba(0,0,0,.04); border:1px solid #e9ecef; }
        .badge-status-pending     { background:#fff3e0; color:#92400e; }
        .badge-status-in_progress { background:#dbeafe; color:#1e40af; }
        .badge-status-completed   { background:#d1fae5; color:#065f46; }
        .badge-status-skipped     { background:#f3f4f6; color:#374151; }
    </style>
</head>
<body>
<div class="container-fluid">
  <div class="row">
    <jsp:include page="/WEB-INF/views/shared/sidebar.jsp"/>
    <main class="col-md-10 ms-sm-auto col-lg-10 px-4 py-4">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
          <h1 style="font-family:'Playfair Display',serif;font-size:1.8rem;">Janitor Dashboard</h1>
          <p class="text-muted small mb-0">Welcome back, <%= currentUser.getName() %></p>
        </div>
        <a href="<%= ctx %>/logout" class="btn btn-outline-danger btn-sm">
          <i class="bi bi-box-arrow-left"></i> Sign Out
        </a>
      </div>

      <div class="row g-3 mb-4">
        <div class="col-sm-6 col-xl-4">
          <div class="stat-card text-center">
            <div style="font-size:2rem;color:#00A651;"><i class="bi bi-bucket-fill"></i></div>
            <h3 class="fw-bold fs-2 mb-0"><%= todayCount %></h3>
            <p class="text-muted small">Today's Tasks</p>
          </div>
        </div>
        <div class="col-sm-6 col-xl-4">
          <div class="stat-card text-center">
            <div style="font-size:2rem;color:#0d6efd;"><i class="bi bi-list-check"></i></div>
            <h3 class="fw-bold fs-2 mb-0"><%= myTasks.size() %></h3>
            <p class="text-muted small">Total Assigned Tasks</p>
          </div>
        </div>
        <div class="col-sm-6 col-xl-4">
          <div class="stat-card text-center">
            <div style="font-size:2rem;color:#dc3545;"><i class="bi bi-tools"></i></div>
            <h3 class="fw-bold fs-2 mb-0"><%= assignedRequests.size() %></h3>
            <p class="text-muted small">Maintenance Requests</p>
          </div>
        </div>
      </div>

      <!-- Cleaning Tasks -->
      <div class="table-container mb-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
          <h5 class="fw-semibold mb-0">My Cleaning Tasks</h5>
          <a href="<%= ctx %>/cleaning-tasks" class="btn btn-sm btn-outline-success">View All</a>
        </div>
        <% if (myTasks.isEmpty()) { %>
        <p class="text-muted text-center py-3">No cleaning tasks assigned.</p>
        <% } else { %>
        <div class="table-responsive">
          <table class="table table-hover align-middle">
            <thead class="table-light">
              <tr><th>Facility</th><th>Scheduled Date</th><th>Status</th><th>Notes</th><th>Update</th></tr>
            </thead>
            <tbody>
              <% for (CleaningTask t : myTasks) { %>
              <tr>
                <td class="fw-medium"><%= t.getFacilityName() %></td>
                <td class="text-muted small"><%= t.getScheduledDate() %></td>
                <td><span class="badge rounded-pill badge-status-<%= t.getStatus().name() %> text-capitalize"><%= t.getStatus().name().replace("_"," ") %></span></td>
                <td class="text-muted small"><%= t.getNotes() != null ? t.getNotes() : "" %></td>
                <td>
                  <form method="post" action="<%= ctx %>/cleaning-tasks" class="d-flex gap-1">
                    <input type="hidden" name="action" value="updateStatus">
                    <input type="hidden" name="id" value="<%= t.getId() %>">
                    <select name="status" class="form-select form-select-sm" style="width:120px;">
                      <option value="pending"     <%= t.getStatus() == CleaningTask.Status.pending     ? "selected" : "" %>>Pending</option>
                      <option value="in_progress" <%= t.getStatus() == CleaningTask.Status.in_progress ? "selected" : "" %>>In Progress</option>
                      <option value="completed"   <%= t.getStatus() == CleaningTask.Status.completed   ? "selected" : "" %>>Completed</option>
                      <option value="skipped"     <%= t.getStatus() == CleaningTask.Status.skipped     ? "selected" : "" %>>Skipped</option>
                    </select>
                    <button class="btn btn-sm btn-primary">Update</button>
                  </form>
                </td>
              </tr>
              <% } %>
            </tbody>
          </table>
        </div>
        <% } %>
      </div>

      <!-- Assigned Maintenance Requests -->
      <div class="table-container">
        <div class="d-flex justify-content-between align-items-center mb-3">
          <h5 class="fw-semibold mb-0">Assigned Maintenance Requests</h5>
          <a href="<%= ctx %>/maintenance-requests" class="btn btn-sm btn-outline-success">View All</a>
        </div>
        <% if (assignedRequests.isEmpty()) { %>
        <p class="text-muted text-center py-3">No maintenance requests assigned.</p>
        <% } else { %>
        <div class="table-responsive">
          <table class="table table-hover align-middle">
            <thead class="table-light">
              <tr><th>Title</th><th>Facility</th><th>Priority</th><th>Status</th><th>Update</th></tr>
            </thead>
            <tbody>
              <% for (MaintenanceRequest r : assignedRequests) { %>
              <tr>
                <td class="fw-medium"><%= r.getTitle() %></td>
                <td class="text-muted small"><%= r.getFacilityName() %></td>
                <td><span class="badge rounded-pill text-capitalize" style="background:#fee2e2;color:#991b1b;"><%= r.getPriority().name() %></span></td>
                <td><span class="badge rounded-pill text-capitalize" style="background:#dbeafe;color:#1e40af;"><%= r.getStatus().name().replace("_"," ") %></span></td>
                <td>
                  <form method="post" action="<%= ctx %>/maintenance-requests" class="d-flex gap-1">
                    <input type="hidden" name="action" value="updateStatus">
                    <input type="hidden" name="id" value="<%= r.getId() %>">
                    <select name="status" class="form-select form-select-sm" style="width:130px;">
                      <option value="pending"     <%= r.getStatus() == MaintenanceRequest.Status.pending     ? "selected" : "" %>>Pending</option>
                      <option value="in_progress" <%= r.getStatus() == MaintenanceRequest.Status.in_progress ? "selected" : "" %>>In Progress</option>
                      <option value="resolved"    <%= r.getStatus() == MaintenanceRequest.Status.resolved    ? "selected" : "" %>>Resolved</option>
                    </select>
                    <button class="btn btn-sm btn-primary">Update</button>
                  </form>
                </td>
              </tr>
              <% } %>
            </tbody>
          </table>
        </div>
        <% } %>
      </div>
    </main>
  </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
