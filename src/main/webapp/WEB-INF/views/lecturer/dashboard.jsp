<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartcampus.model.*,java.util.*" %>
<%
    request.setAttribute("activePage", "dashboard");
    User currentUser = (User) session.getAttribute("loggedInUser");
    String ctx = request.getContextPath();
    String firstName = (currentUser.getName() != null && !currentUser.getName().isEmpty())
                       ? currentUser.getName().split(" ")[0] : "Lecturer";

    @SuppressWarnings("unchecked")
    List<CleaningTask> completedTasks = (List<CleaningTask>) request.getAttribute("completedTasks");
    if (completedTasks == null) completedTasks = Collections.emptyList();

    @SuppressWarnings("unchecked")
    List<LecturerReport> myReports = (List<LecturerReport>) request.getAttribute("myReports");
    if (myReports == null) myReports = Collections.emptyList();

    // Build a set of already-rated task IDs for this lecturer
    Set<Integer> ratedTaskIds = new HashSet<>();
    for (LecturerReport r : myReports) ratedTaskIds.add(r.getTaskId());

    String reportError   = (String) session.getAttribute("reportError");
    String reportSuccess = (String) session.getAttribute("reportSuccess");
    session.removeAttribute("reportError");
    session.removeAttribute("reportSuccess");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
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

        .report-btn { background: none; border: none; color: #dc3545; font-size: 0.7rem;
                      cursor: pointer; padding: 4px 8px; border-radius: 20px; transition: all 0.2s; }
        .report-btn:hover { background: #fee2e2; }

        .star-rating { display: flex; gap: 4px; flex-direction: row-reverse; justify-content: flex-end; }
        .star-rating input { display: none; }
        .star-rating label { font-size: 1.6rem; color: #ccc; cursor: pointer; transition: color 0.15s; }
        .star-rating input:checked ~ label,
        .star-rating label:hover,
        .star-rating label:hover ~ label { color: #f5a623; }
        .star-filled { color: #f5a623; }

        .rate-btn { background: var(--egerton-green); color: white; border: none;
                    padding: 4px 14px; border-radius: 20px; font-size: 0.75rem; font-weight: 600;
                    cursor: pointer; transition: all 0.2s; }
        .rate-btn:hover { background: var(--egerton-green-dark); }

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
              <h3><%= currentUser.getStaffId() != null ? currentUser.getStaffId() : "—" %></h3>
              <p>My Office</p>
            </div>
          </div>
          <div class="col-md-6">
            <div class="info-card">
              <div class="info-icon"><i class="bi bi-droplet"></i></div>
              <div id="intensityDisplay"></div>
              <p>Cleaning Intensity</p>
            </div>
          </div>
        </div>

        <!-- Check-in Card -->
        <div class="checkin-card">
          <div class="row align-items-center">
            <div class="col-8">
              <i class="bi bi-check2-circle"></i>
              <h4 class="mt-2">Daily Check-in</h4>
              <p id="checkinMessage"></p>
            </div>
            <div class="col-4 text-end">
              <button class="btn-checkin" id="checkinBtn">
                <i class="bi bi-calendar-check"></i> Check In
              </button>
            </div>
          </div>
        </div>

        <!-- Today's Cleaning Tasks -->
        <div class="tasks-container">
          <div class="tasks-header d-flex justify-content-between align-items-center">
            <h5><i class="bi bi-brush text-success"></i> Today's Cleaning Tasks</h5>
            <span id="tasksHeaderBadge"></span>
          </div>
          <div id="tasksList"></div>
          <div class="mt-3 pt-2 text-center" id="taskProgress"></div>
        </div>
      </div>

      <!-- Reports Section (JS-based local reports) -->
      <div id="reportsSection" style="display:none;">
        <div class="tasks-container">
          <div class="tasks-header">
            <h5><i class="bi bi-flag text-success"></i> My Submitted Reports</h5>
            <p class="text-muted small">Reports you have submitted to the supervisor</p>
          </div>
          <% if (myReports.isEmpty()) { %>
          <div class="text-center py-4 text-muted">No reports submitted yet</div>
          <% } else {
               for (LecturerReport r : myReports) { %>
          <div class="task-item">
            <div class="task-content">
              <div class="d-flex justify-content-between align-items-center mb-1">
                <strong><%= r.getTaskFacilityName() %></strong>
                <span class="text-muted small"><%= r.getCreatedAt() != null ? r.getCreatedAt().toLocalDate() : "" %></span>
              </div>
              <div class="mb-1">
                <% for (int s = 1; s <= 5; s++) { %>
                <i class="bi bi-star<%= s <= r.getRating() ? "-fill star-filled" : "" %>"></i>
                <% } %>
                <small class="ms-1 text-muted">(<%= r.getRating() %>/5)</small>
              </div>
              <p class="text-muted small mb-0"><%= r.getReportText() %></p>
            </div>
          </div>
          <% } } %>
        </div>
      </div>

      <!-- Rate Tasks Section -->
      <div id="rateTasksSection" style="display:none;">
        <div class="tasks-container">
          <div class="tasks-header">
            <h5><i class="bi bi-star text-success"></i> Rate Cleaning Tasks</h5>
            <p class="text-muted small">Rate the quality of completed cleaning tasks in your office</p>
          </div>

          <% if (reportError != null) { %>
          <div class="alert alert-danger py-2 small"><%= reportError %></div>
          <% } %>
          <% if (reportSuccess != null) { %>
          <div class="alert alert-success py-2 small"><%= reportSuccess %></div>
          <% } %>

          <% if (completedTasks.isEmpty()) { %>
          <div class="text-center py-4 text-muted">No completed cleaning tasks available to rate</div>
          <% } else {
               for (CleaningTask t : completedTasks) {
                 boolean alreadyRated = ratedTaskIds.contains(t.getId());
          %>
          <div class="task-item d-flex align-items-center gap-3">
            <div class="task-content">
              <div class="d-flex justify-content-between align-items-center mb-1">
                <strong><%= t.getFacilityName() %></strong>
                <small class="text-muted">Completed: <%= t.getScheduledDate() %></small>
              </div>
              <small class="text-muted">Janitor: <%= t.getAssignedToName() != null ? t.getAssignedToName() : "N/A" %></small>
            </div>
            <div>
              <% if (alreadyRated) { %>
              <span class="badge bg-success">Rated</span>
              <% } else { %>
              <button class="rate-btn"
                data-task-id="<%= t.getId() %>"
                data-facility-name="<%= t.getFacilityName() %>"
                data-janitor-name="<%= t.getAssignedToName() != null ? t.getAssignedToName() : "N/A" %>"
                onclick="openRatingModal(this)">
                <i class="bi bi-star"></i> Rate
              </button>
              <% } %>
            </div>
          </div>
          <% } } %>
        </div>
      </div>

    </div>
  </div>
</div>

<!-- Rating Modal -->
<div class="modal fade modal-custom" id="ratingModal" tabindex="-1">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title"><i class="bi bi-star"></i> Rate Cleaning Task</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <form method="post" action="<%= ctx %>/lecturer/report">
        <div class="modal-body">
          <input type="hidden" name="taskId" id="ratingTaskId">
          <div class="mb-3">
            <label class="form-label fw-semibold">Office</label>
            <input type="text" class="form-control" id="ratingFacilityDisplay" readonly>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Janitor</label>
            <input type="text" class="form-control" id="ratingJanitorDisplay" readonly>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Rating</label>
            <div class="star-rating">
              <input type="radio" name="rating" id="star5" value="5"><label for="star5" title="Excellent">&#9733;</label>
              <input type="radio" name="rating" id="star4" value="4"><label for="star4" title="Good">&#9733;</label>
              <input type="radio" name="rating" id="star3" value="3"><label for="star3" title="Average">&#9733;</label>
              <input type="radio" name="rating" id="star2" value="2"><label for="star2" title="Poor">&#9733;</label>
              <input type="radio" name="rating" id="star1" value="1"><label for="star1" title="Very Poor">&#9733;</label>
            </div>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Report / Comments</label>
            <textarea class="form-control" name="reportText" rows="3"
                      placeholder="Describe the cleaning quality, any issues observed..." required></textarea>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
          <button type="submit" class="btn btn-success">Submit Report</button>
        </div>
      </form>
    </div>
  </div>
</div>

<!-- Report Modal -->
<div class="modal fade modal-custom" id="reportModal" tabindex="-1">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title"><i class="bi bi-flag"></i> Report Issue</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <form id="reportForm">
          <input type="hidden" id="reportTaskId">
          <input type="hidden" id="reportTaskName">
          <div class="mb-3">
            <label class="form-label fw-semibold">Task</label>
            <input type="text" class="form-control" id="reportTaskDisplay" readonly>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Reason for Dissatisfaction</label>
            <textarea class="form-control" id="reportReason" rows="3"
                      placeholder="Please explain why you're unsatisfied with this task..." required></textarea>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Additional Notes</label>
            <input type="text" class="form-control" id="reportNotes" placeholder="Any additional comments">
          </div>
        </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="button" class="btn btn-primary" id="submitReportBtn">Submit Report</button>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const lowIntensityTasks  = [{ id: 1, name: "Dusting", completed: false, reported: false }];
    const highIntensityTasks = [
        { id: 1, name: "Mopping",                 completed: false, reported: false },
        { id: 2, name: "Dusting",                 completed: false, reported: false },
        { id: 3, name: "Emptying Bins",            completed: false, reported: false },
        { id: 4, name: "Replenishing Stationery",  completed: false, reported: false }
    ];

    let currentTasks = [];
    let checkedIn = false;
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

    function updateIntensity() {
        const intensityDisplay  = document.getElementById('intensityDisplay');
        const tasksHeaderBadge  = document.getElementById('tasksHeaderBadge');
        if (!checkedIn) {
            intensityDisplay.innerHTML  = '<span class="intensity-low">Low Intensity</span>';
            tasksHeaderBadge.innerHTML  = '<span class="intensity-low">Low Intensity (Dusting Only)</span>';
        } else {
            intensityDisplay.innerHTML  = '<span class="intensity-high">High Intensity</span>';
            tasksHeaderBadge.innerHTML  = '<span class="intensity-high">High Intensity (Full Cleaning - All 4 Tasks)</span>';
        }
    }

    function updateCheckinStatus() {
        const checkinMessage = document.getElementById('checkinMessage');
        const checkinBtn     = document.getElementById('checkinBtn');
        if (checkedIn) {
            const allCompleted = currentTasks.every(t => t.completed);
            checkinMessage.innerHTML = allCompleted
                ? '&#x2705; Checked in — All cleaning tasks completed! Office is now clean.'
                : '&#x2705; Checked in — Office is dirty, intensive cleaning required (All 4 tasks)';
            checkinBtn.innerHTML  = '<i class="bi bi-check-circle"></i> Checked In';
            checkinBtn.disabled   = true;
        } else {
            checkinMessage.innerHTML = '&#x2713; Not checked in — Office is clean, minimal cleaning needed (Dusting only)';
            checkinBtn.innerHTML  = '<i class="bi bi-calendar-check"></i> Check In (Office Dirty)';
            checkinBtn.disabled   = false;
        }
    }

    function renderTasks() {
        const container    = document.getElementById('tasksList');
        const taskProgress = document.getElementById('taskProgress');
        if (!container) return;

        container.innerHTML = '';

        if (!currentTasks || currentTasks.length === 0) {
            container.innerHTML = '<p class="text-center text-muted py-4">No tasks scheduled</p>';
            taskProgress.innerHTML = '';
            return;
        }

        currentTasks.forEach(task => {
            const taskDiv = document.createElement('div');
            taskDiv.className = 'task-item';

            const checkbox = document.createElement('input');
            checkbox.type = 'checkbox';
            checkbox.className = 'task-checkbox';
            checkbox.dataset.id = task.id;
            checkbox.checked  = task.completed;
            checkbox.disabled = !checkedIn;
            taskDiv.appendChild(checkbox);

            const contentDiv = document.createElement('div');
            contentDiv.className = 'task-content';
            const titleP  = document.createElement('p');
            titleP.className = 'task-title';
            titleP.textContent = task.name;
            const statusP = document.createElement('p');
            statusP.className = 'task-status';
            statusP.textContent = task.completed ? 'Completed by Janitor' : 'Pending';
            contentDiv.appendChild(titleP);
            contentDiv.appendChild(statusP);
            taskDiv.appendChild(contentDiv);

            const actionDiv = document.createElement('div');
            if (task.completed) {
                const reportBtn = document.createElement('button');
                reportBtn.className = 'report-btn';
                reportBtn.disabled  = !checkedIn;
                reportBtn.dataset.taskId   = task.id;
                reportBtn.dataset.taskName = task.name;
                reportBtn.innerHTML = '<i class="bi bi-flag"></i> Report Issue';
                actionDiv.appendChild(reportBtn);
            } else {
                const span = document.createElement('span');
                span.className = 'text-muted small';
                span.textContent = 'Awaiting completion';
                actionDiv.appendChild(span);
            }
            taskDiv.appendChild(actionDiv);

            container.appendChild(taskDiv);
        });

        const completedCount = currentTasks.filter(t => t.completed).length;
        const totalCount     = currentTasks.length;
        if (checkedIn) {
            taskProgress.innerHTML = `<small class="text-muted">${completedCount}/${totalCount} tasks completed by janitor</small>`;
            if (completedCount === totalCount) {
                taskProgress.innerHTML += '<br><small class="text-success">\u2713 All cleaning tasks completed! Office is now clean.</small>';
            }
        } else {
            taskProgress.innerHTML = '<small class="text-muted">Office is clean. Check in only when office becomes dirty.</small>';
        }
    }

    function toggleTask(taskId) {
        const task = currentTasks.find(t => t.id === taskId);
        if (task && checkedIn) {
            const newState = !task.completed;
            if (newState === false && task.completed === true) {
                document.querySelector(`.task-checkbox[data-id="${taskId}"]`).checked = true;
                openReportModal(taskId, task.name);
                return;
            }
            task.completed = newState;
            if (newState) showToast('\u2713 ' + task.name + ' marked as completed by janitor!', 'success');
            renderTasks();
            updateCheckinStatus();
            saveState();
        }
    }

    function openReportModal(taskId, taskName) {
        document.getElementById('reportTaskId').value      = taskId;
        document.getElementById('reportTaskName').value    = taskName;
        document.getElementById('reportTaskDisplay').value = taskName;
        document.getElementById('reportReason').value      = '';
        document.getElementById('reportNotes').value       = '';
        new bootstrap.Modal(document.getElementById('reportModal')).show();
    }

    function submitReport() {
        const taskId   = parseInt(document.getElementById('reportTaskId').value);
        const taskName = document.getElementById('reportTaskName').value;
        const reason   = document.getElementById('reportReason').value;
        const notes    = document.getElementById('reportNotes').value;
        if (!reason) { showToast('Please provide a reason for your dissatisfaction', 'error'); return; }

        const task = currentTasks.find(t => t.id === taskId);
        if (task) {
            task.reported = true;
            reports.unshift({ id: Date.now(), taskName, reason, notes, date: new Date().toLocaleString(), status: 'Pending Review' });
            showToast('Report sent to supervisor regarding "' + taskName + '"', 'info');
            bootstrap.Modal.getInstance(document.getElementById('reportModal')).hide();
            saveState();
            renderTasks();
            renderReports();
        }
    }

    function handleCheckIn() {
        if (!checkedIn) {
            checkedIn    = true;
            currentTasks = JSON.parse(JSON.stringify(highIntensityTasks));
            updateIntensity();
            updateCheckinStatus();
            renderTasks();
            showToast('&#x2713; Checked in! High intensity cleaning scheduled (All 4 tasks).', 'success');
            saveState();
        }
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
            const div = document.createElement('div');
            div.className = 'task-item';
            div.innerHTML = `
                <div class="task-content">
                    <p class="task-title"><strong>${report.taskName}</strong> - ${report.date}</p>
                    <p class="text-muted small mb-1"><strong>Reason:</strong> ${report.reason}</p>
                    \${report.notes ? `<p class="text-muted small"><strong>Notes:</strong> ${report.notes}</p>` : ''}
                    <span class="badge bg-warning text-dark">${report.status}</span>
                </div>`;
            container.appendChild(div);
        });
    }

    function loadState() {
        const saved = localStorage.getItem('lecturerDashboardState');
        if (saved) {
            try {
                const state = JSON.parse(saved);
                // Discard state saved more than 24 hours ago
                const savedAt = typeof state.savedAt === 'number' ? state.savedAt : 0;
                if (Date.now() - savedAt > 86400000) throw new Error('expired');
                checkedIn = state.checkedIn === true;
                if (checkedIn) {
                    currentTasks = (Array.isArray(state.currentTasks) && state.currentTasks.length === 4)
                        ? state.currentTasks : JSON.parse(JSON.stringify(highIntensityTasks));
                } else {
                    currentTasks = (Array.isArray(state.currentTasks) && state.currentTasks.length === 1)
                        ? state.currentTasks : JSON.parse(JSON.stringify(lowIntensityTasks));
                }
                reports = Array.isArray(state.reports) ? state.reports : [];
            } catch(e) {
                localStorage.removeItem('lecturerDashboardState');
                checkedIn    = false;
                currentTasks = JSON.parse(JSON.stringify(lowIntensityTasks));
                reports      = [];
            }
        } else {
            checkedIn    = false;
            currentTasks = JSON.parse(JSON.stringify(lowIntensityTasks));
            reports      = [];
        }
        updateIntensity();
        updateCheckinStatus();
        renderTasks();
        renderReports();
    }

    function saveState() {
        localStorage.setItem('lecturerDashboardState',
            JSON.stringify({ checkedIn, currentTasks, reports, savedAt: Date.now() }));
    }

    // Sidebar section navigation (Dashboard / Rate Tasks / Reports)
    document.querySelectorAll('.nav-link-custom[data-section]').forEach(link => {
        link.addEventListener('click', e => {
            e.preventDefault();
            const section = link.getAttribute('data-section');
            document.querySelectorAll('.nav-link-custom').forEach(l => l.classList.remove('active'));
            link.classList.add('active');
            document.getElementById('dashboardSection').style.display  = section === 'dashboard'  ? 'block' : 'none';
            document.getElementById('reportsSection').style.display    = section === 'reports'    ? 'block' : 'none';
            document.getElementById('rateTasksSection').style.display  = section === 'rateTasks'  ? 'block' : 'none';
            if (section === 'reports') renderReports();
        });
    });

    function openRatingModal(btn) {
        document.getElementById('ratingTaskId').value        = btn.getAttribute('data-task-id');
        document.getElementById('ratingFacilityDisplay').value = btn.getAttribute('data-facility-name');
        document.getElementById('ratingJanitorDisplay').value  = btn.getAttribute('data-janitor-name');
        // Reset stars
        document.querySelectorAll('#ratingModal input[name="rating"]').forEach(r => r.checked = false);
        new bootstrap.Modal(document.getElementById('ratingModal')).show();
    }

    // Event delegation for task checkboxes and report buttons
    document.addEventListener('change', e => {
        if (e.target.classList.contains('task-checkbox')) {
            toggleTask(parseInt(e.target.dataset.id));
        }
    });
    document.addEventListener('click', e => {
        const btn = e.target.closest('.report-btn');
        if (btn) openReportModal(parseInt(btn.dataset.taskId), btn.dataset.taskName);
    });

    document.getElementById('checkinBtn').addEventListener('click', handleCheckIn);
    document.getElementById('submitReportBtn').addEventListener('click', submitReport);

    // Auto-open Rate Tasks section if a flash message is present (after form submission)
    <% if (reportError != null || reportSuccess != null) { %>
    document.getElementById('dashboardSection').style.display  = 'none';
    document.getElementById('rateTasksSection').style.display  = 'block';
    <% } %>

    loadState();
</script>
</body>
</html>
