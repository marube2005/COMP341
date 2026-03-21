<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartcampus.model.*,java.util.*" %>
<%
    request.setAttribute("activePage", "users");
    String ctx = request.getContextPath();
    String success  = request.getParameter("success");
    String errorMsg = (String) request.getAttribute("error");

    @SuppressWarnings("unchecked")
    List<User> users = (List<User>) request.getAttribute("users");
    if (users == null) users = Collections.emptyList();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Manage Users | SmartCampus</title>
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
    </style>
</head>
<body>
<div class="container-fluid">
  <div class="row">
    <jsp:include page="/WEB-INF/views/shared/sidebar.jsp"/>
    <main class="col-md-10 ms-sm-auto col-lg-10 px-4 py-4">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
          <h1 style="font-family:'Playfair Display',serif;font-size:1.8rem;">User Management</h1>
          <p class="text-muted small mb-0">Add, update, or deactivate system users</p>
        </div>
        <button class="btn btn-success" data-bs-toggle="modal" data-bs-target="#addUserModal">
          <i class="bi bi-person-plus-fill me-1"></i> Add User
        </button>
      </div>

      <% if (success != null) { %>
      <div class="alert alert-success alert-dismissible fade show">
        <i class="bi bi-check-circle-fill me-2"></i>
        Operation completed successfully.
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
                <th>#</th><th>Name</th><th>Email</th><th>Role</th>
                <th>Department</th><th>Status</th><th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <% for (User u : users) { %>
              <tr>
                <td class="text-muted small"><%= u.getId() %></td>
                <td class="fw-medium"><%= u.getName() %></td>
                <td class="text-muted small"><%= u.getEmail() %></td>
                <td><span class="badge bg-<%= "admin".equals(u.getRole().name()) ? "danger" : "success" %> text-capitalize"><%= u.getRole().name() %></span></td>
                <td><%= u.getDepartment() != null ? u.getDepartment() : "" %></td>
                <td>
                  <% if (u.isActive()) { %>
                  <span class="badge bg-success-subtle text-success border border-success-subtle">Active</span>
                  <% } else { %>
                  <span class="badge bg-secondary-subtle text-secondary border border-secondary-subtle">Inactive</span>
                  <% } %>
                </td>
                <td>
                  <button class="btn btn-sm btn-outline-primary me-1"
                          onclick="openEditModal(<%= u.getId() %>,'<%= u.getName().replace("'","\\'") %>','<%= u.getRole().name() %>','<%= u.getPhone() != null ? u.getPhone() : "" %>','<%= u.getDepartment() != null ? u.getDepartment().replace("'","\\'") : "" %>')">
                    <i class="bi bi-pencil-fill"></i>
                  </button>
                  <% if (u.isActive()) { %>
                  <form method="post" action="<%= ctx %>/admin/users" class="d-inline"
                        onsubmit="return confirm('Deactivate this user?')">
                    <input type="hidden" name="action" value="deactivate">
                    <input type="hidden" name="id" value="<%= u.getId() %>">
                    <button class="btn btn-sm btn-outline-warning">
                      <i class="bi bi-person-x-fill"></i>
                    </button>
                  </form>
                  <% } %>
                </td>
              </tr>
              <% } %>
              <% if (users.isEmpty()) { %>
              <tr><td colspan="7" class="text-center text-muted py-4">No users found.</td></tr>
              <% } %>
            </tbody>
          </table>
        </div>
      </div>
    </main>
  </div>
</div>

<!-- Add User Modal -->
<div class="modal fade" id="addUserModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <form method="post" action="<%= ctx %>/admin/users">
        <input type="hidden" name="action" value="create">
        <div class="modal-header">
          <h5 class="modal-title fw-semibold">Add New User</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <div class="mb-3">
            <label class="form-label fw-semibold small">Full Name *</label>
            <input type="text" name="name" class="form-control" required maxlength="120">
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold small">Email *</label>
            <input type="email" name="email" class="form-control" required maxlength="150">
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold small">Password *</label>
            <input type="password" name="password" class="form-control" required minlength="6" maxlength="72">
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold small">Role *</label>
            <select name="role" class="form-select" required>
              <option value="">-- Select Role --</option>
              <option value="admin">Administrator</option>
              <option value="lecturer">Lecturer</option>
              <option value="janitor">Janitor</option>
              <option value="supervisor">Supervisor</option>
            </select>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold small">Phone</label>
            <input type="text" name="phone" class="form-control" maxlength="20">
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold small">Department</label>
            <input type="text" name="department" class="form-control" maxlength="100">
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
          <button type="submit" class="btn btn-success">Create User</button>
        </div>
      </form>
    </div>
  </div>
</div>

<!-- Edit User Modal -->
<div class="modal fade" id="editUserModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <form method="post" action="<%= ctx %>/admin/users">
        <input type="hidden" name="action" value="update">
        <input type="hidden" name="id" id="editUserId">
        <div class="modal-header">
          <h5 class="modal-title fw-semibold">Edit User</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <div class="mb-3">
            <label class="form-label fw-semibold small">Full Name *</label>
            <input type="text" name="name" id="editUserName" class="form-control" required maxlength="120">
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold small">Role *</label>
            <select name="role" id="editUserRole" class="form-select" required>
              <option value="admin">Administrator</option>
              <option value="lecturer">Lecturer</option>
              <option value="janitor">Janitor</option>
              <option value="supervisor">Supervisor</option>
            </select>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold small">Phone</label>
            <input type="text" name="phone" id="editUserPhone" class="form-control" maxlength="20">
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold small">Department</label>
            <input type="text" name="department" id="editUserDept" class="form-control" maxlength="100">
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
function openEditModal(id, name, role, phone, dept) {
    document.getElementById('editUserId').value    = id;
    document.getElementById('editUserName').value  = name;
    document.getElementById('editUserRole').value  = role;
    document.getElementById('editUserPhone').value = phone;
    document.getElementById('editUserDept').value  = dept;
    new bootstrap.Modal(document.getElementById('editUserModal')).show();
}
</script>
</body>
</html>
