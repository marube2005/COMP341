package com.smartcampus.servlet;

import com.smartcampus.dao.CleaningTaskDAO;
import com.smartcampus.dao.FacilityDAO;
import com.smartcampus.dao.UserDAO;
import com.smartcampus.model.CleaningTask;
import com.smartcampus.model.User;
import com.smartcampus.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * CRUD servlet for {@link CleaningTask} entities.
 *
 * <p>Supported actions (via the {@code action} request parameter on POST):
 * <ul>
 *   <li>GET  /cleaning-tasks            – list tasks (filtered by role)</li>
 *   <li>POST /cleaning-tasks?action=create       – create a task (admin/supervisor)</li>
 *   <li>POST /cleaning-tasks?action=updateStatus – update task status (janitor/admin/supervisor)</li>
 *   <li>POST /cleaning-tasks?action=delete       – delete a task (admin only)</li>
 * </ul>
 */
public class CleaningTaskServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(CleaningTaskServlet.class.getName());

    private final CleaningTaskDAO ctDAO   = new CleaningTaskDAO();
    private final FacilityDAO     facDAO  = new FacilityDAO();
    private final UserDAO         userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = currentUser(req);
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        try {
            switch (user.getRole()) {
                case janitor:
                    req.setAttribute("tasks", ctDAO.findByJanitor(user.getId()));
                    break;
                default:
                    req.setAttribute("tasks", ctDAO.findAll());
                    break;
            }
            req.setAttribute("facilities", facDAO.findAll());
            req.setAttribute("janitors",   userDAO.findByRole(User.Role.janitor));
            req.getRequestDispatcher("/WEB-INF/views/shared/cleaning-tasks.jsp").forward(req, resp);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "DB error in CleaningTaskServlet GET", e);
            handleError(req, resp, "Failed to load cleaning tasks.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = currentUser(req);
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        if (action == null) action = "";

        try {
            switch (action) {
                case "create":       handleCreate(req, resp, user); break;
                case "reassign":     handleReassign(req, resp, user); break;
                case "updateStatus": handleUpdateStatus(req, resp, user); break;
                case "delete":       handleDelete(req, resp, user); break;
                default: resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown action: " + action); break;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "DB error in CleaningTaskServlet POST", e);
            handleError(req, resp, "A database error occurred.");
        }
    }

    private void handleReassign(HttpServletRequest req, HttpServletResponse resp, User user)
            throws IOException, SQLException {

        if (user.getRole() != User.Role.admin && user.getRole() != User.Role.supervisor) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        int id = ValidationUtil.parseIntOrDefault(req.getParameter("id"), -1);
        if (id < 1) { resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid task ID"); return; }

        String janitorIdStr = req.getParameter("janitorId");
        if (!ValidationUtil.isPositiveInt(janitorIdStr)) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid janitor");
            return;
        }

        int janitorId = Integer.parseInt(janitorIdStr.trim());
        ctDAO.updateAssignedTo(id, janitorId);
        LOGGER.log(Level.INFO, "Task {0} reassigned to janitorId={1} by userId={2}",
                new Object[]{id, janitorId, user.getId()});
        resp.sendRedirect(req.getContextPath() + "/supervisor/dashboard?success=reassigned");
    }

    // ─── Action handlers ─────────────────────────────────────

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp, User user)
            throws IOException, ServletException, SQLException {

        if (user.getRole() != User.Role.admin && user.getRole() != User.Role.supervisor) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String facilityIdStr = req.getParameter("facilityId");
        String janitorIdStr  = req.getParameter("janitorId");
        String dateStr       = req.getParameter("scheduledDate");
        String statusStr     = req.getParameter("status");
        String notes         = req.getParameter("notes");

        if (!ValidationUtil.isPositiveInt(facilityIdStr)) {
            req.setAttribute("error", "Please select a valid facility.");
            doGet(req, resp); return;
        }
        if (!ValidationUtil.isPositiveInt(janitorIdStr)) {
            req.setAttribute("error", "Please select a valid janitor.");
            doGet(req, resp); return;
        }
        if (ValidationUtil.isBlank(dateStr)) {
            req.setAttribute("error", "Scheduled date is required.");
            doGet(req, resp); return;
        }

        LocalDate scheduledDate;
        try {
            scheduledDate = LocalDate.parse(dateStr.trim());
        } catch (Exception e) {
            req.setAttribute("error", "Invalid date format. Use YYYY-MM-DD.");
            doGet(req, resp); return;
        }

        if (scheduledDate.isBefore(LocalDate.now())) {
            req.setAttribute("error", "Scheduled date must be today or a future date.");
            doGet(req, resp); return;
        }

        int facilityId = Integer.parseInt(facilityIdStr.trim());
        if (ctDAO.existsByFacilityAndDate(facilityId, scheduledDate, -1)) {
            req.setAttribute("error", "This office is already assigned to a janitor on the selected date.");
            doGet(req, resp); return;
        }

        CleaningTask task = new CleaningTask();
        task.setFacilityId(facilityId);
        task.setAssignedTo(Integer.parseInt(janitorIdStr.trim()));
        task.setScheduledDate(scheduledDate);
        task.setStatus(isValidEnum(CleaningTask.Status.class, statusStr)
                ? CleaningTask.Status.valueOf(statusStr) : CleaningTask.Status.pending);
        task.setNotes(notes != null ? notes.trim() : "");

        ctDAO.create(task);
        LOGGER.log(Level.INFO, "Cleaning task created by userId={0}", user.getId());
        if (user.getRole() == User.Role.supervisor) {
            resp.sendRedirect(req.getContextPath() + "/supervisor/dashboard?success=assigned");
        } else {
            resp.sendRedirect(req.getContextPath() + "/cleaning-tasks?success=created");
        }
    }

    private void handleUpdateStatus(HttpServletRequest req, HttpServletResponse resp, User user)
            throws IOException, SQLException {

        int id = ValidationUtil.parseIntOrDefault(req.getParameter("id"), -1);
        if (id < 1) { resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid task ID"); return; }

        String statusStr = req.getParameter("status");
        if (!isValidEnum(CleaningTask.Status.class, statusStr)) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid status");
            return;
        }

        // Janitor can only update their own tasks
        if (user.getRole() == User.Role.janitor) {
            CleaningTask task = ctDAO.findById(id);
            if (task == null || task.getAssignedTo() != user.getId()) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
        } else if (user.getRole() != User.Role.admin && user.getRole() != User.Role.supervisor) {
            // Only admin/supervisor may update arbitrary tasks
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        ctDAO.updateStatus(id, CleaningTask.Status.valueOf(statusStr));
        resp.sendRedirect(req.getContextPath() + "/cleaning-tasks?success=statusUpdated");
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp, User user)
            throws IOException, SQLException {

        if (user.getRole() != User.Role.admin) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        int id = ValidationUtil.parseIntOrDefault(req.getParameter("id"), -1);
        if (id < 1) { resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid ID"); return; }

        ctDAO.delete(id);
        resp.sendRedirect(req.getContextPath() + "/cleaning-tasks?success=deleted");
    }

    // ─── Helpers ──────────────────────────────────────────────

    private <E extends Enum<E>> boolean isValidEnum(Class<E> enumClass, String value) {
        if (ValidationUtil.isBlank(value)) return false;
        try { Enum.valueOf(enumClass, value); return true; }
        catch (IllegalArgumentException e) { return false; }
    }

    private User currentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return (session != null) ? (User) session.getAttribute("loggedInUser") : null;
    }

    private void handleError(HttpServletRequest req, HttpServletResponse resp, String msg)
            throws ServletException, IOException {
        req.setAttribute("error", msg);
        req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
    }
}
