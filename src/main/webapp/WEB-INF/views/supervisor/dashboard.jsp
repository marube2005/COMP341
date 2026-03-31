<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartcampus.model.*,java.util.*" %>
<%
    request.setAttribute("activePage", "dashboard");
    User currentUser = (User) session.getAttribute("loggedInUser");
    String ctx = request.getContextPath();

    @SuppressWarnings("unchecked")
    List<MaintenanceRequest> allRequests = (List<MaintenanceRequest>) request.getAttribute("allRequests");
    if (allRequests == null) allRequests = Collections.emptyList();

    @SuppressWarnings("unchecked")
    List<User> janitors = (List<User>) request.getAttribute("janitors");
    if (janitors == null) janitors = Collections.emptyList();

    int pendingCount    = request.getAttribute("pendingCount")    != null ? (int) request.getAttribute("pendingCount")    : 0;
    int inProgressCount = request.getAttribute("inProgressCount") != null ? (int) request.getAttribute("inProgressCount") : 0;
    int resolvedCount   = request.getAttribute("resolvedCount")   != null ? (int) request.getAttribute("resolvedCount")   : 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Supervisor Dashboard | SmartCampus</title>
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
    <jsp:include page="/WEB-INF/views/shared/sidebar.jsp"/>
    <main class="col-md-10 ms-sm-auto col-lg-10 px-4 py-4">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
          <h1 style="font-family:'Playfair Display',serif;font-size:1.8rem;">Supervisor Dashboard</h1>
          <p class="text-muted small mb-0">Welcome back, <%= currentUser.getName() %></p>
        </div>
        <a href="<%= ctx %>/logout" class="btn btn-outline-danger btn-sm">
          <i class="bi bi-box-arrow-left"></i> Sign Out
        </a>
      </div>

      <div class="row g-3 mb-4">
        <div class="col-sm-6 col-xl-4">
          <div class="stat-card text-center">
            <div style="font-size:2rem;color:#f59e0b;"><i class="bi bi-hourglass-split"></i></div>
            <h3 class="fw-bold fs-2 mb-0"><%= pendingCount %></h3>
            <p class="text-muted small">Pending Requests</p>
          </div>
        </div>
        <div class="col-sm-6 col-xl-4">
          <div class="stat-card text-center">
            <div style="font-size:2rem;color:#3b82f6;"><i class="bi bi-arrow-repeat"></i></div>
            <h3 class="fw-bold fs-2 mb-0"><%= inProgressCount %></h3>
            <p class="text-muted small">In Progress</p>
          </div>
        </div>
        <div class="col-sm-6 col-xl-4">
          <div class="stat-card text-center">
            <div style="font-size:2rem;color:#00A651;"><i class="bi bi-check2-circle"></i></div>
            <h3 class="fw-bold fs-2 mb-0"><%= resolvedCount %></h3>
            <p class="text-muted small">Resolved</p>
          </div>
        </div>
      </div>

      <div class="table-container">
        <div class="d-flex justify-content-between align-items-center mb-3">
          <h5 class="fw-semibold mb-0">All Maintenance Requests</h5>
          <a href="<%= ctx %>/maintenance-requests" class="btn btn-sm btn-outline-success">View All</a>
        </div>
        <% if (allRequests.isEmpty()) { %>
        <p class="text-muted text-center py-3">No maintenance requests found.</p>
        <% } else { %>
        <div class="table-responsive">
          <table class="table table-hover align-middle">
            <thead class="table-light">
              <tr>
                <th>Title</th><th>Facility</th><th>Reporter</th>
                <th>Priority</th><th>Status</th><th>Assigned To</th><th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <% int shown = 0;
                 for (MaintenanceRequest r : allRequests) {
                     if (shown++ >= 15) break; %>
              <tr>
                <td class="fw-medium"><%= r.getTitle() %></td>
                <td class="text-muted small"><%= r.getFacilityName() %></td>
                <td class="text-muted small"><%= r.getReportedByName() %></td>
                <td><span class="badge rounded-pill badge-priority-<%= r.getPriority().name() %> text-capitalize"><%= r.getPriority().name() %></span></td>
                <td><span class="badge rounded-pill badge-status-<%= r.getStatus().name() %> text-capitalize"><%= r.getStatus().name().replace("_"," ") %></span></td>
                <td class="text-muted small"><%= r.getAssignedToName() != null ? r.getAssignedToName() : "Unassigned" %></td>
                <td>
                  <!-- Assign dropdown -->
                  <% if (r.getStatus() == MaintenanceRequest.Status.pending && !janitors.isEmpty()) { %>
                  <form method="post" action="<%= ctx %>/maintenance-requests" class="d-flex gap-1">
                    <input type="hidden" name="action" value="assign">
                    <input type="hidden" name="id" value="<%= r.getId() %>">
                    <select name="assigneeId" class="form-select form-select-sm" style="width:130px;">
                      <% for (User j : janitors) { %>
                      <option value="<%= j.getId() %>"><%= j.getName() %></option>
                      <% } %>
                    </select>
                    <button class="btn btn-sm btn-primary">Assign</button>
                  </form>
                  <% } else { %>
                  <span class="text-muted small">—</span>
                  <% } %>
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
