package com.smartcampus.servlet;

import com.smartcampus.dao.FacilityDAO;
import com.smartcampus.dao.MaintenanceRequestDAO;
import com.smartcampus.dao.UserDAO;
import com.smartcampus.dao.CleaningTaskDAO;
import com.smartcampus.model.CleaningTask;
import com.smartcampus.model.Facility;
import com.smartcampus.model.MaintenanceRequest;
import com.smartcampus.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Resolves the dashboard URL for the currently logged-in user's role and
 * pre-loads summary statistics before forwarding to the appropriate JSP.
 * Mapped to /admin/dashboard, /lecturer/dashboard, /janitor/dashboard,
 * /supervisor/dashboard in web.xml.
 */
public class DashboardServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(DashboardServlet.class.getName());

    private final UserDAO                userDAO   = new UserDAO();
    private final FacilityDAO            facDAO    = new FacilityDAO();
    private final MaintenanceRequestDAO  mrDAO     = new MaintenanceRequestDAO();
    private final CleaningTaskDAO        ctDAO     = new CleaningTaskDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("loggedInUser");
        String jspPath;

        try {
            switch (user.getRole()) {
                case admin:
                    req.setAttribute("totalUsers",       userDAO.count());
                    req.setAttribute("totalFacilities",  facDAO.count());
                    req.setAttribute("pendingRequests",  ctDAO.countByStatus(CleaningTask.Status.pending));
                    req.setAttribute("activeFacilities", facDAO.countByStatus(Facility.Status.available));
                    req.setAttribute("completedToday",   ctDAO.countCompletedToday());
                    req.setAttribute("allUsers",         userDAO.findAll());
                    req.setAttribute("allFacilities",    facDAO.findAll());
                    jspPath = "/WEB-INF/views/admin/dashboard.jsp";
                    break;
                case lecturer:
                    req.setAttribute("myRequests",    mrDAO.findByReporter(user.getId()));
                    req.setAttribute("facilities",    facDAO.findByStatus(Facility.Status.available));
                    req.setAttribute("pendingCount",  mrDAO.countByStatus(MaintenanceRequest.Status.pending));
                    jspPath = "/WEB-INF/views/lecturer/dashboard.jsp";
                    break;
                case janitor:
                    req.setAttribute("myTasks",       ctDAO.findByJanitor(user.getId()));
                    req.setAttribute("todayCount",    ctDAO.countTodayByJanitor(user.getId()));
                    req.setAttribute("assignedRequests", mrDAO.findByAssignee(user.getId()));
                    jspPath = "/WEB-INF/views/janitor/dashboard.jsp";
                    break;
                case supervisor:
                    req.setAttribute("allRequests",   mrDAO.findAll());
                    req.setAttribute("allTasks",      ctDAO.findAll());
                    req.setAttribute("janitors",      userDAO.findByRole(User.Role.janitor));
                    req.setAttribute("pendingCount",  mrDAO.countByStatus(MaintenanceRequest.Status.pending));
                    req.setAttribute("inProgressCount", mrDAO.countByStatus(MaintenanceRequest.Status.in_progress));
                    req.setAttribute("resolvedCount", mrDAO.countByStatus(MaintenanceRequest.Status.resolved));
                    jspPath = "/WEB-INF/views/supervisor/dashboard.jsp";
                    break;
                default:
                    resp.sendRedirect(req.getContextPath() + "/login");
                    return;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error loading dashboard data for user " + user.getId(), e);
            req.setAttribute("error", "Failed to load dashboard data. Please try again.");
            jspPath = "/WEB-INF/views/error.jsp";
        }

        req.getRequestDispatcher(jspPath).forward(req, resp);
    }
}
