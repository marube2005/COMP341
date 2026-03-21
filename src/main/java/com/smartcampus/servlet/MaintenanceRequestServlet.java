package com.smartcampus.servlet;

import com.smartcampus.dao.FacilityDAO;
import com.smartcampus.dao.MaintenanceRequestDAO;
import com.smartcampus.dao.UserDAO;
import com.smartcampus.model.MaintenanceRequest;
import com.smartcampus.model.User;
import com.smartcampus.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * CRUD servlet for {@link MaintenanceRequest} entities.
 *
 * <p>Supported actions (via the {@code action} request parameter on POST):
 * <ul>
 *   <li>GET  /maintenance-requests              – list requests (filtered by role)</li>
 *   <li>GET  /maintenance-requests?id=n         – show single request</li>
 *   <li>POST /maintenance-requests?action=create  – submit a new request</li>
 *   <li>POST /maintenance-requests?action=update  – update an existing request</li>
 *   <li>POST /maintenance-requests?action=updateStatus – change status only</li>
 *   <li>POST /maintenance-requests?action=assign  – assign to a janitor/staff member</li>
 *   <li>POST /maintenance-requests?action=delete  – delete a request (admin only)</li>
 * </ul>
 */
public class MaintenanceRequestServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(MaintenanceRequestServlet.class.getName());

    private final MaintenanceRequestDAO mrDAO  = new MaintenanceRequestDAO();
    private final FacilityDAO           facDAO = new FacilityDAO();
    private final UserDAO               userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = currentUser(req);
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String idParam = req.getParameter("id");
        try {
            if (ValidationUtil.isNotBlank(idParam)) {
                int id = ValidationUtil.parseIntOrDefault(idParam, -1);
                if (id < 1) { resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid ID"); return; }

                MaintenanceRequest mr = null;
                switch (user.getRole()) {
                    case admin:
                    case supervisor:
                        mr = mrDAO.findById(id);
                        break;
                    case lecturer:
                        for (MaintenanceRequest r : mrDAO.findByReporter(user.getId())) {
                            if (r.getId() == id) {
                                mr = r;
                                break;
                            }
                        }
                        break;
                    case janitor:
                        for (MaintenanceRequest r : mrDAO.findByAssignee(user.getId())) {
                            if (r.getId() == id) {
                                mr = r;
                                break;
                            }
                        }
                        break;
                    default:
                        resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                        return;
                }

                if (mr == null) {
                    // Either the request does not exist or the user is not authorised to view it
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }

                req.setAttribute("request", mr);
                req.setAttribute("facilities", facDAO.findAll());
                req.setAttribute("janitors",   userDAO.findByRole(User.Role.janitor));
                req.getRequestDispatcher("/WEB-INF/views/shared/maintenance-requests.jsp").forward(req, resp);
            } else {
            // Filter by role
            switch (user.getRole()) {
                case admin:
                case supervisor:
                    req.setAttribute("requests", mrDAO.findAll());
                    break;
                case lecturer:
                    req.setAttribute("requests", mrDAO.findByReporter(user.getId()));
                    break;
                case janitor:
                    req.setAttribute("requests", mrDAO.findByAssignee(user.getId()));
                    break;
                default:
                    req.setAttribute("requests", mrDAO.findAll());
                    break;
            }
                req.setAttribute("facilities", facDAO.findAll());
                req.setAttribute("janitors",   userDAO.findByRole(User.Role.janitor));
                req.getRequestDispatcher("/WEB-INF/views/shared/maintenance-requests.jsp").forward(req, resp);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "DB error in MaintenanceRequestServlet GET", e);
            handleError(req, resp, "Failed to load maintenance requests.");
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
                case "update":       handleUpdate(req, resp, user); break;
                case "updateStatus": handleUpdateStatus(req, resp, user); break;
                case "assign":       handleAssign(req, resp, user); break;
                case "delete":       handleDelete(req, resp, user); break;
                default: resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown action: " + action); break;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "DB error in MaintenanceRequestServlet POST", e);
            handleError(req, resp, "A database error occurred.");
        }
    }

    // ─── Action handlers ─────────────────────────────────────

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp, User user)
            throws IOException, ServletException, SQLException {

        String facilityIdStr = req.getParameter("facilityId");
        String title         = req.getParameter("title");
        String description   = req.getParameter("description");
        String priorityStr   = req.getParameter("priority");

        String err = validateRequestInput(facilityIdStr, title, description, priorityStr);
        if (err != null) {
            req.setAttribute("error", err);
            doGet(req, resp);
            return;
        }

        MaintenanceRequest mr = new MaintenanceRequest();
        mr.setFacilityId(Integer.parseInt(facilityIdStr.trim()));
        mr.setReportedBy(user.getId());
        mr.setTitle(title.trim());
        mr.setDescription(description.trim());
        mr.setPriority(MaintenanceRequest.Priority.valueOf(priorityStr));
        mr.setStatus(MaintenanceRequest.Status.pending);

        mrDAO.create(mr);
        LOGGER.log(Level.INFO, "Maintenance request created by userId={0}", user.getId());
        resp.sendRedirect(req.getContextPath() + "/maintenance-requests?success=created");
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp, User user)
            throws IOException, ServletException, SQLException {

        int id = ValidationUtil.parseIntOrDefault(req.getParameter("id"), -1);
        if (id < 1) { resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid ID"); return; }

        MaintenanceRequest existing = mrDAO.findById(id);
        if (existing == null) { resp.sendError(HttpServletResponse.SC_NOT_FOUND); return; }

        // Only admin/supervisor or the original reporter may update
        if (!canModify(user, existing)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String facilityIdStr = req.getParameter("facilityId");
        String title         = req.getParameter("title");
        String description   = req.getParameter("description");
        String priorityStr   = req.getParameter("priority");
        String statusStr     = req.getParameter("status");

        String err = validateRequestInput(facilityIdStr, title, description, priorityStr);
        if (err != null) {
            req.setAttribute("error", err);
            req.setAttribute("request", existing);
            req.getRequestDispatcher("/WEB-INF/views/shared/maintenance-request-detail.jsp").forward(req, resp);
            return;
        }

        existing.setFacilityId(Integer.parseInt(facilityIdStr.trim()));
        existing.setTitle(title.trim());
        existing.setDescription(description.trim());
        existing.setPriority(MaintenanceRequest.Priority.valueOf(priorityStr));
        if (ValidationUtil.isNotBlank(statusStr)) {
            existing.setStatus(MaintenanceRequest.Status.valueOf(statusStr));
        }

        mrDAO.update(existing);
        resp.sendRedirect(req.getContextPath() + "/maintenance-requests?success=updated");
    }

    private void handleUpdateStatus(HttpServletRequest req, HttpServletResponse resp, User user)
            throws IOException, SQLException {

        int id = ValidationUtil.parseIntOrDefault(req.getParameter("id"), -1);
        if (id < 1) { resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid ID"); return; }

        String statusStr = req.getParameter("status");
        if (!isValidEnum(MaintenanceRequest.Status.class, statusStr)) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid status");
            return;
        }

        mrDAO.updateStatus(id, MaintenanceRequest.Status.valueOf(statusStr));
        resp.sendRedirect(req.getContextPath() + "/maintenance-requests?success=statusUpdated");
    }

    private void handleAssign(HttpServletRequest req, HttpServletResponse resp, User user)
            throws IOException, SQLException {

        if (user.getRole() != User.Role.admin && user.getRole() != User.Role.supervisor) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        int requestId  = ValidationUtil.parseIntOrDefault(req.getParameter("id"),         -1);
        int assigneeId = ValidationUtil.parseIntOrDefault(req.getParameter("assigneeId"), -1);
        if (requestId < 1 || assigneeId < 1) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid IDs");
            return;
        }

        mrDAO.assign(requestId, assigneeId);
        LOGGER.log(Level.INFO, "Request {0} assigned to user {1}", new Object[]{requestId, assigneeId});
        resp.sendRedirect(req.getContextPath() + "/maintenance-requests?success=assigned");
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp, User user)
            throws IOException, SQLException {

        if (user.getRole() != User.Role.admin) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        int id = ValidationUtil.parseIntOrDefault(req.getParameter("id"), -1);
        if (id < 1) { resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid ID"); return; }

        mrDAO.delete(id);
        resp.sendRedirect(req.getContextPath() + "/maintenance-requests?success=deleted");
    }

    // ─── Helpers ──────────────────────────────────────────────

    private boolean isValidTitle(String title) {
        if (ValidationUtil.isBlank(title)) {
            return false;
        }
        String trimmed = title.trim();
        int length = trimmed.length();
        return length >= 2 && length <= 200;
    }

    private String validateRequestInput(String facilityIdStr, String title,
                                        String description, String priorityStr) {
        if (!ValidationUtil.isPositiveInt(facilityIdStr)) return "Please select a valid facility.";
        if (!isValidTitle(title))                        return "Title is required (2–200 characters).";
        if (ValidationUtil.isBlank(description))         return "Description is required.";
        if (!isValidEnum(MaintenanceRequest.Priority.class, priorityStr)) return "Invalid priority value.";
        return null;
    }

    private <E extends Enum<E>> boolean isValidEnum(Class<E> enumClass, String value) {
        if (ValidationUtil.isBlank(value)) return false;
        try { Enum.valueOf(enumClass, value); return true; }
        catch (IllegalArgumentException e) { return false; }
    }

    private boolean canModify(User user, MaintenanceRequest mr) {
        return user.getRole() == User.Role.admin
            || user.getRole() == User.Role.supervisor
            || user.getId() == mr.getReportedBy();
    }

    private User currentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return (session != null) ? (User) session.getAttribute("loggedInUser") : null;
    }

    private void handleError(HttpServletRequest req, HttpServletResponse resp, String message)
            throws ServletException, IOException {
        req.setAttribute("error", message);
        req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
    }
}
