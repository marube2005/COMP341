<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartcampus.model.*,java.util.*" %>
<%
    request.setAttribute("activePage", "cleaning");
    String ctx = request.getContextPath();
    String success  = request.getParameter("success");
    String errorMsg = (String) request.getAttribute("error");

    User currentUser = (User) session.getAttribute("loggedInUser");

    @SuppressWarnings("unchecked")
    List<CleaningTask> tasks = (List<CleaningTask>) request.getAttribute("tasks");
    if (tasks == null) tasks = Collections.emptyList();

    @SuppressWarnings("unchecked")
    List<Facility> facilities = (List<Facility>) request.getAttribute("facilities");
    if (facilities == null) facilities = Collections.emptyList();

    @SuppressWarnings("unchecked")
    List<User> janitors = (List<User>) request.getAttribute("janitors");
    if (janitors == null) janitors = Collections.emptyList();

    boolean canCreate = currentUser != null &&
        (currentUser.getRole() == User.Role.admin || currentUser.getRole() == User.Role.supervisor);
    boolean canDelete = currentUser != null && currentUser.getRole() == User.Role.admin;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cleaning Tasks | SmartCampus</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <style>
        :root { --egerton-green:#00A651; --egerton-green-dark:#008a43; --egerton-gold:#D2AC67;
                --sidebar-bg:#1a472a; --sidebar-hover:#2a5a3a; }
        body { background:#F8F9FC; font-family:'Inter',sans-serif; overflow-x:hidden; }
        .sidebar { background:linear-gradient(180deg,var(--sidebar-bg) 0%,#007624 100%);
                   min-height:100vh; color:white; }
        .nav-link-custom { color:rgba(255,255,255,.85); padding:.7rem 1.2rem; margin:.2rem .8rem;
                           border-radius:12px; transition:all .2s; font-weight:500; font-size:.9rem;
                           display:flex; align-items:center; gap:10px; text-decoration:none; }
        .nav-link-custom:hover { background:var(--sidebar-hover); color:white; }
        .nav-link-custom.active { background:var(--egerton-gold); color:#007624; font-weight:600; }
        .nav-link-custom i { font-size:1.1rem; width:22px; }
        .table-container { background:#fff; border-radius:16px; padding:1.5rem;
                           box-shadow:0 2px 8px rgba(0,0,0,.04); border:1px solid #e9ecef; }
        .badge-status-pending     { background:#fff3e0; color:#92400e; }
        .badge-status-in_progress { background:#dbeafe; color:#1e40af; }
        .badge-status-completed   { background:#d1fae5; color:#065f46; }
        .badge-status-skipped     { background:#f3f4f6; color:#374151; }
        @media (max-width: 767.98px) {
            .table-container { padding: 1rem 0.75rem; border-radius:12px; }
            h1 { font-size:1.4rem !important; }
        }
    </style>
</head>
<body>
<div class="container-fluid">
  <div class="row">
    <jsp:include page="/WEB-INF/views/shared/sidebar.jsp"/>
    <main class="col-md-10 ms-sm-auto col-lg-10 px-4 py-4">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
          <h1 style="font-family:'Playfair Display',serif;font-size:1.8rem;">Cleaning Tasks</h1>
          <p class="text-muted small mb-0">Schedule and track cleaning activities</p>
        </div>
        <% if (canCreate) { %>
        <button class="btn btn-success" data-bs-toggle="modal" data-bs-target="#newTaskModal">
          <i class="bi bi-plus-circle-fill me-1"></i> Schedule Task
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
        <% if (tasks.isEmpty()) { %>
        <p class="text-muted text-center py-4">No cleaning tasks found.</p>
        <% } else { %>
        <div class="table-responsive">
          <table class="table table-hover align-middle">
            <thead class="table-light">
              <tr><th>Facility</th><th>Assigned To</th><th>Scheduled Date</th><th>Status</th><th>Notes</th><th>Actions</th></tr>
            </thead>
            <tbody>
              <% for (CleaningTask t : tasks) { %>
              <tr>
                <td class="fw-medium"><%= t.getFacilityName() %></td>
                <td class="text-muted small"><%= t.getAssignedToName() %></td>
                <td class="text-muted small"><%= t.getScheduledDate() %></td>
                <td><span class="badge rounded-pill badge-status-<%= t.getStatus().name() %> text-capitalize"><%= t.getStatus().name().replace("_"," ") %></span></td>
                <td class="text-muted small"><%= t.getNotes() != null ? t.getNotes() : "" %></td>
                <td>
                  <form method="post" action="<%= ctx %>/cleaning-tasks" class="d-flex gap-1">
                    <input type="hidden" name="action" value="updateStatus">
                    <input type="hidden" name="id" value="<%= t.getId() %>">
                    <select name="status" class="form-select form-select-sm" style="width:115px;">
                      <option value="pending"     <%= t.getStatus() == CleaningTask.Status.pending     ? "selected" : "" %>>Pending</option>
                      <option value="in_progress" <%= t.getStatus() == CleaningTask.Status.in_progress ? "selected" : "" %>>In Progress</option>
                      <option value="completed"   <%= t.getStatus() == CleaningTask.Status.completed   ? "selected" : "" %>>Completed</option>
                      <option value="skipped"     <%= t.getStatus() == CleaningTask.Status.skipped     ? "selected" : "" %>>Skipped</option>
                    </select>
                    <button class="btn btn-sm btn-primary">Update</button>
                  </form>
                  <% if (canDelete) { %>
                  <form method="post" action="<%= ctx %>/cleaning-tasks" class="d-inline"
                        onsubmit="return confirm('Delete this task?')">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="id" value="<%= t.getId() %>">
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
<!-- New Cleaning Task Modal -->
<div class="modal fade" id="newTaskModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <form method="post" action="<%= ctx %>/cleaning-tasks">
        <input type="hidden" name="action" value="create">
        <div class="modal-header">
          <h5 class="modal-title fw-semibold">Schedule Cleaning Task</h5>
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
            <label class="form-label fw-semibold small">Assign To (Janitor) *</label>
            <select name="janitorId" class="form-select" required>
              <option value="">-- Select Janitor --</option>
              <% for (User j : janitors) { %>
              <option value="<%= j.getId() %>"><%= j.getName() %></option>
              <% } %>
            </select>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold small">Scheduled Date *</label>
            <input type="date" name="scheduledDate" class="form-control" required id="newTaskDate">
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold small">Notes</label>
            <textarea name="notes" class="form-control" rows="2" maxlength="500"></textarea>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
          <button type="submit" class="btn btn-success">Schedule Task</button>
        </div>
      </form>
    </div>
  </div>
</div>
<% } %>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.getElementById('newTaskDate').min = new Date().toISOString().split('T')[0];
</script>
</html>
