package com.smartcampus.servlet;

import com.smartcampus.dao.UserDAO;
import com.smartcampus.model.User;
import com.smartcampus.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Handles user login (GET shows the login page, POST processes credentials).
 * Mapped to /login in web.xml.
 */
public class LoginServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(LoginServlet.class.getName());
    private final UserDAO userDAO = new UserDAO();

    /** Shows the login JSP. */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // If already logged in, redirect to dashboard
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("loggedInUser") != null) {
            User user = (User) session.getAttribute("loggedInUser");
            redirectToDashboard(resp, req.getContextPath(), user.getRole());
            return;
        }
        req.getRequestDispatcher("/index.jsp").forward(req, resp);
    }

    /** Processes the login form submission. */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String email    = req.getParameter("email");
        String password = req.getParameter("password");

        // ─── Validation ──────────────────────────────────────────
        if (!ValidationUtil.isValidEmail(email)) {
            req.setAttribute("error", "Please enter a valid Egerton University email (e.g. name.role@egerton.ac.ke).");
            req.getRequestDispatcher("/index.jsp").forward(req, resp);
            return;
        }
        if (!ValidationUtil.isValidPassword(password)) {
            req.setAttribute("error", "Password must be at least 6 characters.");
            req.getRequestDispatcher("/index.jsp").forward(req, resp);
            return;
        }

        // ─── Authentication ──────────────────────────────────────
        try {
            User user = userDAO.authenticate(email, password);
            if (user == null) {
                req.setAttribute("error", "Invalid email address or password.");
                req.setAttribute("emailValue", email);
                req.getRequestDispatcher("/index.jsp").forward(req, resp);
                return;
            }

            // Successful login – invalidate old session first (session fixation protection)
            HttpSession oldSession = req.getSession(false);
            if (oldSession != null) oldSession.invalidate();

            HttpSession session = req.getSession(true);
            session.setAttribute("loggedInUser", user);
            session.setAttribute("userId",   user.getId());
            session.setAttribute("userRole", user.getRole().name());
            session.setAttribute("userName", user.getName());
            session.setMaxInactiveInterval(30 * 60); // 30 minutes

            LOGGER.log(Level.INFO, "User logged in: {0} [{1}]", new Object[]{user.getEmail(), user.getRole()});
            redirectToDashboard(resp, req.getContextPath(), user.getRole());

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error during login", e);
            req.setAttribute("error", "A system error occurred. Please try again later.");
            req.getRequestDispatcher("/index.jsp").forward(req, resp);
        } catch (RuntimeException e) {
            LOGGER.log(Level.SEVERE, "Unexpected error during login", e);
            req.setAttribute("error", "A system error occurred. Please try again later.");
            req.getRequestDispatcher("/index.jsp").forward(req, resp);
        }
    }

    // ─── Helper ───────────────────────────────────────────────

    private void redirectToDashboard(HttpServletResponse resp, String contextPath, User.Role role)
            throws IOException {
        String path;
        switch (role) {
            case admin:      path = contextPath + "/admin/dashboard";      break;
            case lecturer:   path = contextPath + "/lecturer/dashboard";   break;
            case janitor:    path = contextPath + "/janitor/dashboard";    break;
            case supervisor: path = contextPath + "/supervisor/dashboard"; break;
            default:         path = contextPath + "/login";                break;
        }
        resp.sendRedirect(path);
    }
}
