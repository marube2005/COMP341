package com.smartcampus.servlet;

import com.smartcampus.dao.FacilityDAO;
import com.smartcampus.dao.LecturerCheckinDAO;
import com.smartcampus.model.Facility;
import com.smartcampus.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Handles lecturer daily check-in to their assigned office.
 *
 * <p>POST /lecturer/checkin – records a check-in for the logged-in lecturer and
 * redirects back to the lecturer dashboard with a success or error indicator.
 */
public class LecturerCheckinServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(LecturerCheckinServlet.class.getName());

    private final LecturerCheckinDAO checkinDAO  = new LecturerCheckinDAO();
    private final FacilityDAO        facilityDAO = new FacilityDAO();

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

        try {
            Facility office = facilityDAO.findByLecturerId(user.getId());
            if (office == null) {
                // Lecturer has no assigned office; redirect with an error indicator
                resp.sendRedirect(req.getContextPath() + "/lecturer/dashboard?checkin=no_office");
                return;
            }

            checkinDAO.checkIn(user.getId(), office.getId());
            LOGGER.log(Level.INFO, "Lecturer id={0} checked in to facility id={1}",
                    new Object[]{user.getId(), office.getId()});
            resp.sendRedirect(req.getContextPath() + "/lecturer/dashboard?checkin=success");

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "DB error during lecturer check-in for userId=" + user.getId(), e);
            resp.sendRedirect(req.getContextPath() + "/lecturer/dashboard?checkin=error");
        }
    }
}
