<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartcampus.model.*,java.util.*" %>
<%
    request.setAttribute("activePage", "facilities");
    String ctx = request.getContextPath();
    String success  = request.getParameter("success");
    String errorMsg = (String) request.getAttribute("error");

    @SuppressWarnings("unchecked")
    List<Facility> facilities = (List<Facility>) request.getAttribute("facilities");
    if (facilities == null) facilities = Collections.emptyList();

    User sessionUser = (User) session.getAttribute("loggedInUser");
    boolean isAdmin = sessionUser != null && sessionUser.getRole() == User.Role.admin;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Facilities | SmartCampus</title>
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
        .badge-status-available   { background:#d1fae5; color:#065f46; }
        .badge-status-occupied    { background:#dbeafe; color:#1e40af; }
        .badge-status-maintenance { background:#fee2e2; color:#991b1b; }
        .badge-status-closed      { background:#f3f4f6; color:#374151; }
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
          <h1 style="font-family:'Playfair Display',serif;font-size:1.8rem;">Facilities</h1>
          <p class="text-muted small mb-0">Campus facility directory</p>
        </div>
        <% if (isAdmin) { %>
        <button class="btn btn-success" data-bs-toggle="modal" data-bs-target="#addFacilityModal">
          <i class="bi bi-plus-circle-fill me-1"></i> Add Facility
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
        <div class="table-responsive">
          <table class="table table-hover align-middle">
            <thead class="table-light">
              <tr>
                <th>#</th><th>Name</th><th>Location</th><th>Type</th>
                <th>Capacity</th><th>Status</th><th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <% for (Facility f : facilities) { %>
              <tr>
                <td class="text-muted small"><%= f.getId() %></td>
                <td class="fw-medium"><%= f.getName() %></td>
                <td class="text-muted small"><%= f.getLocation() %></td>
                <td class="text-capitalize"><%= f.getFacilityType().name() %></td>
                <td><%= f.getCapacity() > 0 ? f.getCapacity() : "—" %></td>
                <td><span class="badge rounded-pill badge-status-<%= f.getStatus().name() %> text-capitalize px-3"><%= f.getStatus().name() %></span></td>
                <td>
                  <% if (isAdmin) { %>
                  <button class="btn btn-sm btn-outline-primary me-1"
                          onclick="openEditFacility(<%= f.getId() %>,'<%= f.getName().replace("'","\\'") %>','<%= f.getLocation().replace("'","\\'") %>','<%= f.getFacilityType().name() %>',<%= f.getCapacity() %>,'<%= f.getStatus().name() %>','<%= f.getDescription() != null ? f.getDescription().replace("'","\\'") : "" %>')">
                    <i class="bi bi-pencil-fill"></i>
                  </button>
                  <form method="post" action="<%= ctx %>/facilities" class="d-inline"
                        onsubmit="return confirm('Delete this facility? This cannot be undone.')">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="id" value="<%= f.getId() %>">
                    <button class="btn btn-sm btn-outline-danger"><i class="bi bi-trash-fill"></i></button>
                  </form>
                  <% } %>
                </td>
              </tr>
              <% } %>
              <% if (facilities.isEmpty()) { %>
              <tr><td colspan="7" class="text-center text-muted py-4">No facilities found.</td></tr>
              <% } %>
            </tbody>
          </table>
        </div>
      </div>
    </main>
  </div>
</div>

<% if (isAdmin) { %>
<!-- Add Facility Modal -->
<div class="modal fade" id="addFacilityModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <form method="post" action="<%= ctx %>/facilities">
        <input type="hidden" name="action" value="create">
        <div class="modal-header">
          <h5 class="modal-title fw-semibold">Add New Facility</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <div class="mb-3">
            <label class="form-label fw-semibold small">Facility Name *</label>
            <input type="text" name="name" class="form-control" required maxlength="150">
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold small">Location *</label>
            <input type="text" name="location" class="form-control" required maxlength="200">
          </div>
          <div class="row">
            <div class="col mb-3">
              <label class="form-label fw-semibold small">Type *</label>
              <select name="facilityType" class="form-select" required>
                <option value="classroom">Classroom</option>
                <option value="lab">Lab</option>
                <option value="office">Office</option>
                <option value="hall">Hall</option>
                <option value="restroom">Restroom</option>
                <option value="other">Other</option>
              </select>
            </div>
            <div class="col mb-3">
              <label class="form-label fw-semibold small">Capacity</label>
              <input type="number" name="capacity" class="form-control" min="0" value="0">
            </div>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold small">Status *</label>
            <select name="status" class="form-select" required>
              <option value="available">Available</option>
              <option value="occupied">Occupied</option>
              <option value="maintenance">Maintenance</option>
              <option value="closed">Closed</option>
            </select>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold small">Description</label>
            <textarea name="description" class="form-control" rows="2" maxlength="500"></textarea>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
          <button type="submit" class="btn btn-success">Create Facility</button>
        </div>
      </form>
    </div>
  </div>
</div>

<!-- Edit Facility Modal -->
<div class="modal fade" id="editFacilityModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <form method="post" action="<%= ctx %>/facilities">
        <input type="hidden" name="action" value="update">
        <input type="hidden" name="id" id="editFacId">
        <div class="modal-header">
          <h5 class="modal-title fw-semibold">Edit Facility</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <div class="mb-3">
            <label class="form-label fw-semibold small">Facility Name *</label>
            <input type="text" name="name" id="editFacName" class="form-control" required maxlength="150">
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold small">Location *</label>
            <input type="text" name="location" id="editFacLoc" class="form-control" required maxlength="200">
          </div>
          <div class="row">
            <div class="col mb-3">
              <label class="form-label fw-semibold small">Type *</label>
              <select name="facilityType" id="editFacType" class="form-select" required>
                <option value="classroom">Classroom</option>
                <option value="lab">Lab</option>
                <option value="office">Office</option>
                <option value="hall">Hall</option>
                <option value="restroom">Restroom</option>
                <option value="other">Other</option>
              </select>
            </div>
            <div class="col mb-3">
              <label class="form-label fw-semibold small">Capacity</label>
              <input type="number" name="capacity" id="editFacCap" class="form-control" min="0">
            </div>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold small">Status *</label>
            <select name="status" id="editFacStatus" class="form-select" required>
              <option value="available">Available</option>
              <option value="occupied">Occupied</option>
              <option value="maintenance">Maintenance</option>
              <option value="closed">Closed</option>
            </select>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold small">Description</label>
            <textarea name="description" id="editFacDesc" class="form-control" rows="2" maxlength="500"></textarea>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
          <button type="submit" class="btn btn-primary">Save Changes</button>
        </div>
      </form>
    </div>
  </div>
</div>
<% } %>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
function openEditFacility(id, name, location, type, capacity, status, description) {
    document.getElementById('editFacId').value     = id;
    document.getElementById('editFacName').value   = name;
    document.getElementById('editFacLoc').value    = location;
    document.getElementById('editFacType').value   = type;
    document.getElementById('editFacCap').value    = capacity;
    document.getElementById('editFacStatus').value = status;
    document.getElementById('editFacDesc').value   = description;
    new bootstrap.Modal(document.getElementById('editFacilityModal')).show();
}
</script>
</body>
</html>
