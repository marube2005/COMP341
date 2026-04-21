<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartcampus.model.User" %>
<%
    User currentUser = (User) session.getAttribute("loggedInUser");
    String userName  = currentUser != null ? currentUser.getName() : "User";
    String userRole  = currentUser != null ? currentUser.getRole().name() : "";
    String activePage = (String) request.getAttribute("activePage");
    if (activePage == null) activePage = "";
    String ctx = request.getContextPath();
%>
<style>
    /* ── Mobile top bar ─────────────────────────────────── */
    .mobile-topbar {
        display: none;
        position: fixed;
        top: 0; left: 0; right: 0;
        height: 56px;
        background: linear-gradient(90deg, #1a472a 0%, #007624 100%);
        z-index: 1040;
        align-items: center;
        padding: 0 1rem;
        justify-content: space-between;
        box-shadow: 0 2px 8px rgba(0,0,0,0.25);
    }
    @media (max-width: 767.98px) {
        .mobile-topbar { display: flex; }
        body { padding-top: 56px !important; }
        /* Stack main content full-width below the top bar */
        .row > main,
        .row > div.main-content,
        .row > .col-md-9,
        .row > .col-md-10 {
            width: 100% !important;
            max-width: 100% !important;
            margin-left: 0 !important;
        }
    }

    /* ── Mobile sidebar overlay + drawer ────────────────── */
    .mobile-sidebar-overlay {
        display: none;
        position: fixed;
        inset: 0;
        background: rgba(0,0,0,0.5);
        z-index: 1045;
    }
    .mobile-sidebar-overlay.open { display: block; }
    .mobile-sidebar-drawer {
        position: fixed;
        top: 0; left: -280px;
        width: 260px;
        height: 100dvh;
        background: linear-gradient(180deg, #1a472a 0%, #007624 100%);
        z-index: 1050;
        transition: left 0.3s ease;
        display: flex;
        flex-direction: column;
        padding: 1rem 0;
        overflow-y: auto;
    }
    .mobile-sidebar-drawer.open { left: 0; }

    /* ── Red sign-out button (shared) ───────────────────── */
    .nav-signout {
        background: rgba(220, 53, 69, 0.18) !important;
        color: #ff6b6b !important;
        border: 1px solid rgba(220, 53, 69, 0.35) !important;
        margin: 0.4rem 0.8rem !important;
    }
    .nav-signout:hover {
        background: rgba(220, 53, 69, 0.32) !important;
        color: #ff4757 !important;
    }

    /* ── Sidebar bottom section ──────────────────────────── */
    .sidebar-bottom {
        margin-top: auto;
        padding: 0.75rem 0 0;
        border-top: 1px solid rgba(255,255,255,0.15);
    }
    .sidebar-user-label {
        padding: 0.4rem 1.4rem;
        font-size: 0.78rem;
        color: rgba(255,255,255,0.55);
    }
</style>

<!-- ═══ Mobile Top Bar (< md) ═══════════════════════════════════ -->
<div class="mobile-topbar">
    <button class="btn btn-link text-white p-0 lh-1" id="mobileSidebarToggle" aria-label="Open menu">
        <i class="bi bi-list" style="font-size:1.7rem;"></i>
    </button>
    <span class="text-white fw-bold" style="font-family:'Playfair Display',serif;font-size:1.1rem;">SmartCampus</span>
    <a href="<%= ctx %>/logout" class="btn btn-danger btn-sm rounded-pill px-3">
        <i class="bi bi-box-arrow-left"></i>
    </a>
</div>

<!-- ═══ Mobile Sidebar Overlay ══════════════════════════════════ -->
<div class="mobile-sidebar-overlay" id="mobileSidebarOverlay"></div>

<!-- ═══ Mobile Sidebar Drawer ═══════════════════════════════════ -->
<div class="mobile-sidebar-drawer" id="mobileSidebarDrawer">
    <div class="px-3 pb-3 mb-2 border-bottom border-light border-opacity-25">
        <h3 class="text-white fw-bold mb-0" style="font-family:'Playfair Display',serif;">SmartCampus</h3>
        <p class="text-white-50 small mb-0">Egerton University</p>
    </div>

    <% if ("admin".equals(userRole)) { %>
    <a href="<%= ctx %>/admin/dashboard"   class="nav-link-custom <%= "dashboard".equals(activePage) ? "active" : "" %>"><i class="bi bi-speedometer2"></i> Dashboard</a>
    <a href="<%= ctx %>/admin/users"        class="nav-link-custom <%= "users".equals(activePage) ? "active" : "" %>"><i class="bi bi-people-fill"></i> Users</a>
    <a href="<%= ctx %>/facilities"         class="nav-link-custom <%= "facilities".equals(activePage) ? "active" : "" %>"><i class="bi bi-building-fill"></i> Offices</a>
    <% } else if ("lecturer".equals(userRole)) { %>
    <a href="<%= ctx %>/lecturer/dashboard"  class="nav-link-custom <%= "dashboard".equals(activePage) ? "active" : "" %>"><i class="bi bi-speedometer2"></i> Dashboard</a>
    <a href="#" data-section="reports"       class="nav-link-custom"><i class="bi bi-flag"></i> My Reports</a>
    <% } else if ("janitor".equals(userRole)) { %>
    <a href="<%= ctx %>/janitor/dashboard"   class="nav-link-custom <%= "dashboard".equals(activePage) ? "active" : "" %>"><i class="bi bi-speedometer2"></i> Dashboard</a>
    <a href="#" data-section="history"       class="nav-link-custom"><i class="bi bi-clock-history"></i> Completed History</a>
    <% } else if ("supervisor".equals(userRole)) { %>
    <a href="<%= ctx %>/supervisor/dashboard" class="nav-link-custom <%= "dashboard".equals(activePage) ? "active" : "" %>"><i class="bi bi-speedometer2"></i> Dashboard</a>
    <a href="#" data-section="monitor"        class="nav-link-custom"><i class="bi bi-tv"></i> Live Monitor</a>
    <a href="#" data-section="staff"          class="nav-link-custom"><i class="bi bi-people"></i> Janitor Staff</a>
    <a href="#" data-section="reports"        class="nav-link-custom"><i class="bi bi-flag"></i> Dispute Reports</a>
    <% } %>

    <div class="sidebar-bottom">
        <div class="sidebar-user-label">
            <i class="bi bi-person-circle"></i> <%= userName %>
            <span class="badge bg-success ms-1 text-capitalize"><%= userRole %></span>
        </div>
        <a href="<%= ctx %>/logout" class="nav-link-custom nav-signout">
            <i class="bi bi-box-arrow-left"></i> Sign Out
        </a>
    </div>
</div>

<!-- ═══ Desktop Sidebar (≥ md) ══════════════════════════════════ -->
<nav class="sidebar col-md-2 col-lg-2 d-none d-md-flex flex-column py-3">
    <div class="sidebar-brand px-3 pb-3 mb-3 border-bottom border-light border-opacity-25">
        <h3 class="text-white fw-bold mb-0" style="font-family:'Playfair Display',serif;">SmartCampus</h3>
        <p class="text-white-50 small mb-0">Egerton University</p>
    </div>

    <% if ("admin".equals(userRole)) { %>
    <a href="<%= ctx %>/admin/dashboard"   class="nav-link-custom <%= "dashboard".equals(activePage) ? "active" : "" %>"><i class="bi bi-speedometer2"></i> Dashboard</a>
    <a href="<%= ctx %>/admin/users"        class="nav-link-custom <%= "users".equals(activePage) ? "active" : "" %>"><i class="bi bi-people-fill"></i> Users</a>
    <a href="<%= ctx %>/facilities"         class="nav-link-custom <%= "facilities".equals(activePage) ? "active" : "" %>"><i class="bi bi-building-fill"></i> Offices</a>
    <% } else if ("lecturer".equals(userRole)) { %>
    <a href="<%= ctx %>/lecturer/dashboard"  class="nav-link-custom <%= "dashboard".equals(activePage) ? "active" : "" %>"><i class="bi bi-speedometer2"></i> Dashboard</a>
    <a href="#" data-section="reports"       class="nav-link-custom"><i class="bi bi-flag"></i> My Reports</a>
    <% } else if ("janitor".equals(userRole)) { %>
    <a href="<%= ctx %>/janitor/dashboard"   class="nav-link-custom <%= "dashboard".equals(activePage) ? "active" : "" %>"><i class="bi bi-speedometer2"></i> Dashboard</a>
    <a href="#" data-section="history"       class="nav-link-custom"><i class="bi bi-clock-history"></i> Completed History</a>
    <% } else if ("supervisor".equals(userRole)) { %>
    <a href="<%= ctx %>/supervisor/dashboard" class="nav-link-custom <%= "dashboard".equals(activePage) ? "active" : "" %>"><i class="bi bi-speedometer2"></i> Dashboard</a>
    <a href="#" data-section="monitor"        class="nav-link-custom"><i class="bi bi-tv"></i> Live Monitor</a>
    <a href="#" data-section="staff"          class="nav-link-custom"><i class="bi bi-people"></i> Janitor Staff</a>
    <a href="#" data-section="reports"        class="nav-link-custom"><i class="bi bi-flag"></i> Dispute Reports</a>
    <% } %>

    <div class="sidebar-bottom">
        <div class="sidebar-user-label">
            <i class="bi bi-person-circle"></i> <%= userName %>
            <span class="badge bg-success ms-1 text-capitalize"><%= userRole %></span>
        </div>
        <a href="<%= ctx %>/logout" class="nav-link-custom nav-signout">
            <i class="bi bi-box-arrow-left"></i> Sign Out
        </a>
    </div>
</nav>

<script>
(function () {
    var toggle  = document.getElementById('mobileSidebarToggle');
    var overlay = document.getElementById('mobileSidebarOverlay');
    var drawer  = document.getElementById('mobileSidebarDrawer');
    function openDrawer()  { drawer.classList.add('open');  overlay.classList.add('open'); }
    function closeDrawer() { drawer.classList.remove('open'); overlay.classList.remove('open'); }
    if (toggle)  toggle.addEventListener('click', openDrawer);
    if (overlay) overlay.addEventListener('click', closeDrawer);
    /* Close drawer when a link inside it is tapped */
    if (drawer) {
        drawer.querySelectorAll('a').forEach(function(a) {
            a.addEventListener('click', function() {
                if (a.getAttribute('href') && a.getAttribute('href') !== '#') closeDrawer();
            });
        });
    }
})();
</script>
