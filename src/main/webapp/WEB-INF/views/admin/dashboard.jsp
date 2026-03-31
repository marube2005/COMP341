<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartcampus.model.*,java.util.*" %>
<%
    request.setAttribute("activePage", "dashboard");
    User currentUser    = (User) session.getAttribute("loggedInUser");
    int totalUsers      = (int) request.getAttribute("totalUsers");
    int totalFacils     = (int) request.getAttribute("totalFacilities");
    int pendingReqs     = (int) request.getAttribute("pendingRequests");
    int completedToday  = request.getAttribute("completedToday") != null ? (int) request.getAttribute("completedToday") : 0;
    String ctx          = request.getContextPath();
    String errorMsg     = (String) request.getAttribute("error");

    @SuppressWarnings("unchecked")
    List<Facility> allFacilities = (List<Facility>) request.getAttribute("allFacilities");
    if (allFacilities == null) allFacilities = Collections.emptyList();

    @SuppressWarnings("unchecked")
    List<User> allUsers = (List<User>) request.getAttribute("allUsers");
    if (allUsers == null) allUsers = Collections.emptyList();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
    <title>Admin Dashboard | SmartCampus - Egerton University</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        :root {
            --egerton-green: #00A651;
            --egerton-green-dark: #008a43;
            --egerton-green-deep: #007624;
            --egerton-gold: #D2AC67;
            --bg-light: #F8F9FC;
            --card-white: #ffffff;
            --text-dark: #1F2A3A;
            --text-muted: #5a6e8a;
            --border-color: #e9ecef;
            --sidebar-bg: #1a472a;
            --sidebar-hover: #2a5a3a;
        }

        body { background: var(--bg-light); font-family: 'Inter', sans-serif; overflow-x: hidden; }

        /* Sidebar */
        .sidebar { background: linear-gradient(180deg, var(--sidebar-bg) 0%, var(--egerton-green-deep) 100%);
                   min-height: 100vh; color: white; position: relative; }
        .nav-link-custom { color: rgba(255,255,255,.85); padding: .7rem 1.2rem; margin: .2rem .8rem;
                           border-radius: 12px; transition: all .2s; font-weight: 500; font-size: .9rem;
                           display: flex; align-items: center; gap: 10px; text-decoration: none; }
        .nav-link-custom:hover { background: var(--sidebar-hover); color: white; }
        .nav-link-custom.active { background: var(--egerton-gold); color: var(--egerton-green-deep); font-weight: 600; }
        .nav-link-custom i { font-size: 1.1rem; width: 22px; }

        /* Page header */
        .page-header { margin-bottom: 2rem; }
        .page-header h1 { font-family: 'Playfair Display', serif; font-size: 1.8rem; font-weight: 700;
                          color: var(--text-dark); margin-bottom: 0.25rem; }
        .page-header p { color: var(--text-muted); font-size: 0.85rem; margin-bottom: 0; }

        /* Stat cards */
        .stat-card { background: var(--card-white); border-radius: 20px; padding: 1.2rem;
                     box-shadow: 0 2px 8px rgba(0,0,0,0.04); border: 1px solid var(--border-color);
                     transition: transform 0.2s, box-shadow 0.2s; margin-bottom: 1rem; }
        .stat-card:hover { transform: translateY(-3px); box-shadow: 0 8px 20px rgba(0,0,0,0.08); }
        .stat-icon { width: 48px; height: 48px;
                     background: linear-gradient(135deg, rgba(0,166,81,0.1), rgba(210,172,103,0.1));
                     border-radius: 16px; display: flex; align-items: center; justify-content: center;
                     margin-bottom: 0.8rem; }
        .stat-icon i { font-size: 1.8rem; color: var(--egerton-green); }
        .stat-card h3 { font-size: 1.8rem; font-weight: 700; color: var(--text-dark); margin-bottom: 0; }
        .stat-card p { color: var(--text-muted); font-size: 0.8rem; margin-bottom: 0; font-weight: 500; }

        /* Table container */
        .table-container { background: var(--card-white); border-radius: 20px; padding: 1.5rem;
                           box-shadow: 0 2px 8px rgba(0,0,0,0.04); border: 1px solid var(--border-color); }
        .table-container h5 { font-weight: 700; color: var(--text-dark); margin-bottom: 1.2rem;
                              display: flex; align-items: center; gap: 8px; }
        .table-custom { margin-bottom: 0; }
        .table-custom thead { background: #F8F9FC; }
        .table-custom th { font-weight: 600; font-size: 0.8rem; color: var(--text-muted);
                           border-bottom: 2px solid var(--border-color); padding: 0.8rem; }
        .table-custom td { font-size: 0.85rem; padding: 0.8rem; vertical-align: middle;
                           border-bottom: 1px solid var(--border-color); }

        /* Role badges */
        .badge-lecturer { background: linear-gradient(135deg, #00A65120, #D2AC6720);
                          color: var(--egerton-green-dark); font-weight: 600; padding: 4px 10px;
                          border-radius: 20px; font-size: 0.75rem; display: inline-block; }
        .badge-janitor  { background: #e8f0fe; color: #2c6e9e; font-weight: 600; padding: 4px 10px;
                          border-radius: 20px; font-size: 0.75rem; display: inline-block; }
        .badge-supervisor { background: #fff3cd; color: #856404; font-weight: 600; padding: 4px 10px;
                            border-radius: 20px; font-size: 0.75rem; display: inline-block; }
        .badge-admin    { background: #ffe6e6; color: #b33; font-weight: 600; padding: 4px 10px;
                          border-radius: 20px; font-size: 0.75rem; display: inline-block; }

        /* Status/Type badges */
        .badge-status-available   { background: #d1fae5; color: #065f46; }
        .badge-status-occupied    { background: #dbeafe; color: #1e40af; }
        .badge-status-maintenance { background: #fee2e2; color: #991b1b; }
        .badge-status-closed      { background: #f3f4f6; color: #374151; }

        /* Add button */
        .btn-add { background: var(--egerton-green); color: white; border: none;
                   padding: 8px 20px; border-radius: 12px; font-weight: 600; font-size: 0.85rem;
                   transition: all 0.2s; }
        .btn-add:hover { background: var(--egerton-green-dark); transform: translateY(-2px); color: white; }

        /* Section nav tabs */
        .section-tabs { display: flex; gap: 0.5rem; margin-bottom: 1.5rem; flex-wrap: wrap; }
        .section-tab { padding: 0.5rem 1.2rem; border-radius: 12px; border: 1px solid var(--border-color);
                       background: var(--card-white); color: var(--text-muted); font-weight: 500;
                       font-size: 0.88rem; cursor: pointer; transition: all 0.2s; text-decoration: none; display: flex; align-items: center; gap: 6px; }
        .section-tab:hover { background: rgba(0,166,81,0.05); color: var(--egerton-green); border-color: var(--egerton-green); }
        .section-tab.active { background: var(--egerton-green); color: white; border-color: var(--egerton-green); }

        /* Modal styles */
        .modal-custom .modal-content { border-radius: 24px; border: none; }
        .modal-custom .modal-header { background: linear-gradient(135deg, var(--egerton-green-dark), var(--egerton-green));
                                      color: white; border-radius: 24px 24px 0 0; border: none; }
        .modal-custom .modal-header .btn-close { filter: invert(1); }
        .modal-custom .btn-primary { background: var(--egerton-green); border: none; border-radius: 40px; padding: 8px 24px; }
        .modal-custom .btn-primary:hover { background: var(--egerton-green-dark); }

        /* Toast */
        @keyframes slideIn  { from { transform: translateX(100%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
        @keyframes slideOut { from { transform: translateX(0); opacity: 1; } to { transform: translateX(100%); opacity: 0; } }
        .custom-toast { position: fixed; bottom: 20px; right: 20px; padding: 12px 20px;
                        border-radius: 12px; font-size: 0.85rem; font-weight: 500; z-index: 9999;
                        box-shadow: 0 4px 12px rgba(0,0,0,0.15); animation: slideIn 0.3s ease;
                        cursor: pointer; display: flex; align-items: center; gap: 8px; }

        @media (max-width: 768px) { .page-header h1 { font-size: 1.4rem; } }
    </style>
</head>
<body>
<div class="container-fluid">
  <div class="row">
    <!-- Sidebar (layout kept as-is) -->
    <jsp:include page="/WEB-INF/views/shared/sidebar.jsp"/>

    <!-- Main content -->
    <main class="col-md-10 ms-sm-auto col-lg-10 px-4 py-4">

      <!-- Page Header -->
      <div class="page-header d-flex justify-content-between align-items-center flex-wrap gap-2">
        <div>
          <h1>Admin Dashboard</h1>
          <p>Welcome back, <%= currentUser.getName() %> &nbsp;|&nbsp; Campus Management Overview</p>
        </div>
        <span class="badge bg-light text-dark p-2 shadow-sm">
          <i class="bi bi-person-circle"></i> <%= currentUser.getName() %>
          <span class="badge bg-success ms-1">admin</span>
        </span>
      </div>

      <% if (errorMsg != null) { %>
      <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <i class="bi bi-exclamation-triangle-fill me-2"></i><%= errorMsg %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      </div>
      <span id="serverErrorMsg" data-msg="<%= errorMsg.replace("&","&amp;").replace("\"","&quot;") %>" class="d-none"></span>
      <% } %>

      <!-- Stats Cards -->
      <div class="row mb-4">
        <div class="col-md-3 col-sm-6">
          <div class="stat-card">
            <div class="stat-icon"><i class="bi bi-door-closed"></i></div>
            <h3><%= totalFacils %></h3>
            <p>Total Offices</p>
          </div>
        </div>
        <div class="col-md-3 col-sm-6">
          <div class="stat-card">
            <div class="stat-icon"><i class="bi bi-people"></i></div>
            <h3><%= totalUsers %></h3>
            <p>Total Users</p>
          </div>
        </div>
        <div class="col-md-3 col-sm-6">
          <div class="stat-card">
            <div class="stat-icon"><i class="bi bi-check2-circle"></i></div>
            <h3><%= completedToday %></h3>
            <p>Completed Today</p>
          </div>
        </div>
        <div class="col-md-3 col-sm-6">
          <div class="stat-card">
            <div class="stat-icon"><i class="bi bi-hourglass-split"></i></div>
            <h3><%= pendingReqs %></h3>
            <p>Pending Tasks</p>
          </div>
        </div>
      </div>

      <!-- Section Tabs -->
      <div class="section-tabs">
        <a class="section-tab active" id="tab-facilities" onclick="showSection('facilities')">
          <i class="bi bi-building"></i> Offices
        </a>
        <a class="section-tab" id="tab-users" onclick="showSection('users')">
          <i class="bi bi-people"></i> Users
        </a>
        <a class="section-tab" href="<%= ctx %>/cleaning-tasks">
          <i class="bi bi-bucket-fill"></i> Cleaning Tasks
        </a>
      </div>

      <!-- Offices Section -->
      <div id="facilitiesSection">
        <div class="table-container">
          <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
            <h5><i class="bi bi-building text-success"></i> Offices</h5>
            <button class="btn-add" data-bs-toggle="modal" data-bs-target="#addFacilityModal">
              <i class="bi bi-plus-lg"></i> Add Office
            </button>
          </div>
          <div class="table-responsive">
            <table class="table table-custom table-hover">
              <thead>
                <tr>
                  <th>#</th><th>Office</th><th>Wing</th><th>Capacity</th><th>Status</th><th>Actions</th>
                </tr>
              </thead>
              <tbody>
                <% if (allFacilities.isEmpty()) { %>
                <tr><td colspan="6" class="text-center text-muted py-4">No offices found.</td></tr>
                <% } else {
                   for (Facility f : allFacilities) { %>
                <tr>
                  <td><strong><%= f.getId() %></strong></td>
                  <td><strong><%= f.getName() %></strong></td>
                  <td><span class="badge bg-secondary bg-opacity-10 text-dark"><%= f.getLocation() %></span></td>
                  <td><%= f.getCapacity() > 0 ? f.getCapacity() : "—" %></td>
                  <td><span class="badge rounded-pill badge-status-<%= f.getStatus().name() %> text-capitalize px-3"><%= f.getStatus().name() %></span></td>
                  <td>
                    <button class="btn btn-sm btn-outline-success me-1" style="border-radius:20px;"
                            data-fac-id="<%= f.getId() %>"
                            data-fac-name="<%= f.getName().replace("&","&amp;").replace("\"","&quot;") %>"
                            data-fac-loc="<%= f.getLocation().replace("&","&amp;").replace("\"","&quot;") %>"
                            data-fac-cap="<%= f.getCapacity() %>"
                            data-fac-status="<%= f.getStatus().name() %>"
                            data-fac-desc="<%= f.getDescription() != null ? f.getDescription().replace("&","&amp;").replace("\"","&quot;") : "" %>"
                            onclick="openEditFacility(this)">
                      <i class="bi bi-pencil-square"></i>
                    </button>
                    <form method="post" action="<%= ctx %>/facilities" class="d-inline"
                          onsubmit="return confirm('Delete this office? This cannot be undone.')">
                      <input type="hidden" name="action" value="delete">
                      <input type="hidden" name="id" value="<%= f.getId() %>">
                      <button class="btn btn-sm btn-outline-danger" style="border-radius:20px;">
                        <i class="bi bi-trash3"></i>
                      </button>
                    </form>
                  </td>
                </tr>
                <% } } %>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Users Section (hidden by default) -->
      <div id="usersSection" style="display:none;">
        <div class="table-container">
          <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
            <h5><i class="bi bi-people text-success"></i> Users Management</h5>
            <a href="<%= ctx %>/admin/users" class="btn-add text-decoration-none">
              <i class="bi bi-person-plus-fill"></i> Manage Users
            </a>
          </div>
          <div class="table-responsive">
            <table class="table table-custom table-hover">
              <thead>
                <tr><th>Name</th><th>Email</th><th>Role</th><th>Department</th><th>Status</th></tr>
              </thead>
              <tbody>
                <% if (allUsers.isEmpty()) { %>
                <tr><td colspan="5" class="text-center text-muted py-4">No users found.</td></tr>
                <% } else {
                   for (User u : allUsers) {
                       String roleClass = "admin".equals(u.getRole().name()) ? "badge-admin"
                                        : "lecturer".equals(u.getRole().name()) ? "badge-lecturer"
                                        : "janitor".equals(u.getRole().name()) ? "badge-janitor"
                                        : "badge-supervisor"; %>
                <tr>
                  <td><strong><%= u.getName() %></strong></td>
                  <td><%= u.getEmail() %></td>
                  <td><span class="<%= roleClass %> text-capitalize"><%= u.getRole().name() %></span></td>
                  <td><%= u.getDepartment() != null ? u.getDepartment() : "—" %></td>
                  <td>
                    <% if (u.isActive()) { %>
                    <span class="badge bg-success-subtle text-success border border-success-subtle">Active</span>
                    <% } else { %>
                    <span class="badge bg-secondary-subtle text-secondary border border-secondary-subtle">Inactive</span>
                    <% } %>
                  </td>
                </tr>
                <% } } %>
              </tbody>
            </table>
          </div>
        </div>
      </div>

    </main>
  </div>
</div>

<!-- Add Office Modal -->
<div class="modal fade modal-custom" id="addFacilityModal" tabindex="-1">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <form method="post" action="<%= ctx %>/facilities">
        <input type="hidden" name="action" value="create">
        <input type="hidden" name="facilityType" value="office">
        <div class="modal-header">
          <h5 class="modal-title"><i class="bi bi-plus-circle"></i> Add New Office</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <div class="mb-3">
            <label class="form-label fw-semibold">Office Number *</label>
            <input type="text" name="name" class="form-control" required maxlength="150" placeholder="e.g., A101, B202">
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Wing *</label>
            <select name="location" class="form-select" required>
              <option value="Wing A">Wing A</option>
              <option value="Wing B">Wing B</option>
              <option value="Wing C">Wing C</option>
              <option value="Wing D">Wing D</option>
            </select>
          </div>
          <div class="row">
            <div class="col mb-3">
              <label class="form-label fw-semibold">Capacity</label>
              <input type="number" name="capacity" class="form-control" min="0" value="0">
            </div>
            <div class="col mb-3">
              <label class="form-label fw-semibold">Status *</label>
              <select name="status" class="form-select" required>
                <option value="available">Available</option>
                <option value="occupied">Occupied</option>
                <option value="maintenance">Maintenance</option>
                <option value="closed">Closed</option>
              </select>
            </div>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Description</label>
            <textarea name="description" class="form-control" rows="2" maxlength="500"></textarea>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
          <button type="submit" class="btn btn-primary">Add Office</button>
        </div>
      </form>
    </div>
  </div>
</div>

<!-- Edit Office Modal -->
<div class="modal fade modal-custom" id="editFacilityModal" tabindex="-1">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <form method="post" action="<%= ctx %>/facilities">
        <input type="hidden" name="action" value="update">
        <input type="hidden" name="id" id="editFacId">
        <input type="hidden" name="facilityType" value="office">
        <div class="modal-header">
          <h5 class="modal-title"><i class="bi bi-pencil-square"></i> Edit Office</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <div class="mb-3">
            <label class="form-label fw-semibold">Office Number *</label>
            <input type="text" name="name" id="editFacName" class="form-control" required maxlength="150">
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Wing *</label>
            <select name="location" id="editFacLoc" class="form-select" required>
              <option value="Wing A">Wing A</option>
              <option value="Wing B">Wing B</option>
              <option value="Wing C">Wing C</option>
              <option value="Wing D">Wing D</option>
            </select>
          </div>
          <div class="row">
            <div class="col mb-3">
              <label class="form-label fw-semibold">Capacity</label>
              <input type="number" name="capacity" id="editFacCap" class="form-control" min="0">
            </div>
            <div class="col mb-3">
              <label class="form-label fw-semibold">Status *</label>
              <select name="status" id="editFacStatus" class="form-select" required>
                <option value="available">Available</option>
                <option value="occupied">Occupied</option>
                <option value="maintenance">Maintenance</option>
                <option value="closed">Closed</option>
              </select>
            </div>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Description</label>
            <textarea name="description" id="editFacDesc" class="form-control" rows="2" maxlength="500"></textarea>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
          <button type="submit" class="btn btn-primary">Update Office</button>
        </div>
      </form>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Section switching
    function showSection(name) {
        ['facilities', 'users'].forEach(s => {
            document.getElementById(s + 'Section').style.display = (s === name) ? 'block' : 'none';
            const tab = document.getElementById('tab-' + s);
            if (tab) tab.classList.toggle('active', s === name);
        });
    }

    // Edit office modal - reads from safe HTML data attributes
    function openEditFacility(btn) {
        document.getElementById('editFacId').value      = btn.dataset.facId;
        document.getElementById('editFacName').value    = btn.dataset.facName;
        document.getElementById('editFacLoc').value     = btn.dataset.facLoc;
        document.getElementById('editFacCap').value     = btn.dataset.facCap;
        document.getElementById('editFacStatus').value  = btn.dataset.facStatus;
        document.getElementById('editFacDesc').value    = btn.dataset.facDesc;
        new bootstrap.Modal(document.getElementById('editFacilityModal')).show();
    }

    // Toast notification
    function showToast(message, type) {
        const toast = document.createElement('div');
        toast.className = 'custom-toast';
        toast.style.backgroundColor = type === 'success' ? '#00A651' : type === 'error' ? '#dc3545' : '#17a2b8';
        toast.style.color = 'white';
        const icons = { success: 'bi-check-circle-fill', error: 'bi-exclamation-triangle-fill', info: 'bi-info-circle-fill' };
        const icon = document.createElement('i');
        icon.className = 'bi ' + (icons[type] || icons.info);
        const text = document.createElement('span');
        text.textContent = message;
        toast.appendChild(icon);
        toast.appendChild(text);
        document.body.appendChild(toast);
        setTimeout(() => { toast.style.animation = 'slideOut 0.3s ease'; setTimeout(() => toast.remove(), 300); }, 2500);
        toast.onclick = () => { toast.style.animation = 'slideOut 0.3s ease'; setTimeout(() => toast.remove(), 300); };
    }

    <% if (request.getParameter("success") != null) { %>
    showToast('Operation completed successfully!', 'success');
    <% } %>
    <% if (errorMsg != null) { %>
    showToast(document.getElementById('serverErrorMsg').dataset.msg, 'error');
    <% } %>
</script>
</body>
</html>
