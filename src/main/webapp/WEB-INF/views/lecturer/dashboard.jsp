<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartcampus.model.*,java.util.*" %>
<%
    request.setAttribute("activePage", "dashboard");
    User currentUser = (User) session.getAttribute("loggedInUser");
    String ctx = request.getContextPath();
    String firstName = (currentUser.getName() != null && !currentUser.getName().isEmpty())
                       ? currentUser.getName().split(" ")[0] : "Lecturer";
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

      <!-- Reports Section -->
      <div id="reportsSection" style="display:none;">
        <div class="tasks-container">
          <div class="tasks-header">
            <h5><i class="bi bi-flag text-success"></i> My Dissatisfaction Reports</h5>
            <p class="text-muted small">Reports sent to supervisor when you uncheck completed tasks</p>
          </div>
          <div id="reportsList"></div>
        </div>
      </div>

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
            <label class="form-label fw-semibold">Cleaning Quality Rating</label>
            <div class="d-flex gap-2 align-items-center" id="starRating">
              <% for (int s = 1; s <= 5; s++) { %>
              <i class="bi bi-star-fill star-icon" data-value="<%= s %>"
                 style="font-size:1.5rem;cursor:pointer;color:#ccc;transition:color 0.15s;"
                 title="<%= s %> star<%= s > 1 ? "s" : "" %>"></i>
              <% } %>
              <small class="text-muted ms-1" id="ratingLabel">Select a rating</small>
            </div>
            <input type="hidden" id="reportRating" value="3">
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
        document.getElementById('reportRating').value      = '3';
        updateStars(3);
        new bootstrap.Modal(document.getElementById('reportModal')).show();
    }

    function updateStars(value) {
        const stars = document.querySelectorAll('.star-icon');
        const labels = ['', 'Poor', 'Fair', 'Average', 'Good', 'Excellent'];
        stars.forEach(s => {
            s.style.color = parseInt(s.dataset.value) <= value ? '#f0a500' : '#ccc';
        });
        const label = document.getElementById('ratingLabel');
        if (label) label.textContent = value ? labels[value] + ' (' + value + '/5)' : 'Select a rating';
    }

    // Star rating interaction
    document.querySelectorAll('.star-icon').forEach(star => {
        star.addEventListener('click', () => {
            const val = parseInt(star.dataset.value);
            document.getElementById('reportRating').value = val;
            updateStars(val);
        });
        star.addEventListener('mouseover', () => updateStars(parseInt(star.dataset.value)));
        star.addEventListener('mouseout',  () => updateStars(parseInt(document.getElementById('reportRating').value) || 3));
    });

    function submitReport() {
        const taskId   = parseInt(document.getElementById('reportTaskId').value);
        const taskName = document.getElementById('reportTaskName').value;
        const rating   = parseInt(document.getElementById('reportRating').value) || 3;
        const reason   = document.getElementById('reportReason').value.trim();
        const notes    = document.getElementById('reportNotes').value.trim();
        if (!reason) { showToast('Please provide a reason for your dissatisfaction', 'error'); return; }

        const submitBtn = document.getElementById('submitReportBtn');
        submitBtn.disabled = true;

        const params = new URLSearchParams({ taskName, rating, reason, notes });
        fetch(window.location.origin + document.querySelector('meta[name="ctx"]').content + '/lecturer/report', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params.toString()
        })
        .then(r => r.json())
        .then(data => {
            submitBtn.disabled = false;
            if (data.success) {
                const task = currentTasks.find(t => t.id === taskId);
                if (task) task.reported = true;
                reports.unshift({ id: data.id || Date.now(), taskName, rating, reason, notes,
                                  date: new Date().toLocaleString(), status: 'Submitted' });
                showToast('Report sent to supervisor regarding "' + taskName + '"', 'info');
                bootstrap.Modal.getInstance(document.getElementById('reportModal')).hide();
                saveState();
                renderTasks();
                renderReports();
            } else {
                showToast(data.message || 'Failed to submit report', 'error');
            }
        })
        .catch(() => {
            submitBtn.disabled = false;
            showToast('Network error. Please try again.', 'error');
        });
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
            const stars = Array.from({length: 5}, (_, i) =>
                `<i class="bi bi-star${i < (report.rating || 3) ? '-fill' : ''}" style="color:${i < (report.rating || 3) ? '#f0a500' : '#ccc'};font-size:0.9rem;"></i>`
            ).join('');
            const div = document.createElement('div');
            div.className = 'task-item';
            div.innerHTML = `
                <div class="task-content">
                    <p class="task-title"><strong>${report.taskName}</strong> - ${report.date}</p>
                    <p class="text-muted small mb-1">${stars}</p>
                    <p class="text-muted small mb-1"><strong>Reason:</strong> ${report.reason}</p>
                    ${report.notes ? `<p class="text-muted small"><strong>Notes:</strong> ${report.notes}</p>` : ''}
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

    loadState();
</script>
</body>
</html>
