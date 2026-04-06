package com.smartcampus.servlet;

import com.smartcampus.dao.CleaningTaskDAO;
import com.smartcampus.dao.LecturerReportDAO;
import com.smartcampus.model.CleaningTask;
import com.smartcampus.model.LecturerReport;
import com.smartcampus.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Handles lecturer report submissions.
 *
 * <p>POST /lecturer/report — A lecturer rates a completed cleaning task and
 * provides a written report. The submitted report is persisted to the database
 * so that it can be displayed in the supervisor's dashboard.</p>
 *
 * <p>GET /lecturer/report — Redirects to the lecturer dashboard where the
 * rate-tasks section can be found.</p>
 */
public class LecturerReportServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(LecturerReportServlet.class.getName());

    private final LecturerReportDAO reportDAO  = new LecturerReportDAO();
    private final CleaningTaskDAO   taskDAO    = new CleaningTaskDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.sendRedirect(req.getContextPath() + "/lecturer/dashboard");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("loggedInUser");
        if (user.getRole() != User.Role.lecturer) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String taskIdStr    = req.getParameter("taskId");
        String ratingStr    = req.getParameter("rating");
        String reportText   = req.getParameter("reportText");

        // Basic validation
        if (taskIdStr == null || ratingStr == null || reportText == null
                || reportText.trim().isEmpty()) {
            session.setAttribute("reportError", "All fields (task, rating, report text) are required.");
            resp.sendRedirect(req.getContextPath() + "/lecturer/dashboard");
            return;
        }

        int taskId, rating;
        try {
            taskId = Integer.parseInt(taskIdStr);
            rating = Integer.parseInt(ratingStr);
        } catch (NumberFormatException e) {
            session.setAttribute("reportError", "Invalid task or rating value.");
            resp.sendRedirect(req.getContextPath() + "/lecturer/dashboard");
            return;
        }

        if (rating < 1 || rating > 5) {
            session.setAttribute("reportError", "Rating must be between 1 and 5.");
            resp.sendRedirect(req.getContextPath() + "/lecturer/dashboard");
            return;
        }

        try {
            // Confirm the task exists and is completed
            CleaningTask task = taskDAO.findById(taskId);
            if (task == null || task.getStatus() != CleaningTask.Status.completed) {
                session.setAttribute("reportError", "You can only rate completed cleaning tasks.");
                resp.sendRedirect(req.getContextPath() + "/lecturer/dashboard");
                return;
            }

            // Prevent duplicate reports from the same lecturer for the same task
            if (reportDAO.existsForTask(taskId, user.getId())) {
                session.setAttribute("reportError", "You have already submitted a report for this task.");
                resp.sendRedirect(req.getContextPath() + "/lecturer/dashboard");
                return;
            }

            LecturerReport report = new LecturerReport();
            report.setTaskId(taskId);
            report.setLecturerId(user.getId());
            report.setRating(rating);
            report.setReportText(reportText.trim());
            reportDAO.create(report);

            session.setAttribute("reportSuccess", "Your report has been submitted successfully.");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error saving lecturer report for user " + user.getId(), e);
            session.setAttribute("reportError", "Failed to save report. Please try again.");
        }

        resp.sendRedirect(req.getContextPath() + "/lecturer/dashboard");
    }
}
