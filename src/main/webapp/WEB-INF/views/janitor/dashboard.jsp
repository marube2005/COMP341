<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartcampus.model.*,com.smartcampus.model.TaskActivity,java.util.*" %>
<%
    request.setAttribute("activePage", "dashboard");
    User currentUser = (User) session.getAttribute("loggedInUser");
    String ctx = request.getContextPath();

    @SuppressWarnings("unchecked")
    List<CleaningTask> myTasks = (List<CleaningTask>) request.getAttribute("myTasks");
    if (myTasks == null) myTasks = Collections.emptyList();

    @SuppressWarnings("unchecked")
    Map<Integer, List<TaskActivity>> activitiesMap =
        (Map<Integer, List<TaskActivity>>) request.getAttribute("activitiesMap");
    if (activitiesMap == null) activitiesMap = Collections.emptyMap();

    int completedCount = 0;
    int pendingCount   = 0;
    for (CleaningTask t : myTasks) {
        if (t.getStatus() == CleaningTask.Status.completed) completedCount++;
        if (t.getStatus() == CleaningTask.Status.pending)   pendingCount++;
    }
    String firstName = (currentUser.getName() != null && !currentUser.getName().isEmpty())
                       ? currentUser.getName().split(" ")[0] : "Janitor";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Janitor Dashboard | SmartCampus - Egerton University</title>
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
            --pending-bg: #fff3e0;
            --pending-color: #e67e22;
            --completed-bg: #e0f2e9;
            --completed-color: #00A651;
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
        .stat-card h3 { font-size: 1.8rem; font-weight: 700; margin-bottom: 0; color: var(--text-dark); }
        .stat-card p { color: var(--text-muted); font-size: 0.75rem; margin-bottom: 0; }

        .office-card { background: var(--card-white); border-radius: 20px; padding: 1.2rem;
                       box-shadow: 0 2px 8px rgba(0,0,0,0.04); border: 1px solid var(--border-color);
                       margin-bottom: 1rem; transition: all 0.2s; }
        .office-card:hover { box-shadow: 0 8px 20px rgba(0,0,0,0.08); }

        .office-header { border-bottom: 2px solid var(--border-color); padding-bottom: 0.8rem; margin-bottom: 1rem; }
        .office-header h4 { font-weight: 700; color: var(--text-dark); margin-bottom: 0.25rem; }
        .office-location { font-size: 0.75rem; color: var(--text-muted); }

        .badge-pending    { background: var(--pending-bg);   color: var(--pending-color);   padding: 4px 10px; border-radius: 20px; font-size: 0.7rem; font-weight: 600; display: inline-block; }
        .badge-completed  { background: var(--completed-bg); color: var(--completed-color); padding: 4px 10px; border-radius: 20px; font-size: 0.7rem; font-weight: 600; display: inline-block; }
        .badge-in_progress { background: #dbeafe; color: #1e40af; padding: 4px 10px; border-radius: 20px; font-size: 0.7rem; font-weight: 600; display: inline-block; }
        .badge-skipped    { background: #f3f4f6; color: #374151; padding: 4px 10px; border-radius: 20px; font-size: 0.7rem; font-weight: 600; display: inline-block; }

        .office-task-row { display: flex; align-items: center; gap: 8px; padding: 8px 0;
                           border-bottom: 1px solid var(--border-color); font-size: 0.875rem; }
        .office-task-row:last-child { border-bottom: none; }
        .office-task-row i { color: var(--egerton-green); width: 18px; }

        .office-actions { margin-top: 1rem; padding-top: 0.8rem; border-top: 1px solid var(--border-color); }

        /* Activity checklist */
        .activity-list { list-style: none; padding: 0; margin: 0.75rem 0 0; }
        .activity-item { display: flex; align-items: center; gap: 10px; padding: 6px 0;
                         border-bottom: 1px solid var(--border-color); font-size: 0.875rem; }
        .activity-item:last-child { border-bottom: none; }
        .activity-item input[type="checkbox"] { width: 18px; height: 18px; cursor: pointer;
                                                accent-color: var(--egerton-green); flex-shrink: 0; }
        .activity-item.done label { text-decoration: line-through; color: var(--text-muted); }
        .activity-item label { cursor: pointer; margin: 0; }

        .filter-buttons { display: flex; gap: 10px; margin-bottom: 20px; }
        .filter-btn { padding: 6px 16px; border-radius: 20px; border: 1px solid var(--border-color);
                      background: white; font-size: 0.8rem; cursor: pointer; transition: all 0.2s; }
        .filter-btn.active { background: var(--egerton-green); color: white; border-color: var(--egerton-green); }
        .filter-btn:hover:not(.active) { border-color: var(--egerton-green); color: var(--egerton-green); }

        .history-card { background: var(--card-white); border-radius: 20px; padding: 1.5rem;
                        box-shadow: 0 2px 8px rgba(0,0,0,0.04); border: 1px solid var(--border-color); }
        .history-item { display: flex; align-items: center; gap: 12px; padding: 12px 0;
                        border-bottom: 1px solid var(--border-color); }
        .history-item:last-child { border-bottom: none; }

        @media (max-width: 767.98px) {
            .main-content { padding: 1rem; }
            .welcome-header h1 { font-size: 1.3rem; }
            .stat-card { padding: 1rem; }
            .office-card { padding: 1rem; }
            .filter-buttons { flex-wrap: wrap; gap: 6px; }
        }
    </style>
</head>
<body>
<div class="container-fluid px-0">
  <div class="row g-0">
    <jsp:include page="/WEB-INF/views/shared/sidebar.jsp"/>

    <div class="col-md-9 col-lg-10 main-content">

      <!-- Dashboard Section -->
      <div id="dashboardSection">

        <!-- Welcome Header -->
        <div class="welcome-header d-flex justify-content-between align-items-center mb-4">
          <div>
            <h1>Welcome, <%= firstName %></h1>
            <p>Janitor Dashboard — Your assigned tasks</p>
          </div>
          <span class="badge bg-light text-dark p-2 shadow-sm">
            <i class="bi bi-person-circle"></i>
            Janitor &nbsp;|&nbsp; <%= currentUser.getEmail() %>
            <% if (currentUser.getStaffId() != null) { %> &nbsp;|&nbsp; ID: <%= currentUser.getStaffId() %><% } %>
          </span>
        </div>

        <!-- Filter Buttons -->
        <div class="filter-buttons">
          <button class="filter-btn active" data-filter="all">All Offices</button>
          <button class="filter-btn" data-filter="pending">Pending Only</button>
          <button class="filter-btn" data-filter="completed">Completed Only</button>
        </div>

        <!-- Stats Cards -->
        <div class="row mb-4">
          <div class="col-md-4 mb-3">
            <div class="stat-card">
              <div class="stat-icon"><i class="bi bi-briefcase"></i></div>
              <h3><%= myTasks.size() %></h3>
              <p>Total Assigned</p>
            </div>
          </div>
          <div class="col-md-4 mb-3">
            <div class="stat-card">
              <div class="stat-icon"><i class="bi bi-check2-circle"></i></div>
              <h3><%= completedCount %></h3>
              <p>Completed</p>
            </div>
          </div>
          <div class="col-md-4 mb-3">
            <div class="stat-card">
              <div class="stat-icon"><i class="bi bi-hourglass-split"></i></div>
              <h3><%= pendingCount %></h3>
              <p>Pending</p>
            </div>
          </div>
        </div>

        <!-- Assigned Offices / Tasks -->
        <div class="d-flex justify-content-between align-items-center mb-3">
          <h5 class="fw-semibold mb-0"><i class="bi bi-building text-success"></i> My Assigned Offices</h5>
        </div>

        <% if (myTasks.isEmpty()) { %>
        <div class="office-card text-center py-5">
          <i class="bi bi-check-circle text-success" style="font-size:2.5rem;"></i>
          <p class="mt-3 text-muted">No cleaning tasks assigned.</p>
        </div>
        <% } else { %>
        <div id="tasksList">
          <% for (CleaningTask t : myTasks) {
               String statusClass = "badge-" + t.getStatus().name();
               String statusLabel = t.getStatus().name().replace("_", " ");
               String facilityLabel = (t.getFacilityName() != null && !t.getFacilityName().isEmpty())
                                      ? t.getFacilityName() : "Office #" + t.getFacilityId();
               List<TaskActivity> activities = activitiesMap.getOrDefault(t.getId(), Collections.emptyList());
               boolean dustOnly = activities.size() == 1;
               int doneCount    = 0;
               for (TaskActivity a : activities) { if (a.isDone()) doneCount++; }
          %>
          <div class="office-card" data-status="<%= t.getStatus().name() %>">
            <div class="office-header">
              <div class="d-flex justify-content-between align-items-start">
                <div>
                  <h4><%= facilityLabel %></h4>
                  <p class="office-location"><i class="bi bi-geo-alt"></i> Facility ID: <%= t.getFacilityId() %></p>
                </div>
                <span class="<%= statusClass %> text-capitalize"><%= statusLabel %></span>
              </div>
            </div>

            <div class="office-tasks">
              <div class="office-task-row">
                <i class="bi bi-calendar-event"></i>
                <span><strong>Scheduled:</strong> <%= t.getScheduledDate() %></span>
              </div>
              <% if (t.getNotes() != null && !t.getNotes().isEmpty()) { %>
              <div class="office-task-row">
                <i class="bi bi-sticky"></i>
                <span><strong>Notes:</strong> <%= t.getNotes() %></span>
              </div>
              <% } %>
            </div>

            <!-- Activity Checklist -->
            <% if (!activities.isEmpty()) { %>
            <div class="mt-3">
              <div class="d-flex justify-content-between align-items-center mb-1">
                <strong class="small"><i class="bi bi-list-check text-success"></i>
                  <%= dustOnly ? "Cleaning Activities (dust only – lecturer not checked in)" : "Cleaning Activities (full clean)" %>
                </strong>
                <span class="small text-muted"><%= doneCount %>/<%= activities.size() %> done</span>
              </div>
              <ul class="activity-list">
                <% for (TaskActivity act : activities) { %>
                <li class="activity-item<%= act.isDone() ? " done" : "" %>">
                  <form method="post" action="<%= ctx %>/cleaning-tasks" style="display:contents;">
                    <input type="hidden" name="action" value="completeActivity">
                    <input type="hidden" name="activityId" value="<%= act.getId() %>">
                    <input type="hidden" name="done" value="<%= act.isDone() ? "false" : "true" %>">
                    <input type="checkbox" id="act<%= act.getId() %>"
                           <%= act.isDone() ? "checked" : "" %>
                           onchange="this.form.submit()">
                    <label for="act<%= act.getId() %>"><%= act.getActivity() %></label>
                  </form>
                </li>
                <% } %>
              </ul>
            </div>
            <% } %>

            <div class="office-actions">
              <form method="post" action="<%= ctx %>/cleaning-tasks" class="d-flex gap-2 align-items-center">
                <input type="hidden" name="action" value="updateStatus">
                <input type="hidden" name="id" value="<%= t.getId() %>">
                <select name="status" class="form-select form-select-sm" style="width:140px;">
                  <option value="pending"     <%= t.getStatus() == CleaningTask.Status.pending     ? "selected" : "" %>>Pending</option>
                  <option value="in_progress" <%= t.getStatus() == CleaningTask.Status.in_progress ? "selected" : "" %>>In Progress</option>
                  <option value="completed"   <%= t.getStatus() == CleaningTask.Status.completed   ? "selected" : "" %>>Completed</option>
                  <option value="skipped"     <%= t.getStatus() == CleaningTask.Status.skipped     ? "selected" : "" %>>Skipped</option>
                </select>
                <button type="submit" class="btn btn-sm btn-success" style="border-radius:40px;padding:6px 18px;font-weight:600;">
                  <i class="bi bi-check2-circle"></i> Update
                </button>
              </form>
            </div>
          </div>
          <% } %>
        </div>
        <% } %>
      </div>

      <!-- Completed History Section -->
      <div id="historySection" style="display:none;">
        <div class="card border-0 shadow-sm rounded-4">
          <div class="card-body p-4">
            <h5 class="fw-semibold mb-1"><i class="bi bi-clock-history text-success"></i> Completed Tasks History</h5>
            <p class="text-muted small mb-3">Records of tasks you've completed</p>
            <% boolean hasCompleted = false;
               for (CleaningTask t : myTasks) {
                 if (t.getStatus() == CleaningTask.Status.completed) { hasCompleted = true; break; }
               }
               if (!hasCompleted) { %>
            <div class="text-center py-5">
              <i class="bi bi-inbox text-muted" style="font-size:2.5rem;"></i>
              <p class="mt-2 text-muted">No completed tasks yet</p>
            </div>
            <% } else {
                 for (CleaningTask t : myTasks) {
                   if (t.getStatus() != CleaningTask.Status.completed) continue;
                   String facilityLabel = (t.getFacilityName() != null && !t.getFacilityName().isEmpty())
                                          ? t.getFacilityName() : "Office #" + t.getFacilityId(); %>
            <div class="history-item">
              <div style="flex:1;">
                <p class="mb-1"><strong><%= facilityLabel %></strong></p>
                <p class="mb-0 small text-muted">Scheduled: <%= t.getScheduledDate() %></p>
              </div>
              <span class="badge-completed"><i class="bi bi-check-circle"></i> Done</span>
            </div>
            <% } } %>
          </div>
        </div>
      </div>

    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Filter buttons
    document.querySelectorAll('.filter-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            const filter = btn.getAttribute('data-filter');
            document.querySelectorAll('#tasksList .office-card').forEach(card => {
                const status = card.getAttribute('data-status');
                card.style.display = (filter === 'all' || status === filter) ? 'block' : 'none';
            });
        });
    });

    // Sidebar section navigation (Dashboard / History)
    document.querySelectorAll('.nav-link-custom[data-section]').forEach(link => {
        link.addEventListener('click', e => {
            e.preventDefault();
            const section = link.getAttribute('data-section');
            document.querySelectorAll('.nav-link-custom').forEach(l => l.classList.remove('active'));
            link.classList.add('active');
            document.getElementById('dashboardSection').style.display = section === 'dashboard' ? 'block' : 'none';
            document.getElementById('historySection').style.display   = section === 'history'   ? 'block' : 'none';
        });
    });
</script>
</body>
</html>
