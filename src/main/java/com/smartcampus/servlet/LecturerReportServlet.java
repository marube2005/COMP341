package com.smartcampus.servlet;

import com.smartcampus.dao.JanitorReportDAO;
import com.smartcampus.model.JanitorReport;
import com.smartcampus.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Handles lecturer report submissions about janitor cleaning quality.
 *
 * <ul>
 *   <li>POST /lecturer/report – validates the authenticated lecturer's session,
 *       persists the report to the database, and returns a JSON response.</li>
 *   <li>GET  /lecturer/report – redirects to the lecturer dashboard.</li>
 * </ul>
 */
public class LecturerReportServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(LecturerReportServlet.class.getName());

    private final JanitorReportDAO reportDAO = new JanitorReportDAO();

    /** Redirects direct GET requests to the lecturer dashboard. */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.sendRedirect(req.getContextPath() + "/lecturer/dashboard");
    }

    /**
     * Accepts a JSON/form POST from the lecturer dashboard report modal,
     * persists the report, and returns a JSON result.
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        // ── Authentication check ─────────────────────────────
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"success\":false,\"message\":\"Not authenticated\"}");
            return;
        }

        User user = (User) session.getAttribute("loggedInUser");
        if (user.getRole() != User.Role.lecturer) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            out.print("{\"success\":false,\"message\":\"Access denied\"}");
            return;
        }

        // ── Parameter extraction ──────────────────────────────
        String taskName = req.getParameter("taskName");
        String activityName = req.getParameter("activityName");
        String ratingStr = req.getParameter("rating");
        String reason   = req.getParameter("reason");
        String notes    = req.getParameter("notes");

        if (taskName == null || taskName.isBlank()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\":false,\"message\":\"Task name is required\"}");
            return;
        }
        if (reason == null || reason.isBlank()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\":false,\"message\":\"Reason is required\"}");
            return;
        }

        int rating = 3; // default
        if (ratingStr != null && !ratingStr.isBlank()) {
            try {
                rating = Integer.parseInt(ratingStr.trim());
                if (rating < 1 || rating > 5) rating = 3;
            } catch (NumberFormatException e) {
                rating = 3;
            }
        }

        // ── Persist ───────────────────────────────────────────
        JanitorReport report = new JanitorReport();
        report.setLecturerId(user.getId());
        report.setTaskName(taskName.trim());
        report.setActivityName(activityName != null && !activityName.isBlank() ? activityName.trim() : null);
        report.setRating(rating);
        report.setReason(reason.trim());
        report.setNotes(notes != null ? notes.trim() : null);

        try {
            int newId = reportDAO.create(report);
            out.print("{\"success\":true,\"id\":" + newId + "}");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to save janitor report for lecturer " + user.getId(), e);
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\":false,\"message\":\"Failed to save report. Please try again.\"}");
        }
    }
}
