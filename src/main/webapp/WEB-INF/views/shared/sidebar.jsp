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
<nav class="sidebar col-md-2 col-lg-2 d-none d-md-block py-3">
    <div class="sidebar-brand px-3 pb-3 mb-3 border-bottom border-light border-opacity-25">
        <h3 class="text-white fw-bold mb-0" style="font-family:'Playfair Display',serif;">SmartCampus</h3>
        <p class="text-white-50 small mb-0">Egerton University</p>
    </div>

    <% if ("admin".equals(userRole)) { %>
    <a href="<%= ctx %>/admin/dashboard"   class="nav-link-custom <%= "dashboard".equals(activePage) ? "active" : "" %>"><i class="bi bi-speedometer2"></i> Dashboard</a>
    <a href="<%= ctx %>/admin/users"        class="nav-link-custom <%= "users".equals(activePage) ? "active" : "" %>"><i class="bi bi-people-fill"></i> Users</a>
    <a href="<%= ctx %>/facilities"         class="nav-link-custom <%= "facilities".equals(activePage) ? "active" : "" %>"><i class="bi bi-building-fill"></i> Offices</a>
    <a href="<%= ctx %>/cleaning-tasks"     class="nav-link-custom <%= "cleaning".equals(activePage) ? "active" : "" %>"><i class="bi bi-bucket-fill"></i> Cleaning Tasks</a>
    <% } else if ("lecturer".equals(userRole)) { %>
    <a href="<%= ctx %>/lecturer/dashboard"  class="nav-link-custom <%= "dashboard".equals(activePage) ? "active" : "" %>"><i class="bi bi-speedometer2"></i> Dashboard</a>
    <a href="#" data-section="rateTasks"     class="nav-link-custom"><i class="bi bi-star"></i> Rate Tasks</a>
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

    <div class="mt-auto px-3 pt-3" style="position:absolute;bottom:20px;left:0;right:0;">
        <div class="text-white-50 small mb-2">
            <i class="bi bi-person-circle"></i> <%= userName %>
            <span class="badge bg-success ms-1 text-capitalize"><%= userRole %></span>
        </div>
        <a href="<%= ctx %>/logout" class="nav-link-custom text-danger-emphasis">
            <i class="bi bi-box-arrow-left"></i> Sign Out
        </a>
    </div>
</nav>
