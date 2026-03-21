package com.smartcampus.servlet;

import com.smartcampus.dao.FacilityDAO;
import com.smartcampus.model.Facility;
import com.smartcampus.model.User;
import com.smartcampus.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * CRUD servlet for {@link Facility} entities.
 *
 * <p>Supported actions (via the {@code action} request parameter):
 * <ul>
 *   <li>GET  /facilities           – list all facilities</li>
 *   <li>GET  /facilities?id=n      – show single facility detail</li>
 *   <li>POST /facilities?action=create  – create a new facility (admin only)</li>
 *   <li>POST /facilities?action=update  – update an existing facility (admin only)</li>
 *   <li>POST /facilities?action=delete  – delete a facility (admin only)</li>
 * </ul>
 */
public class FacilityServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(FacilityServlet.class.getName());
    private final FacilityDAO facilityDAO = new FacilityDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String idParam = req.getParameter("id");
        try {
            if (ValidationUtil.isNotBlank(idParam)) {
                int id = ValidationUtil.parseIntOrDefault(idParam, -1);
                if (id < 1) {
                    resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid facility ID");
                    return;
                }
                Facility facility = facilityDAO.findById(id);
                if (facility == null) {
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Facility not found");
                    return;
                }
                req.setAttribute("facility", facility);
                req.setAttribute("facilities", java.util.Collections.singletonList(facility));
                req.getRequestDispatcher("/WEB-INF/views/admin/facilities.jsp").forward(req, resp);
            } else {
                req.setAttribute("facilities", facilityDAO.findAll());
                req.getRequestDispatcher("/WEB-INF/views/admin/facilities.jsp").forward(req, resp);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching facilities", e);
            handleError(req, resp, "Failed to load facilities.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Only admins may modify facilities
        if (!isAdmin(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required");
            return;
        }

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        if (action == null) action = "";

        try {
            switch (action) {
                case "create": handleCreate(req, resp); break;
                case "update": handleUpdate(req, resp); break;
                case "delete": handleDelete(req, resp); break;
                default: resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown action: " + action); break;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in FacilityServlet", e);
            handleError(req, resp, "A database error occurred.");
        }
    }

    // ─── Action handlers ─────────────────────────────────────

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException, SQLException {

        String name        = req.getParameter("name");
        String location    = req.getParameter("location");
        String typeStr     = req.getParameter("facilityType");
        String capacityStr = req.getParameter("capacity");
        String statusStr   = req.getParameter("status");
        String description = req.getParameter("description");

        // Validate
        String validationError = validateFacilityInput(name, location, typeStr, capacityStr, statusStr);
        if (validationError != null) {
            req.setAttribute("error", validationError);
            req.setAttribute("facilities", facilityDAO.findAll());
            req.getRequestDispatcher("/WEB-INF/views/admin/facilities.jsp").forward(req, resp);
            return;
        }

        Facility f = new Facility();
        f.setName(name.trim());
        f.setLocation(location.trim());
        f.setFacilityType(Facility.FacilityType.valueOf(typeStr));
        f.setCapacity(Integer.parseInt(capacityStr.trim()));
        f.setStatus(Facility.Status.valueOf(statusStr));
        f.setDescription(description != null ? description.trim() : "");

        facilityDAO.create(f);
        LOGGER.log(Level.INFO, "Facility created: {0}", name);
        resp.sendRedirect(req.getContextPath() + "/facilities?success=created");
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException, SQLException {

        String idStr       = req.getParameter("id");
        String name        = req.getParameter("name");
        String location    = req.getParameter("location");
        String typeStr     = req.getParameter("facilityType");
        String capacityStr = req.getParameter("capacity");
        String statusStr   = req.getParameter("status");
        String description = req.getParameter("description");

        int id = ValidationUtil.parseIntOrDefault(idStr, -1);
        if (id < 1) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid facility ID");
            return;
        }

        String validationError = validateFacilityInput(name, location, typeStr, capacityStr, statusStr);
        if (validationError != null) {
            req.setAttribute("error", validationError);
            req.setAttribute("facilities", facilityDAO.findAll());
            req.getRequestDispatcher("/WEB-INF/views/admin/facilities.jsp").forward(req, resp);
            return;
        }

        Facility f = new Facility();
        f.setId(id);
        f.setName(name.trim());
        f.setLocation(location.trim());
        f.setFacilityType(Facility.FacilityType.valueOf(typeStr));
        f.setCapacity(Integer.parseInt(capacityStr.trim()));
        f.setStatus(Facility.Status.valueOf(statusStr));
        f.setDescription(description != null ? description.trim() : "");

        boolean updated = facilityDAO.update(f);
        if (!updated) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Facility not found");
            return;
        }
        LOGGER.log(Level.INFO, "Facility updated: id={0}", id);
        resp.sendRedirect(req.getContextPath() + "/facilities?success=updated");
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, SQLException {

        int id = ValidationUtil.parseIntOrDefault(req.getParameter("id"), -1);
        if (id < 1) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid facility ID");
            return;
        }
        boolean deleted = facilityDAO.delete(id);
        if (!deleted) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Facility not found");
            return;
        }
        LOGGER.log(Level.INFO, "Facility deleted: id={0}", id);
        resp.sendRedirect(req.getContextPath() + "/facilities?success=deleted");
    }

    // ─── Helpers ──────────────────────────────────────────────

    /** Returns a validation error message, or {@code null} when all inputs are valid. */
    private String validateFacilityInput(String name, String location,
                                         String typeStr, String capacityStr, String statusStr) {
        if (!ValidationUtil.isValidName(name))          return "Facility name is required (2–150 characters).";
        if (!ValidationUtil.isWithinLength(location, 200)) return "Location is required (max 200 characters).";
        if (!isValidEnum(Facility.FacilityType.class, typeStr)) return "Invalid facility type.";
        int capacity = ValidationUtil.parseIntOrDefault(capacityStr, -1);
        if (capacity < 0)                               return "Capacity must be a non-negative integer.";
        if (!isValidEnum(Facility.Status.class, statusStr)) return "Invalid status value.";
        return null;
    }

    private <E extends Enum<E>> boolean isValidEnum(Class<E> enumClass, String value) {
        if (ValidationUtil.isBlank(value)) return false;
        try {
            Enum.valueOf(enumClass, value);
            return true;
        } catch (IllegalArgumentException e) {
            return false;
        }
    }

    private boolean isAdmin(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return false;
        User user = (User) session.getAttribute("loggedInUser");
        return user != null && user.getRole() == User.Role.admin;
    }

    private void handleError(HttpServletRequest req, HttpServletResponse resp, String message)
            throws ServletException, IOException {
        req.setAttribute("error", message);
        req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
    }
}
