<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartcampus.model.*,java.util.*" %>
<%
    request.setAttribute("activePage", "dashboard");
    User currentUser  = (User) session.getAttribute("loggedInUser");
    int totalUsers    = (int) request.getAttribute("totalUsers");
    int totalFacils   = (int) request.getAttribute("totalFacilities");
    int pendingReqs   = (int) request.getAttribute("pendingRequests");
    int activeFacils  = (int) request.getAttribute("activeFacilities");
    String ctx        = request.getContextPath();
    String errorMsg   = (String) request.getAttribute("error");

    @SuppressWarnings("unchecked")
    List<MaintenanceRequest> allRequests = (List<MaintenanceRequest>) request.getAttribute("allRequests");
    if (allRequests == null) allRequests = Collections.emptyList();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard | SmartCampus</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <style>
        :root { --egerton-green:#00A651; --egerton-green-dark:#008a43; --egerton-gold:#D2AC67;
                --sidebar-bg:#1a472a; --sidebar-hover:#2a5a3a; }
        body { background:#F8F9FC; font-family:'Inter',sans-serif; overflow-x:hidden; }
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
        .stat-card:hover { transform:translateY(-2px); transition:.2s; }
        .stat-icon { width:48px; height:48px; border-radius:14px; display:flex;
                     align-items:center; justify-content:center; font-size:1.6rem; margin-bottom:.8rem; }
        .stat-icon.green { background:rgba(0,166,81,.1); color:var(--egerton-green); }
        .stat-icon.blue  { background:rgba(13,110,253,.1); color:#0d6efd; }
        .stat-icon.gold  { background:rgba(210,172,103,.15); color:#b8860b; }
        .stat-icon.red   { background:rgba(220,53,69,.1); color:#dc3545; }
        .table-container { background:#fff; border-radius:16px; padding:1.5rem;
                           box-shadow:0 2px 8px rgba(0,0,0,.04); border:1px solid #e9ecef; }
        .badge-priority-low    { background:#d1fae5; color:#065f46; }
        .badge-priority-medium { background:#fef9c3; color:#713f12; }
        .badge-priority-high   { background:#fee2e2; color:#991b1b; }
        .badge-priority-urgent { background:#7f1d1d; color:#fff; }
        .badge-status-pending     { background:#fff3e0; color:#92400e; }
        .badge-status-in_progress { background:#dbeafe; color:#1e40af; }
        .badge-status-resolved    { background:#d1fae5; color:#065f46; }
        .badge-status-closed      { background:#f3f4f6; color:#374151; }
    </style>
</head>
<body>
<div class="container-fluid">
  <div class="row">
    <!-- Sidebar -->
    <jsp:include page="/WEB-INF/views/shared/sidebar.jsp"/>

    <!-- Main content -->
    <main class="col-md-10 ms-sm-auto col-lg-10 px-4 py-4">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
          <h1 style="font-family:'Playfair Display',serif;font-size:1.8rem;">Admin Dashboard</h1>
          <p class="text-muted small mb-0">Welcome back, <%= currentUser.getName() %></p>
        </div>
        <a href="<%= ctx %>/logout" class="btn btn-outline-danger btn-sm">
          <i class="bi bi-box-arrow-left"></i> Sign Out
        </a>
      </div>

      <% if (errorMsg != null) { %>
      <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <i class="bi bi-exclamation-triangle-fill me-2"></i><%= errorMsg %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      </div>
      <% } %>

      <!-- Stats row -->
      <div class="row g-3 mb-4">
        <div class="col-sm-6 col-xl-3">
          <div class="stat-card text-center">
            <div class="stat-icon green mx-auto"><i class="bi bi-people-fill"></i></div>
            <h3 class="fw-bold fs-2 mb-0"><%= totalUsers %></h3>
            <p class="text-muted small">Total Users</p>
          </div>
        </div>
        <div class="col-sm-6 col-xl-3">
          <div class="stat-card text-center">
            <div class="stat-icon blue mx-auto"><i class="bi bi-building-fill"></i></div>
            <h3 class="fw-bold fs-2 mb-0"><%= totalFacils %></h3>
            <p class="text-muted small">Total Facilities</p>
          </div>
        </div>
        <div class="col-sm-6 col-xl-3">
          <div class="stat-card text-center">
            <div class="stat-icon gold mx-auto"><i class="bi bi-check-circle-fill"></i></div>
            <h3 class="fw-bold fs-2 mb-0"><%= activeFacils %></h3>
            <p class="text-muted small">Available Facilities</p>
          </div>
        </div>
        <div class="col-sm-6 col-xl-3">
          <div class="stat-card text-center">
            <div class="stat-icon red mx-auto"><i class="bi bi-tools"></i></div>
            <h3 class="fw-bold fs-2 mb-0"><%= pendingReqs %></h3>
            <p class="text-muted small">Pending Requests</p>
          </div>
        </div>
      </div>

      <!-- Quick links -->
      <div class="row g-3 mb-4">
        <div class="col-md-4">
          <a href="<%= ctx %>/admin/users" class="btn btn-success w-100 py-3 rounded-3 fw-semibold">
            <i class="bi bi-person-plus-fill me-2"></i>Manage Users
          </a>
        </div>
        <div class="col-md-4">
          <a href="<%= ctx %>/facilities" class="btn btn-primary w-100 py-3 rounded-3 fw-semibold">
            <i class="bi bi-building me-2"></i>Manage Facilities
          </a>
        </div>
        <div class="col-md-4">
          <a href="<%= ctx %>/maintenance-requests" class="btn btn-warning w-100 py-3 rounded-3 fw-semibold text-dark">
            <i class="bi bi-wrench me-2"></i>Maintenance Requests
          </a>
        </div>
      </div>

      <!-- Recent maintenance requests -->
      <div class="table-container">
        <div class="d-flex justify-content-between align-items-center mb-3">
          <h5 class="fw-semibold mb-0">Recent Maintenance Requests</h5>
          <a href="<%= ctx %>/maintenance-requests" class="btn btn-sm btn-outline-success">View All</a>
        </div>
        <% if (allRequests.isEmpty()) { %>
        <p class="text-muted text-center py-3">No maintenance requests found.</p>
        <% } else { %>
        <div class="table-responsive">
          <table class="table table-hover align-middle">
            <thead class="table-light">
              <tr>
                <th>Title</th>
                <th>Facility</th>
                <th>Reporter</th>
                <th>Priority</th>
                <th>Status</th>
                <th>Date</th>
              </tr>
            </thead>
            <tbody>
              <% int shown = 0;
                 for (MaintenanceRequest mr : allRequests) {
                     if (shown++ >= 10) break; %>
              <tr>
                <td class="fw-medium"><%= mr.getTitle() %></td>
                <td><%= mr.getFacilityName() %></td>
                <td><%= mr.getReportedByName() %></td>
                <td><span class="badge rounded-pill badge-priority-<%= mr.getPriority().name() %> text-capitalize"><%= mr.getPriority().name() %></span></td>
                <td><span class="badge rounded-pill badge-status-<%= mr.getStatus().name() %> text-capitalize"><%= mr.getStatus().name().replace("_"," ") %></span></td>
                <td class="text-muted small"><%= mr.getCreatedAt() != null ? mr.getCreatedAt().toLocalDate() : "" %></td>
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
