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
 * Servlet for managing system users (Admin-only).
 *
 * <p>Supported actions:
 * <ul>
 *   <li>GET  /admin/users                  – list all users</li>
 *   <li>POST /admin/users?action=create    – add a new user</li>
 *   <li>POST /admin/users?action=update    – update a user</li>
 *   <li>POST /admin/users?action=deactivate – deactivate a user</li>
 *   <li>POST /admin/users?action=resetPassword – reset password</li>
 * </ul>
 */
public class UserManagementServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(UserManagementServlet.class.getName());
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isAdmin(req)) { resp.sendError(HttpServletResponse.SC_FORBIDDEN); return; }

        try {
            req.setAttribute("users", userDAO.findAll());
            req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error loading users", e);
            handleError(req, resp, "Failed to load users.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isAdmin(req)) { resp.sendError(HttpServletResponse.SC_FORBIDDEN); return; }

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        if (action == null) action = "";

        try {
            switch (action) {
                case "create":        handleCreate(req, resp); break;
                case "update":        handleUpdate(req, resp); break;
                case "deactivate":    handleDeactivate(req, resp); break;
                case "resetPassword": handleResetPassword(req, resp); break;
                default: resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown action: " + action); break;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "DB error in UserManagementServlet", e);
            handleError(req, resp, "A database error occurred.");
        }
    }

    // ─── Action handlers ─────────────────────────────────────

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException, SQLException {

        String name       = req.getParameter("name");
        String email      = req.getParameter("email");
        String password   = req.getParameter("password");
        String roleStr    = req.getParameter("role");
        String phone      = req.getParameter("phone");
        String department = req.getParameter("department");

        // Validate
        String err = validateUserInput(name, email, password, roleStr, phone);
        if (err != null) {
            req.setAttribute("error", err);
            doGet(req, resp); return;
        }

        User user = new User();
        user.setName(name.trim());
        user.setEmail(email.trim().toLowerCase());
        user.setRole(User.Role.valueOf(roleStr));
        user.setPhone(phone != null ? phone.trim() : "");
        user.setDepartment(department != null ? department.trim() : "");
        user.setActive(true);

        try {
            userDAO.create(user, password);
            LOGGER.log(Level.INFO, "User created: {0}", email);
            resp.sendRedirect(req.getContextPath() + "/admin/users?success=created");
        } catch (IllegalArgumentException e) {
            req.setAttribute("error", e.getMessage());
            doGet(req, resp);
        }
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException, SQLException {

        int id = ValidationUtil.parseIntOrDefault(req.getParameter("id"), -1);
        if (id < 1) { resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid user ID"); return; }

        String name       = req.getParameter("name");
        String roleStr    = req.getParameter("role");
        String phone      = req.getParameter("phone");
        String department = req.getParameter("department");

        if (!ValidationUtil.isValidName(name)) {
            req.setAttribute("error", "Name is required (2–150 characters).");
            doGet(req, resp); return;
        }
        if (!isValidEnum(User.Role.class, roleStr)) {
            req.setAttribute("error", "Invalid role.");
            doGet(req, resp); return;
        }

        User user = userDAO.findById(id);
        if (user == null) { resp.sendError(HttpServletResponse.SC_NOT_FOUND); return; }

        user.setName(name.trim());
        user.setRole(User.Role.valueOf(roleStr));
        user.setPhone(phone != null ? phone.trim() : "");
        user.setDepartment(department != null ? department.trim() : "");

        userDAO.update(user);
        resp.sendRedirect(req.getContextPath() + "/admin/users?success=updated");
    }

    private void handleDeactivate(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, SQLException {

        int id = ValidationUtil.parseIntOrDefault(req.getParameter("id"), -1);
        if (id < 1) { resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid user ID"); return; }

        userDAO.deactivate(id);
        LOGGER.log(Level.INFO, "User deactivated: id={0}", id);
        resp.sendRedirect(req.getContextPath() + "/admin/users?success=deactivated");
    }

    private void handleResetPassword(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException, SQLException {

        int id          = ValidationUtil.parseIntOrDefault(req.getParameter("id"), -1);
        String newPass  = req.getParameter("newPassword");

        if (id < 1) { resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid user ID"); return; }
        if (!ValidationUtil.isValidPassword(newPass)) {
            req.setAttribute("error", "Password must be 6–72 characters.");
            doGet(req, resp); return;
        }

        userDAO.updatePassword(id, newPass);
        resp.sendRedirect(req.getContextPath() + "/admin/users?success=passwordReset");
    }

    // ─── Helpers ──────────────────────────────────────────────

    private String validateUserInput(String name, String email, String password,
                                     String roleStr, String phone) {
        String trimmedName = (name == null) ? null : name.trim();
        if (ValidationUtil.isBlank(trimmedName)
                || trimmedName.length() < 2
                || trimmedName.length() > 120
                || !ValidationUtil.isValidName(trimmedName)) {
            return "Name is required (2–120 characters).";
        }
        if (!ValidationUtil.isValidEmail(email))      return "A valid email address is required.";
        if (!ValidationUtil.isValidPassword(password)) return "Password must be at least 6 characters.";
        if (!isValidEnum(User.Role.class, roleStr))   return "Invalid role selected.";
        if (!ValidationUtil.isValidPhoneOrBlank(phone)) return "Phone number format is invalid.";
        return null;
    }

    private <E extends Enum<E>> boolean isValidEnum(Class<E> enumClass, String value) {
        if (ValidationUtil.isBlank(value)) return false;
        try { Enum.valueOf(enumClass, value); return true; }
        catch (IllegalArgumentException e) { return false; }
    }

    private boolean isAdmin(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return false;
        User user = (User) session.getAttribute("loggedInUser");
        return user != null && user.getRole() == User.Role.admin;
    }

    private void handleError(HttpServletRequest req, HttpServletResponse resp, String msg)
            throws ServletException, IOException {
        req.setAttribute("error", msg);
        req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
    }
}
