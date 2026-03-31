package com.smartcampus.filter;

import com.smartcampus.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

/**
 * Servlet filter that enforces authentication and role-based access control.
 * Mapped in web.xml to /*
 */
public class AuthFilter implements Filter {

    /** URL paths that are always accessible without a session. */
    private static final Set<String> PUBLIC_PATHS = new HashSet<>(Arrays.asList(
            "/login",
            "/login.jsp",
            "/index.jsp",
            "/register"
    ));

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest)  request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String contextPath = req.getContextPath();
        String requestURI  = req.getRequestURI();

        // Strip context path to get the local path
        String localPath = requestURI.substring(contextPath.length());

        // Allow public paths and static resources through
        if (isPublicPath(localPath)) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedInUser") : null;

        if (user == null) {
            // Not authenticated – redirect to login
            resp.sendRedirect(contextPath + "/login");
            return;
        }

        // Role-based access checks
        if (!isAuthorised(localPath, user.getRole())) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            RequestDispatcher dispatcher = req.getRequestDispatcher("/403.jsp");
            dispatcher.forward(req, resp);
            return;
        }

        chain.doFilter(request, response);
    }

    // ─── Helpers ──────────────────────────────────────────────

    private boolean isPublicPath(String localPath) {
        if (PUBLIC_PATHS.contains(localPath)) return true;
        // Allow static assets (CSS, JS, images, fonts) through
        return localPath.startsWith("/static/")
            || localPath.endsWith(".css")
            || localPath.endsWith(".js")
            || localPath.endsWith(".png")
            || localPath.endsWith(".jpg")
            || localPath.endsWith(".ico")
            || localPath.endsWith(".woff")
            || localPath.endsWith(".woff2");
    }

    private boolean isAuthorised(String localPath, User.Role role) {
        // Admin-only paths
        if (localPath.startsWith("/admin/")) {
            return role == User.Role.admin;
        }
        // Lecturer-only paths
        if (localPath.startsWith("/lecturer/")) {
            return role == User.Role.lecturer;
        }
        // Janitor-only paths
        if (localPath.startsWith("/janitor/")) {
            return role == User.Role.janitor;
        }
        // Supervisor-only paths
        if (localPath.startsWith("/supervisor/")) {
            return role == User.Role.supervisor;
        }
        // All other protected paths are accessible to any authenticated user
        return true;
    }
}
