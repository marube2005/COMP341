<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartcampus.model.*,java.util.*" %>
<%
    request.setAttribute("activePage", "requests");
    String ctx = request.getContextPath();
    String success  = request.getParameter("success");
    String errorMsg = (String) request.getAttribute("error");

    User currentUser = (User) session.getAttribute("loggedInUser");

    @SuppressWarnings("unchecked")
    List<MaintenanceRequest> requests = (List<MaintenanceRequest>) request.getAttribute("requests");
    if (requests == null) requests = Collections.emptyList();

    @SuppressWarnings("unchecked")
    List<Facility> facilities = (List<Facility>) request.getAttribute("facilities");
    if (facilities == null) facilities = Collections.emptyList();

    @SuppressWarnings("unchecked")
    List<User> janitors = (List<User>) request.getAttribute("janitors");
    if (janitors == null) janitors = Collections.emptyList();

    boolean canCreate = currentUser != null &&
        (currentUser.getRole() == User.Role.lecturer || currentUser.getRole() == User.Role.admin);
    boolean canAssign = currentUser != null &&
        (currentUser.getRole() == User.Role.admin || currentUser.getRole() == User.Role.supervisor);
    boolean canDelete = currentUser != null && currentUser.getRole() == User.Role.admin;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Maintenance Requests | SmartCampus</title>
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
          <h1 style="font-family:'Playfair Display',serif;font-size:1.8rem;">Maintenance Requests</h1>
          <p class="text-muted small mb-0">Track and manage facility maintenance</p>
        </div>
        <% if (canCreate) { %>
        <button class="btn btn-success" data-bs-toggle="modal" data-bs-target="#newRequestModal">
          <i class="bi bi-plus-circle-fill me-1"></i> New Request
        </button>
        <% } %>
      </div>

      <% if (success != null) { %>
      <div class="alert alert-success alert-dismissible fade show">
        <i class="bi bi-check-circle-fill me-2"></i>Operation completed successfully.
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      </div>
      <% } %>
      <% if (errorMsg != null) { %>
      <div class="alert alert-danger alert-dismissible fade show">
        <i class="bi bi-exclamation-triangle-fill me-2"></i><%= errorMsg %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      </div>
      <% } %>

      <div class="table-container">
        <% if (requests.isEmpty()) { %>
        <p class="text-muted text-center py-4">No maintenance requests found.</p>
        <% } else { %>
        <div class="table-responsive">
          <table class="table table-hover align-middle">
            <thead class="table-light">
              <tr>
                <th>Title</th><th>Facility</th><th>Reporter</th>
                <th>Priority</th><th>Status</th><th>Assigned</th><th>Date</th><th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <% for (MaintenanceRequest r : requests) { %>
              <tr>
                <td class="fw-medium"><%= r.getTitle() %></td>
                <td class="text-muted small"><%= r.getFacilityName() %></td>
                <td class="text-muted small"><%= r.getReportedByName() %></td>
                <td><span class="badge rounded-pill badge-priority-<%= r.getPriority().name() %> text-capitalize"><%= r.getPriority().name() %></span></td>
                <td><span class="badge rounded-pill badge-status-<%= r.getStatus().name() %> text-capitalize"><%= r.getStatus().name().replace("_"," ") %></span></td>
                <td class="text-muted small"><%= r.getAssignedToName() != null ? r.getAssignedToName() : "—" %></td>
                <td class="text-muted small"><%= r.getCreatedAt() != null ? r.getCreatedAt().toLocalDate() : "" %></td>
                <td>
                  <% if (canAssign && r.getStatus() == MaintenanceRequest.Status.pending && !janitors.isEmpty()) { %>
                  <form method="post" action="<%= ctx %>/maintenance-requests" class="d-flex gap-1">
                    <input type="hidden" name="action" value="assign">
                    <input type="hidden" name="id" value="<%= r.getId() %>">
                    <select name="assigneeId" class="form-select form-select-sm" style="width:120px;">
                      <% for (User j : janitors) { %>
                      <option value="<%= j.getId() %>"><%= j.getName() %></option>
                      <% } %>
                    </select>
                    <button class="btn btn-sm btn-primary">Assign</button>
                  </form>
                  <% } %>
                  <% if (canDelete) { %>
                  <form method="post" action="<%= ctx %>/maintenance-requests" class="d-inline mt-1"
                        onsubmit="return confirm('Delete this request?')">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="id" value="<%= r.getId() %>">
                    <button class="btn btn-sm btn-outline-danger"><i class="bi bi-trash-fill"></i></button>
                  </form>
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

<% if (canCreate) { %>
<!-- New Request Modal -->
<div class="modal fade" id="newRequestModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <form method="post" action="<%= ctx %>/maintenance-requests">
        <input type="hidden" name="action" value="create">
        <div class="modal-header">
          <h5 class="modal-title fw-semibold">Submit Maintenance Request</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <div class="mb-3">
            <label class="form-label fw-semibold small">Facility *</label>
            <select name="facilityId" class="form-select" required>
              <option value="">-- Select Facility --</option>
              <% for (Facility f : facilities) { %>
              <option value="<%= f.getId() %>"><%= f.getName() %></option>
              <% } %>
            </select>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold small">Title *</label>
            <input type="text" name="title" class="form-control" required maxlength="200">
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold small">Priority *</label>
            <select name="priority" class="form-select" required>
              <option value="low">Low</option>
              <option value="medium" selected>Medium</option>
              <option value="high">High</option>
              <option value="urgent">Urgent</option>
            </select>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold small">Description *</label>
            <textarea name="description" class="form-control" rows="3" required maxlength="1000"></textarea>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
          <button type="submit" class="btn btn-success">Submit Request</button>
        </div>
      </form>
    </div>
  </div>
</div>
<% } %>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
