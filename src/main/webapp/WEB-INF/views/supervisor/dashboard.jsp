<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartcampus.model.*,java.util.*" %>
<%
    request.setAttribute("activePage", "dashboard");
    User currentUser = (User) session.getAttribute("loggedInUser");
    String ctx = request.getContextPath();

    @SuppressWarnings("unchecked")
    List<CleaningTask> allTasks = (List<CleaningTask>) request.getAttribute("allTasks");
    if (allTasks == null) allTasks = Collections.emptyList();

    @SuppressWarnings("unchecked")
    List<User> janitors = (List<User>) request.getAttribute("janitors");
    if (janitors == null) janitors = Collections.emptyList();

    @SuppressWarnings("unchecked")
    List<LecturerReport> lecturerReports = (List<LecturerReport>) request.getAttribute("lecturerReports");
    if (lecturerReports == null) lecturerReports = Collections.emptyList();

    long pendingCount = 0, inProgressCount = 0, completedCount = 0;
    for (CleaningTask t : allTasks) {
        switch (t.getStatus()) {
            case pending:     pendingCount++;     break;
            case in_progress: inProgressCount++;  break;
            case completed:   completedCount++;   break;
            default: break;
        }
    }
    long activeAlerts = inProgressCount;
    int disputedCount = lecturerReports.size();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Supervisor Dashboard | SmartCampus - Egerton University</title>
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
            --high-intensity-bg: #fee2e2;
            --high-intensity-color: #e74c3c;
            --low-intensity-bg: #e0f2e9;
            --low-intensity-color: #00A651;
            --pending-bg: #fff3e0;
            --pending-color: #e67e22;
            --completed-bg: #e0f2e9;
            --completed-color: #00A651;
            --alert-bg: #fee2e2;
            --alert-color: #e74c3c;
        }

        body { background: var(--bg-light); font-family: 'Inter', sans-serif; overflow-x: hidden; }

        .sidebar { background: linear-gradient(180deg, var(--sidebar-bg) 0%, var(--egerton-green-deep) 100%);
                   min-height: 100vh; color: white; box-shadow: 2px 0 12px rgba(0,0,0,0.08); }
        .nav-link-custom { color: rgba(255,255,255,0.85); padding: 0.7rem 1.2rem; margin: 0.2rem 0.8rem;
                           border-radius: 12px; transition: all 0.2s; font-weight: 500; font-size: 0.9rem;
                           display: flex; align-items: center; gap: 10px; text-decoration: none; }
        .nav-link-custom:hover { background: var(--sidebar-hover); color: white; transform: translateX(4px); }
        .nav-link-custom.active { background: var(--egerton-gold); color: var(--egerton-green-deep); font-weight: 600; }
        .nav-link-custom i { font-size: 1.2rem; width: 24px; }

        .main-content { padding: 1.5rem 2rem; }

        .welcome-header h1 { font-family: 'Playfair Display', serif; font-size: 1.8rem; font-weight: 700; color: var(--text-dark); }
        .welcome-header p { color: var(--text-muted); font-size: 0.85rem; }

        .stat-card { background: var(--card-white); border-radius: 20px; padding: 1.2rem;
                     box-shadow: 0 2px 8px rgba(0,0,0,0.04); border: 1px solid var(--border-color);
                     transition: transform 0.2s; text-align: center; }
        .stat-card:hover { transform: translateY(-3px); }
        .stat-icon { width: 48px; height: 48px;
                     background: linear-gradient(135deg, rgba(0,166,81,0.1), rgba(210,172,103,0.1));
                     border-radius: 16px; display: flex; align-items: center; justify-content: center;
                     margin: 0 auto 0.8rem; }
        .stat-icon i { font-size: 1.8rem; color: var(--egerton-green); }
        .stat-card h3 { font-size: 1.8rem; font-weight: 700; margin-bottom: 0; }
        .stat-card p { color: var(--text-muted); font-size: 0.75rem; margin-bottom: 0; }

        .alert-card { background: var(--alert-bg); border-left: 4px solid var(--alert-color);
                      border-radius: 12px; padding: 1rem; margin-bottom: 1rem; }

        .table-container { background: var(--card-white); border-radius: 20px; padding: 1.5rem;
                           box-shadow: 0 2px 8px rgba(0,0,0,0.04); border: 1px solid var(--border-color); }

        .table-custom { margin-bottom: 0; }
        .table-custom thead { background: #F8F9FC; }
        .table-custom th { font-weight: 600; font-size: 0.8rem; color: var(--text-muted); padding: 0.8rem; }
        .table-custom td { font-size: 0.85rem; padding: 0.8rem; vertical-align: middle; }

        .status-completed { background: var(--completed-bg); color: var(--completed-color);
                            padding: 4px 10px; border-radius: 20px; font-size: 0.7rem; font-weight: 600; }
        .status-pending   { background: var(--pending-bg); color: var(--pending-color);
                            padding: 4px 10px; border-radius: 20px; font-size: 0.7rem; font-weight: 600; }
        .status-progress  { background: #e3f2fd; color: #1976d2;
                            padding: 4px 10px; border-radius: 20px; font-size: 0.7rem; font-weight: 600; }
        .status-skipped   { background: #f3f4f6; color: #374151;
                            padding: 4px 10px; border-radius: 20px; font-size: 0.7rem; font-weight: 600; }

        .progress-bar-custom { width: 60px; height: 6px; background: var(--border-color);
                               border-radius: 3px; overflow: hidden; }
        .progress-fill { height: 100%; background: var(--egerton-green); border-radius: 3px; }

        .btn-reassign { background: var(--egerton-gold); color: var(--egerton-green-deep); border: none;
                        padding: 4px 12px; border-radius: 20px; font-size: 0.7rem; font-weight: 600; transition: all 0.2s; }
        .btn-reassign:hover { background: var(--egerton-green); color: white; }

        .task-item { padding: 12px 0; border-bottom: 1px solid var(--border-color); }
        .task-item:last-child { border-bottom: none; }
        .task-content { flex: 1; }

        .janitor-card { background: var(--card-white); border-radius: 16px; padding: 1rem;
                        border: 1px solid var(--border-color); transition: all 0.2s; }
        .janitor-card:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.08); }
        .janitor-avatar { width: 48px; height: 48px;
                          background: linear-gradient(135deg, var(--egerton-green), var(--egerton-gold));
                          border-radius: 50%; display: flex; align-items: center; justify-content: center;
                          color: white; font-weight: bold; font-size: 1.2rem; }
        .janitor-progress { width: 100%; height: 6px; background: var(--border-color);
                            border-radius: 3px; overflow: hidden; margin-top: 0.5rem; }
        .janitor-progress-fill { height: 100%; background: var(--egerton-green); border-radius: 3px; }

        @keyframes slideIn  { from { transform: translateX(100%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
        @keyframes slideOut { from { transform: translateX(0); opacity: 1; } to { transform: translateX(100%); opacity: 0; } }
        .custom-toast { position: fixed; bottom: 20px; right: 20px; padding: 12px 20px; border-radius: 12px;
                        font-size: 0.85rem; font-weight: 500; z-index: 9999; animation: slideIn 0.3s ease;
                        cursor: pointer; display: flex; align-items: center; gap: 8px; }

        .modal-custom .modal-content { border-radius: 24px; border: none; }
        .modal-custom .modal-header { background: linear-gradient(135deg, var(--egerton-green-dark), var(--egerton-green));
                                      color: white; border-radius: 24px 24px 0 0; }

        @media (max-width: 768px) {
            .sidebar { min-height: auto; }
            .main-content { padding: 1rem; }
        }
    </style>
</head>
<body>
<div class="container-fluid">
  <div class="row">
    <jsp:include page="/WEB-INF/views/shared/sidebar.jsp"/>

    <div class="col-md-10 ms-sm-auto col-lg-10 main-content">

      <!-- Welcome Header -->
      <div class="welcome-header d-flex justify-content-between align-items-center mb-4">
        <div>
          <h1>Supervisor Dashboard</h1>
          <p>Monitor and manage cleaning operations</p>
        </div>
        <span class="badge bg-light text-dark p-2 shadow-sm">
          <i class="bi bi-person-circle"></i> Supervisor &nbsp;|&nbsp; <%= currentUser.getEmail() %>
        </span>
      </div>

      <!-- Dashboard Section -->
      <div id="dashboardSection">

        <!-- Stats Cards -->
        <div class="row mb-4">
          <div class="col-md-3">
            <div class="stat-card">
              <div class="stat-icon"><i class="bi bi-check2-circle"></i></div>
              <h3><%= completedCount %></h3>
              <p>Completed</p>
            </div>
          </div>
          <div class="col-md-3">
            <div class="stat-card">
              <div class="stat-icon"><i class="bi bi-exclamation-triangle"></i></div>
              <h3><%= disputedCount %></h3>
              <p>Disputed</p>
            </div>
          </div>
          <div class="col-md-3">
            <div class="stat-card">
              <div class="stat-icon"><i class="bi bi-bell"></i></div>
              <h3><%= activeAlerts %></h3>
              <p>Active Alerts</p>
            </div>
          </div>
          <div class="col-md-3">
            <div class="stat-card">
              <div class="stat-icon"><i class="bi bi-hourglass-split"></i></div>
              <h3><%= pendingCount %></h3>
              <p>Pending</p>
            </div>
          </div>
        </div>

        <!-- Incomplete Task Alert -->
        <% if (inProgressCount > 0) { %>
        <div class="alert-card mb-4">
          <div class="d-flex align-items-center gap-2">
            <i class="bi bi-clock-history text-danger fs-4"></i>
            <div>
              <strong>Incomplete Task Alert</strong><br>
              <small><%= inProgressCount %> task<%= inProgressCount == 1 ? "" : "s" %> currently in progress</small>
            </div>
          </div>
        </div>
        <% } %>

        <!-- Pending Tasks Summary -->
        <div class="table-container">
          <h5><i class="bi bi-list-check text-success"></i> Pending Tasks Summary</h5>
          <p class="text-muted small">Tasks awaiting completion</p>
          <% boolean hasPending = false;
             for (CleaningTask t : allTasks) {
               if (t.getStatus() == CleaningTask.Status.pending || t.getStatus() == CleaningTask.Status.in_progress) {
                 hasPending = true; break;
               }
             }
             if (!hasPending) { %>
          <div class="text-center py-4 text-muted">No pending tasks</div>
          <% } else {
               for (CleaningTask t : allTasks) {
                 if (t.getStatus() != CleaningTask.Status.pending && t.getStatus() != CleaningTask.Status.in_progress) continue;
                 String statusClass = t.getStatus() == CleaningTask.Status.in_progress ? "status-progress" : "status-pending";
                 String statusText  = t.getStatus() == CleaningTask.Status.in_progress ? "In Progress" : "Pending";
          %>
          <div class="task-item d-flex align-items-center gap-2">
            <div class="task-content">
              <div class="d-flex justify-content-between align-items-center mb-1">
                <strong><%= t.getFacilityName() %></strong>
                <span class="<%= statusClass %>"><%= statusText %></span>
              </div>
              <div class="d-flex justify-content-between align-items-center">
                <small class="text-muted">Scheduled: <%= t.getScheduledDate() %></small>
                <small class="text-muted">Assigned: <%= t.getAssignedToName() != null ? t.getAssignedToName() : "Unassigned" %></small>
              </div>
            </div>
          </div>
          <% } } %>
        </div>
      </div>

      <!-- Live Monitor Section -->
      <div id="monitorSection" style="display:none;">
        <div class="table-container">
          <h5><i class="bi bi-tv text-success"></i> Live Task Monitor</h5>
          <p class="text-muted small mb-3">Real-time tracking of all cleaning tasks</p>
          <% if (allTasks.isEmpty()) { %>
          <div class="text-center py-4 text-muted">No tasks found</div>
          <% } else { %>
          <div class="table-responsive">
            <table class="table table-custom align-middle">
              <thead>
                <tr>
                  <th>Office</th>
                  <th>Status</th>
                  <th>Scheduled Date</th>
                  <th>Assigned Janitor</th>
                  <th>Action</th>
                </tr>
              </thead>
              <tbody>
                <% for (CleaningTask t : allTasks) {
                     String sc = "status-pending";
                     String sl = "Pending";
                     if (t.getStatus() == CleaningTask.Status.completed)   { sc = "status-completed"; sl = "Completed"; }
                     else if (t.getStatus() == CleaningTask.Status.in_progress) { sc = "status-progress";  sl = "In Progress"; }
                     else if (t.getStatus() == CleaningTask.Status.skipped) { sc = "status-skipped";   sl = "Skipped"; }
                %>
                <tr>
                  <td><strong><%= t.getFacilityName() %></strong></td>
                  <td><span class="<%= sc %>"><%= sl %></span></td>
                  <td><%= t.getScheduledDate() %></td>
                  <td><%= t.getAssignedToName() != null ? t.getAssignedToName() : "Unassigned" %></td>
                  <td>
                    <button class="btn-reassign"
                      data-task-id="<%= t.getId() %>"
                      data-office-name="<%= t.getFacilityName() %>"
                      data-current-janitor="<%= t.getAssignedToName() != null ? t.getAssignedToName() : "" %>">
                      <i class="bi bi-arrow-repeat"></i> Reassign
                    </button>
                  </td>
                </tr>
                <% } %>
              </tbody>
            </table>
          </div>
          <% } %>
        </div>
      </div>

      <!-- Janitor Staff Section -->
      <div id="staffSection" style="display:none;">
        <% if (janitors.isEmpty()) { %>
        <div class="text-center py-5 text-muted">No janitors found</div>
        <% } else { %>
        <div class="row">
          <% for (User j : janitors) {
               String initial = j.getName() != null && j.getName().length() > 0
                   ? String.valueOf(j.getName().charAt(0)).toUpperCase() : "J";
               long jCompleted = 0, jTotal = 0;
               for (CleaningTask t : allTasks) {
                   if (j.getName() != null && j.getName().equals(t.getAssignedToName())) {
                       jTotal++;
                       if (t.getStatus() == CleaningTask.Status.completed) jCompleted++;
                   }
               }
               int jPct = jTotal > 0 ? (int)((jCompleted * 100) / jTotal) : 0;
          %>
          <div class="col-md-4 mb-3">
            <div class="janitor-card">
              <div class="d-flex align-items-center gap-3">
                <div class="janitor-avatar"><%= initial %></div>
                <div>
                  <h6 class="mb-0"><%= j.getName() %></h6>
                  <small class="text-muted"><%= j.getEmail() %></small>
                </div>
              </div>
              <div class="mt-3">
                <div class="d-flex justify-content-between mb-1">
                  <small>Task Completion</small>
                  <small><%= jCompleted %>/<%= jTotal %></small>
                </div>
                <div class="janitor-progress">
                  <div class="janitor-progress-fill" style="width:<%= jPct %>%"></div>
                </div>
              </div>
            </div>
          </div>
          <% } %>
        </div>
        <% } %>
      </div>

      <!-- Dispute Reports Section -->
      <div id="reportsSection" style="display:none;">
        <div class="table-container">
          <h5><i class="bi bi-flag text-success"></i> Lecturer Reports</h5>
          <p class="text-muted small mb-3">Reports filed by lecturers rating the quality of cleaning tasks</p>
          <% if (lecturerReports.isEmpty()) { %>
          <div class="text-center py-4 text-muted">No reports submitted by lecturers yet</div>
          <% } else { %>
          <div class="table-responsive">
            <table class="table table-custom align-middle">
              <thead>
                <tr>
                  <th>Office / Facility</th>
                  <th>Janitor</th>
                  <th>Submitted By</th>
                  <th>Rating</th>
                  <th>Report</th>
                  <th>Date</th>
                </tr>
              </thead>
              <tbody>
                <% for (LecturerReport r : lecturerReports) { %>
                <tr>
                  <td><strong><%= r.getTaskFacilityName() %></strong></td>
                  <td>
                    <%
                      String janitorName = "N/A";
                      for (CleaningTask t : allTasks) {
                          if (t.getId() == r.getTaskId()) {
                              janitorName = t.getAssignedToName() != null ? t.getAssignedToName() : "N/A";
                              break;
                          }
                      }
                    %>
                    <%= janitorName %>
                  </td>
                  <td><%= r.getLecturerName() %></td>
                  <td>
                    <% for (int s = 1; s <= 5; s++) { %>
                    <i class="bi bi-star<%= s <= r.getRating() ? "-fill" : "" %>"
                       style="color:<%= s <= r.getRating() ? "#f5a623" : "#ccc" %>; font-size:0.9rem;"></i>
                    <% } %>
                    <small class="ms-1 text-muted">(<%= r.getRating() %>/5)</small>
                  </td>
                  <td style="max-width:280px;"><%= r.getReportText() %></td>
                  <td class="text-muted small"><%= r.getCreatedAt() != null ? r.getCreatedAt().toLocalDate() : "" %></td>
                </tr>
                <% } %>
              </tbody>
            </table>
          </div>
          <% } %>
        </div>
      </div>

    </div>
  </div>
</div>

<!-- Reassign Modal -->
<div class="modal fade modal-custom" id="reassignModal" tabindex="-1">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title"><i class="bi bi-arrow-repeat"></i> Reassign Task</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <p>Reassign <strong id="reassignOfficeName"></strong> to:</p>
        <select id="reassignJanitorSelect" class="form-select">
          <% for (User j : janitors) { %>
          <option value="<%= j.getName() %>"><%= j.getName() %></option>
          <% } %>
        </select>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="button" class="btn btn-primary" id="confirmReassignBtn">Reassign</button>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    let currentTaskId = null;

    function showToast(message, type) {
        const toastDiv = document.createElement('div');
        toastDiv.className = 'custom-toast';
        toastDiv.style.backgroundColor = type === 'success' ? '#00A651' : (type === 'error' ? '#dc3545' : '#17a2b8');
        toastDiv.style.color = 'white';
        const icon = type === 'success' ? '<i class="bi bi-check-circle-fill"></i>' :
                     type === 'error'   ? '<i class="bi bi-exclamation-triangle-fill"></i>' :
                                          '<i class="bi bi-info-circle-fill"></i>';
        toastDiv.innerHTML = icon + '<span>' + message + '</span>';
        document.body.appendChild(toastDiv);
        setTimeout(() => { toastDiv.style.animation = 'slideOut 0.3s ease'; setTimeout(() => toastDiv.remove(), 300); }, 3000);
        toastDiv.onclick = () => { toastDiv.style.animation = 'slideOut 0.3s ease'; setTimeout(() => toastDiv.remove(), 300); };
    }

    function openReassignModal(btn) {
        currentTaskId = btn.getAttribute('data-task-id');
        const officeName     = btn.getAttribute('data-office-name');
        const currentJanitor = btn.getAttribute('data-current-janitor');
        document.getElementById('reassignOfficeName').textContent = officeName;
        const select = document.getElementById('reassignJanitorSelect');
        if (select && currentJanitor) select.value = currentJanitor;
        new bootstrap.Modal(document.getElementById('reassignModal')).show();
    }

    function confirmReassign() {
        const newJanitor = document.getElementById('reassignJanitorSelect').value;
        showToast('Reassigned to ' + newJanitor, 'success');
        bootstrap.Modal.getInstance(document.getElementById('reassignModal')).hide();
    }

    // Wire up reassign buttons via event delegation (no inline onclick)
    document.addEventListener('click', e => {
        const btn = e.target.closest('.btn-reassign');
        if (btn) openReassignModal(btn);
    });

    document.getElementById('confirmReassignBtn').addEventListener('click', confirmReassign);

    // Section navigation (driven by sidebar data-section links)
    document.querySelectorAll('.nav-link-custom[data-section]').forEach(link => {
        link.addEventListener('click', e => {
            e.preventDefault();
            const section = link.getAttribute('data-section');
            document.querySelectorAll('.nav-link-custom').forEach(l => l.classList.remove('active'));
            link.classList.add('active');
            document.getElementById('dashboardSection').style.display = section === 'dashboard' ? 'block' : 'none';
            document.getElementById('monitorSection').style.display   = section === 'monitor'   ? 'block' : 'none';
            document.getElementById('staffSection').style.display     = section === 'staff'     ? 'block' : 'none';
            document.getElementById('reportsSection').style.display   = section === 'reports'   ? 'block' : 'none';
        });
    });

    window.confirmReassign = confirmReassign;
</script>
</body>
</html>
