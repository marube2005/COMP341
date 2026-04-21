<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartcampus.model.*,java.util.*,java.time.*" %>
<%
    request.setAttribute("activePage", "dashboard");
    User currentUser = (User) session.getAttribute("loggedInUser");
    String ctx = request.getContextPath();
    String firstName = (currentUser.getName() != null && !currentUser.getName().isEmpty())
                       ? currentUser.getName().split(" ")[0] : "Lecturer";

    Facility assignedOffice = (Facility) request.getAttribute("assignedOffice");
    Boolean checkedInAttr   = (Boolean) request.getAttribute("checkedInToday");
    boolean checkedInToday  = Boolean.TRUE.equals(checkedInAttr);
    Boolean workingDayAttr  = (Boolean) request.getAttribute("workingDay");
    boolean workingDay      = workingDayAttr == null || Boolean.TRUE.equals(workingDayAttr);
    String calendarNotice    = (String) request.getAttribute("calendarNotice");
    @SuppressWarnings("unchecked")
    List<CleaningTask> officeTasks = (List<CleaningTask>) request.getAttribute("officeTasks");
    if (officeTasks == null) officeTasks = Collections.emptyList();
    @SuppressWarnings("unchecked")
    Map<Integer, List<TaskActivity>> activitiesMap = (Map<Integer, List<TaskActivity>>) request.getAttribute("activitiesMap");
    if (activitiesMap == null) activitiesMap = Collections.emptyMap();

    String checkinParam = request.getParameter("checkin");
%>
  <%!
    private String escAttr(String value) {
      if (value == null) return "";
      return value.replace("&", "&amp;")
            .replace("\"", "&quot;")
            .replace("<", "&lt;")
            .replace(">", "&gt;");
    }
  %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="ctx" content="<%= request.getContextPath() %>">
    <title>Lecturer Dashboard | SmartCampus - Egerton University</title>
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

        .info-card { background: var(--card-white); border-radius: 20px; padding: 1.2rem;
                     box-shadow: 0 2px 8px rgba(0,0,0,0.04); border: 1px solid var(--border-color);
                     transition: transform 0.2s; text-align: center; }
        .info-card:hover { transform: translateY(-3px); }
        .info-icon { width: 56px; height: 56px;
                     background: linear-gradient(135deg, rgba(0,166,81,0.1), rgba(210,172,103,0.1));
                     border-radius: 18px; display: flex; align-items: center; justify-content: center;
                     margin: 0 auto 0.8rem; }
        .info-icon i { font-size: 1.8rem; color: var(--egerton-green); }
        .info-card h3 { font-size: 1.5rem; font-weight: 700; margin-bottom: 0.25rem; }
        .info-card p { color: var(--text-muted); font-size: 0.75rem; margin-bottom: 0; }

        .intensity-high { background: var(--high-intensity-bg); color: var(--high-intensity-color);
                          padding: 6px 16px; border-radius: 30px; font-size: 0.8rem; font-weight: 600; display: inline-block; }
        .intensity-low  { background: var(--low-intensity-bg);  color: var(--low-intensity-color);
                          padding: 6px 16px; border-radius: 30px; font-size: 0.8rem; font-weight: 600; display: inline-block; }

        .checkin-card { background: linear-gradient(135deg, var(--egerton-green), var(--egerton-green-dark));
                        border-radius: 20px; padding: 1.2rem; color: white; margin-bottom: 1.5rem; }
        .btn-checkin { background: white; color: var(--egerton-green); border: none; padding: 8px 24px;
                       border-radius: 40px; font-weight: 600; font-size: 0.85rem; transition: all 0.2s; }
        .btn-checkin:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
        .btn-checkin:disabled { opacity: 0.6; cursor: not-allowed; }

        .tasks-container { background: var(--card-white); border-radius: 20px; padding: 1.5rem;
                           box-shadow: 0 2px 8px rgba(0,0,0,0.04); border: 1px solid var(--border-color); }
        .tasks-header { border-bottom: 2px solid var(--border-color); padding-bottom: 0.8rem; margin-bottom: 1.2rem; }
        .tasks-header h5 { font-weight: 700; color: var(--text-dark); }

        .task-item { display: flex; align-items: center; gap: 12px; padding: 12px 0;
                     border-bottom: 1px solid var(--border-color); transition: all 0.2s; }
        .task-item:last-child { border-bottom: none; }
        .task-checkbox { width: 22px; height: 22px; cursor: pointer; accent-color: var(--egerton-green); }
        .task-checkbox:disabled { cursor: not-allowed; opacity: 0.5; }
        .task-content { flex: 1; }
        .task-title  { font-weight: 600; color: var(--text-dark); font-size: 0.9rem; margin-bottom: 0; }
        .task-status { font-size: 0.7rem; color: var(--text-muted); }

        .task-review-card { background: #f8fafc; border: 1px solid var(--border-color); border-radius: 16px; padding: 1rem; }
        .review-panel { background: white; border: 1px dashed var(--border-color); border-radius: 16px; padding: 1rem; }
        .review-panel textarea, .review-panel input { border-radius: 12px; }
        .task-star-icon { font-size: 1.4rem; cursor: pointer; color: #ccc; transition: color 0.15s, transform 0.15s; }
        .task-star-icon:hover { transform: translateY(-1px); }
        .task-star-icon.active { color: #f0a500; }
        .activity-status-note { font-size: 0.75rem; color: var(--text-muted); }
        .activity-toggle-disabled { cursor: not-allowed; opacity: 0.72; }
        .deadline-badge { background: #fee2e2; color: #b91c1c; border-radius: 999px; padding: 0.25rem 0.65rem; font-size: 0.75rem; font-weight: 700; }

        .report-btn { background: none; border: none; color: #dc3545; font-size: 0.7rem;
                      cursor: pointer; padding: 4px 8px; border-radius: 20px; transition: all 0.2s; }
        .report-btn:hover { background: #fee2e2; }

        @keyframes slideIn  { from { transform: translateX(100%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
        @keyframes slideOut { from { transform: translateX(0); opacity: 1; } to { transform: translateX(100%); opacity: 0; } }
        .custom-toast { position: fixed; bottom: 20px; right: 20px; padding: 12px 20px; border-radius: 12px;
                        font-size: 0.85rem; font-weight: 500; z-index: 9999; animation: slideIn 0.3s ease;
                        cursor: pointer; display: flex; align-items: center; gap: 8px; }

        .modal-custom .modal-content { border-radius: 24px; border: none; }
        .modal-custom .modal-header { background: linear-gradient(135deg, var(--egerton-green-dark), var(--egerton-green));
                                      color: white; border-radius: 24px 24px 0 0; }

        @media (max-width: 767.98px) {
            .main-content { padding: 1rem; }
            .welcome-header h1 { font-size: 1.3rem; }
            .info-card { padding: 1rem; }
            .tasks-container { padding: 1rem; border-radius: 14px; }
            .checkin-card { padding: 1rem; }
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
            <p>Lecturer Dashboard — Your Office</p>
          </div>
          <span class="badge bg-light text-dark p-2 shadow-sm">
            <i class="bi bi-person-circle"></i> <%= currentUser.getEmail() %>
          </span>
        </div>

        <!-- Info Cards -->
        <div class="row mb-4">
          <div class="col-md-6">
            <div class="info-card">
              <div class="info-icon"><i class="bi bi-building"></i></div>
              <h3><%= assignedOffice != null ? assignedOffice.getName() : "—" %></h3>
              <p>My Assigned Office</p>
            </div>
          </div>
          <div class="col-md-6">
            <div class="info-card">
              <div class="info-icon"><i class="bi bi-droplet"></i></div>
              <% if (checkedInToday) { %>
              <span class="intensity-high">High Intensity</span>
              <% } else { %>
              <span class="intensity-low">Low Intensity</span>
              <% } %>
              <p>Cleaning Intensity</p>
            </div>
          </div>
        </div>

        <% if ("no_office".equals(checkinParam)) { %>
        <div class="alert alert-warning alert-dismissible fade show">
          <i class="bi bi-exclamation-triangle-fill me-2"></i>
          You have no assigned office. Please contact the administrator.
          <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } else if ("weekend".equals(checkinParam) || "holiday".equals(checkinParam)) { %>
        <div class="alert alert-info alert-dismissible fade show">
          <i class="bi bi-info-circle-fill me-2"></i>
          <%= calendarNotice != null && !calendarNotice.isEmpty() ? calendarNotice : "Today is not a working day." %>
          <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } else if ("error".equals(checkinParam)) { %>
        <div class="alert alert-danger alert-dismissible fade show">
          <i class="bi bi-exclamation-triangle-fill me-2"></i>
          Check-in failed. Please try again.
          <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <!-- Check-in Card -->
        <div class="checkin-card">
          <div class="row align-items-center">
            <div class="col-8">
              <i class="bi bi-check2-circle"></i>
              <h4 class="mt-2">Daily Check-in</h4>
              <% if (!workingDay) { %>
              <p><%= calendarNotice != null && !calendarNotice.isEmpty() ? calendarNotice : "Today is not a working day." %></p>
              <% } else if (checkedInToday) { %>
              <p>&#x2705; You have checked in today — full cleaning scheduled for your office.</p>
              <% } else if (assignedOffice == null) { %>
              <p>No office assigned. Contact admin to assign an office.</p>
              <% } else { %>
              <p>&#x2713; Not checked in — only dusting will be performed in your office today.</p>
              <% } %>
            </div>
            <div class="col-4 text-end">
              <% if (workingDay && !checkedInToday && assignedOffice != null) { %>
              <form method="post" action="<%= ctx %>/lecturer/checkin" style="display:inline;">
                <button type="submit" class="btn-checkin">
                  <i class="bi bi-calendar-check"></i> Check In
                </button>
              </form>
              <% } else if (checkedInToday) { %>
              <button class="btn-checkin" disabled>
                <i class="bi bi-check-circle"></i> Checked In
              </button>
              <% } else if (!workingDay) { %>
              <button class="btn-checkin" disabled>
                <i class="bi bi-calendar-x"></i> Closed Today
              </button>
              <% } %>
            </div>
          </div>
        </div>

        <!-- Today's Cleaning Tasks -->
        <div class="tasks-container">
          <div class="tasks-header d-flex justify-content-between align-items-center gap-2 flex-wrap">
            <div>
              <h5 class="mb-1"><i class="bi bi-brush text-success"></i> Today's Cleaning Tasks</h5>
              <p class="text-muted small mb-0">Uncheck a completed item to notify the supervisor.</p>
            </div>
            <% if (!workingDay) { %>
            <span class="intensity-low">Closed Today</span>
            <% } else if (checkedInToday) { %>
            <span class="intensity-high">High Intensity (All Activities)</span>
            <% } else { %>
            <span class="intensity-low">Low Intensity (Dusting Only)</span>
            <% } %>
          </div>
          <% if (assignedOffice == null) { %>
          <p class="text-center text-muted py-4">No office assigned. Contact admin.</p>
          <% } else if (!workingDay) { %>
          <p class="text-muted small mb-2">
            <i class="bi bi-info-circle text-warning"></i>
            <%= calendarNotice != null && !calendarNotice.isEmpty() ? calendarNotice : "Today is not a working day." %>
            Cleaning will resume on the next working day.
          </p>
          <div class="alert alert-light border text-muted mb-0">
            Office access is closed today, so no check-in or cleaning activity is scheduled.
          </div>
          <% } else if (officeTasks == null || officeTasks.isEmpty()) { %>
          <div class="alert alert-light border text-muted mb-0">
            No cleaning task has been scheduled yet for <strong><%= assignedOffice.getName() %></strong>.
          </div>
          <% } else { %>
          <p class="text-muted small mb-2">
            <i class="bi bi-info-circle text-success"></i>
            <% if (checkedInToday) { %>
            You have checked in. Full cleaning has been scheduled for <strong><%= assignedOffice.getName() %></strong>.
            <% } else { %>
            You have not checked in. Only dusting is scheduled for <strong><%= assignedOffice.getName() %></strong> today.
            <% } %>
          </p>

          <% for (CleaningTask task : officeTasks) {
               List<TaskActivity> activities = activitiesMap.getOrDefault(task.getId(), Collections.emptyList());
               boolean deadlinePassed = task.getScheduledDate() != null
                       && task.getScheduledDate().isEqual(LocalDate.now())
                       && LocalTime.now().isAfter(LocalTime.of(8, 0))
                       && task.getStatus() != CleaningTask.Status.completed;
               String taskLabel = (assignedOffice.getName() != null && !assignedOffice.getName().isEmpty())
                                  ? assignedOffice.getName() : ("Task #" + task.getId());
          %>
          <div class="task-review-card mb-3" data-task-id="<%= task.getId() %>">
            <div class="d-flex justify-content-between align-items-start gap-2 mb-2">
              <div>
                <strong><%= taskLabel %></strong>
                <div class="task-status">Scheduled for <%= task.getScheduledDate() %></div>
              </div>
              <div class="d-flex align-items-center gap-2 flex-wrap justify-content-end">
                <% if (deadlinePassed) { %>
                <span class="deadline-badge">Past 8:00 AM deadline</span>
                <% } %>
                <button type="button"
                        class="btn btn-outline-danger btn-sm report-btn"
                        data-task-id="<%= task.getId() %>"
                        data-task-name="<%= escAttr(taskLabel) %>"
                        onclick="openReportPanel(this)">
                  <i class="bi bi-flag me-1"></i> Report
                </button>
              </div>
            </div>

            <div class="activity-list">
              <% for (TaskActivity act : activities) {
                   boolean done = act.isDone();
              %>
              <div class="task-item<%= done ? " done" : "" %>">
                <input type="checkbox"
                       class="task-checkbox"
                       <%= done ? "checked" : "" %>
                       <%= done ? "" : "disabled" %>
                       data-task-id="<%= task.getId() %>"
                       data-task-name="<%= escAttr(taskLabel) %>"
                       data-activity-name="<%= escAttr(act.getActivity()) %>"
                       onchange="handleActivityToggle(this)">
                <div class="task-content">
                  <p class="task-title"><%= act.getActivity() %></p>
                  <div class="task-status">
                    <%= done ? "Completed by janitor" : "Awaiting janitor" %>
                  </div>
                </div>
                <% if (done) { %>
                <button type="button"
                        class="report-btn"
                        data-task-id="<%= task.getId() %>"
                        data-task-name="<%= escAttr(taskLabel) %>"
                        data-activity-name="<%= escAttr(act.getActivity()) %>"
                        onclick="openReportPanel(this)">
                  Report
                </button>
                <% } else { %>
                <span class="activity-status-note">Locked until janitor completes it</span>
                <% } %>
              </div>
              <% } %>
            </div>

            <div class="review-panel mt-3 d-none" id="reportPanel-<%= task.getId() %>">
              <div class="d-flex justify-content-between align-items-center gap-2 mb-2">
                <div>
                  <strong class="small">Supervisor report</strong>
                  <div class="activity-status-note" id="reportTarget-<%= task.getId() %>">Select a completed item to report dissatisfaction.</div>
                </div>
                <span class="review-pill">5-star rating</span>
              </div>
              <div class="mb-3">
                <label class="form-label fw-semibold small">Cleaning quality rating</label>
                <div class="d-flex gap-1 align-items-center task-star-group" data-task-id="<%= task.getId() %>">
                  <% for (int s = 1; s <= 5; s++) { %>
                  <i class="bi bi-star-fill task-star-icon<%= s == 5 ? " active" : "" %>"
                     data-value="<%= s %>"
                     title="<%= s %> star<%= s > 1 ? "s" : "" %>"></i>
                  <% } %>
                  <small class="text-muted ms-2" id="ratingLabel-<%= task.getId() %>">Select a rating</small>
                </div>
                <input type="hidden" id="reportRating-<%= task.getId() %>" value="5">
              </div>
              <div class="mb-3">
                <label class="form-label fw-semibold small">Reason for dissatisfaction</label>
                <textarea class="form-control" id="reportReason-<%= task.getId() %>" rows="3"
                          placeholder="Explain what was not completed properly..." required></textarea>
              </div>
              <div class="mb-3">
                <label class="form-label fw-semibold small">Additional notes</label>
                <input type="text" class="form-control" id="reportNotes-<%= task.getId() %>" placeholder="Optional details for the supervisor">
              </div>
              <div class="d-flex justify-content-end gap-2">
                <button type="button" class="btn btn-outline-secondary btn-sm" onclick="closeReportPanel(<%= task.getId() %>)">Cancel</button>
                <button type="button" class="btn btn-primary btn-sm" onclick="submitTaskReport(<%= task.getId() %>)">Send Report</button>
              </div>
            </div>
          </div>
          <% } %>
        </div>
        <% } %>
      </div>

      <!-- Reports Section -->
      <div id="reportsSection" style="display:none;">
        <div class="tasks-container">
          <div class="tasks-header">
            <h5><i class="bi bi-flag text-success"></i> My Dissatisfaction Reports</h5>
            <p class="text-muted small">Reports sent to the supervisor when you flag completed work</p>
          </div>
          <div id="reportsList"></div>
        </div>
      </div>

    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    let reports = [];

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

    function escapeHtml(text) {
      return String(text || '')
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
    }

    function updateTaskStars(taskId, value) {
      const stars = document.querySelectorAll('.task-star-group[data-task-id="' + taskId + '"] .task-star-icon');
      const labels = ['', 'Poor', 'Fair', 'Average', 'Good', 'Excellent'];
      stars.forEach(star => {
        const active = parseInt(star.dataset.value) <= value;
        star.classList.toggle('active', active);
      });
      const label = document.getElementById('ratingLabel-' + taskId);
      if (label) label.textContent = value ? labels[value] + ' (' + value + '/5)' : 'Select a rating';
    }

    document.querySelectorAll('.task-star-group').forEach(group => {
      const taskId = group.dataset.taskId;
      group.querySelectorAll('.task-star-icon').forEach(star => {
        star.addEventListener('click', () => {
          const val = parseInt(star.dataset.value);
          document.getElementById('reportRating-' + taskId).value = val;
          updateTaskStars(taskId, val);
        });
        star.addEventListener('mouseover', () => updateTaskStars(taskId, parseInt(star.dataset.value)));
        star.addEventListener('mouseout', () => updateTaskStars(taskId, parseInt(document.getElementById('reportRating-' + taskId).value) || 5));
      });
      updateTaskStars(taskId, parseInt(document.getElementById('reportRating-' + taskId).value) || 5);
    });

    function openReportPanel(trigger) {
      const taskId = trigger.getAttribute('data-task-id');
      const taskName = trigger.getAttribute('data-task-name') || '';
      const activityName = trigger.getAttribute('data-activity-name') || '';
      const panel = document.getElementById('reportPanel-' + taskId);
      const target = document.getElementById('reportTarget-' + taskId);
      if (panel) {
        panel.dataset.taskName = taskName;
        panel.dataset.activityName = activityName;
      }
      if (target) {
        target.textContent = activityName
          ? 'Reporting "' + activityName + '" for ' + taskName
          : 'Reporting cleaning work for ' + taskName;
      }
      if (panel) {
        panel.classList.remove('d-none');
        panel.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }
    }

    function closeReportPanel(taskId) {
      const panel = document.getElementById('reportPanel-' + taskId);
      if (panel) panel.classList.add('d-none');
    }

    function handleActivityToggle(checkbox) {
      if (checkbox.checked) return;
      openReportPanel(checkbox);
    }

    function submitTaskReport(taskId) {
      const panel = document.getElementById('reportPanel-' + taskId);
      const taskName = panel?.dataset.taskName || document.querySelector('.task-checkbox[data-task-id="' + taskId + '"]')?.dataset.taskName || '';
      const activityName = panel?.dataset.activityName || '';
      const rating = parseInt(document.getElementById('reportRating-' + taskId).value) || 5;
      const reason = document.getElementById('reportReason-' + taskId).value.trim();
      const notes = document.getElementById('reportNotes-' + taskId).value.trim();
      if (!reason) { showToast('Please provide a reason for your dissatisfaction', 'error'); return; }

      const submitBtn = document.querySelector('#reportPanel-' + taskId + ' button.btn-primary');
      if (submitBtn) submitBtn.disabled = true;

      const params = new URLSearchParams({ taskName, activityName, rating, reason, notes });
      fetch(window.location.origin + document.querySelector('meta[name="ctx"]').content + '/lecturer/report', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params.toString()
      })
      .then(r => r.json())
      .then(data => {
        if (submitBtn) submitBtn.disabled = false;
        if (data.success) {
          reports.unshift({ taskName, activityName, rating, reason, notes,
                    date: new Date().toLocaleString(), status: 'Submitted' });
          showToast('Report sent to supervisor regarding "' + (activityName || taskName) + '"', 'info');
          closeReportPanel(taskId);
          renderReports();
        } else {
          showToast(data.message || 'Failed to submit report', 'error');
        }
      })
      .catch(() => {
        if (submitBtn) submitBtn.disabled = false;
        showToast('Network error. Please try again.', 'error');
      });
    }

    function renderReports() {
        const container = document.getElementById('reportsList');
        if (!container) return;
        if (reports.length === 0) {
            container.innerHTML = '<p class="text-center text-muted py-4">No reports submitted yet</p>';
            return;
        }
        container.innerHTML = '';
        reports.forEach(report => {
            const stars = Array.from({ length: 5 }, (_, i) => {
              const active = i < (report.rating || 5);
              return '<i class="bi bi-star' + (active ? '-fill' : '') + '" style="color:' + (active ? '#f0a500' : '#ccc') + ';font-size:0.9rem;"></i>';
            }).join('');
            const activityLine = report.activityName
              ? '<p class="text-muted small mb-1"><strong>Activity:</strong> ' + escapeHtml(report.activityName) + '</p>'
              : '';
            const notesLine = report.notes
              ? '<p class="text-muted small"><strong>Notes:</strong> ' + escapeHtml(report.notes) + '</p>'
              : '';
            const div = document.createElement('div');
            div.className = 'task-item';
            div.innerHTML = '' +
                '<div class="task-content">' +
                '<p class="task-title"><strong>' + escapeHtml(report.taskName) + '</strong> - ' + escapeHtml(report.date) + '</p>' +
                '<p class="text-muted small mb-1">' + stars + '</p>' +
                activityLine +
                '<p class="text-muted small mb-1"><strong>Reason:</strong> ' + escapeHtml(report.reason) + '</p>' +
                notesLine +
                '<span class="badge bg-warning text-dark">' + escapeHtml(report.status) + '</span>' +
                '</div>';
            container.appendChild(div);
        });
    }

    // Sidebar section navigation (Dashboard / Reports)
    document.querySelectorAll('.nav-link-custom[data-section]').forEach(link => {
        link.addEventListener('click', e => {
            e.preventDefault();
            const section = link.getAttribute('data-section');
            document.querySelectorAll('.nav-link-custom').forEach(l => l.classList.remove('active'));
            link.classList.add('active');
            document.getElementById('dashboardSection').style.display = section === 'dashboard' ? 'block' : 'none';
            document.getElementById('reportsSection').style.display   = section === 'reports'   ? 'block' : 'none';
            if (section === 'reports') renderReports();
        });
    });

    renderReports();
</script>
</body>
</html>
