package com.smartcampus.servlet;

import com.smartcampus.dao.UserDAO;
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
import java.time.Year;

/**
 * Handles new user self-registration.
 * GET  → redirect to home (login page).
 * POST → validate inputs, create account, then redirect to login with a success flash.
 * Mapped to /register in web.xml.
 */
public class RegisterServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(RegisterServlet.class.getName());
    private final UserDAO userDAO = new UserDAO();
    private final FacilityDAO facilityDAO = new FacilityDAO();

    /** GET: redirect to the home/login page. */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.sendRedirect(req.getContextPath() + "/");
    }

    /** POST: process the registration form. */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String name            = req.getParameter("name");
        String email           = req.getParameter("email");
        String phone           = req.getParameter("phone");
        String gender          = req.getParameter("gender");
        String roleStr         = req.getParameter("role");
        String department      = req.getParameter("department");
        String password        = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        // ── Server-side validation ────────────────────────────────────────────
        if (!ValidationUtil.isValidName(name)) {
            forward(req, resp, "Full name must be at least 2 characters.", name, email, phone, gender, roleStr, department);
            return;
        }
        if (!ValidationUtil.isValidEmail(email)) {
            forward(req, resp, "Email must be in the format name.role@egerton.ac.ke (e.g. john.lecturer@egerton.ac.ke).",
                    name, email, phone, gender, roleStr, department);
            return;
        }
        if (!ValidationUtil.isValidPhoneOrBlank(phone) || ValidationUtil.isBlank(phone)) {
            forward(req, resp, "Please enter a valid phone number.", name, email, phone, gender, roleStr, department);
            return;
        }
        if (!ValidationUtil.isValidPassword(password)) {
            forward(req, resp, "Password must be at least 6 characters.", name, email, phone, gender, roleStr, department);
            return;
        }
        if (!password.equals(confirmPassword)) {
            forward(req, resp, "Passwords do not match.", name, email, phone, gender, roleStr, department);
            return;
        }

        User.Role role;
        try {
            role = User.Role.valueOf(roleStr);
        } catch (IllegalArgumentException | NullPointerException e) {
            forward(req, resp, "Please select a valid role.", name, email, phone, gender, roleStr, department);
            return;
        }

        // Verify that the role suffix in the email matches the selected role
        if (!ValidationUtil.isEmailRoleMatch(email, role.name())) {
            forward(req, resp,
                    "Your email role suffix must match your selected role. "
                    + "For a " + role.name() + " account use: yourname." + role.name() + "@egerton.ac.ke",
                    name, email, phone, gender, roleStr, department);
            return;
        }

        // Build department string that combines optional role-specific metadata
        String staffId     = req.getParameter("staffId");
        String wing        = req.getParameter("wing");
        String officeNumber = req.getParameter("officeNumber");
        String floor       = req.getParameter("floor");

        if (role == User.Role.lecturer) {
            if (ValidationUtil.isBlank(officeNumber) || ValidationUtil.isBlank(wing) || ValidationUtil.isBlank(floor)) {
                forward(req, resp, "Please provide the lecturer office number, wing, and floor.",
                        name, email, phone, gender, roleStr, department);
                return;
            }
        }

        // Validate staff ID for roles that require it
        if (role == User.Role.janitor || role == User.Role.admin || role == User.Role.supervisor) {
            if (!ValidationUtil.isValidStaffId(staffId, role.name())) {
                String prefix = ValidationUtil.getStaffIdPrefix(role.name());
                int currentYear = Year.now().getValue();
                forward(req, resp,
                        "Staff ID is required and must follow the format " + prefix + "-YYYY-NNN "
                        + "(e.g., " + prefix + "-2024-001), where YYYY cannot be greater than " + currentYear + ".",
                        name, email, phone, gender, roleStr, department);
                return;
            }
        }

        String deptValue = buildDepartment(role, department, staffId, wing, officeNumber, floor);

        User user = new User();
        user.setName(name.trim());
        user.setEmail(email.trim().toLowerCase());
        user.setPhone(phone.trim());
        user.setRole(role);
        user.setDepartment(deptValue);
        if (staffId != null && !staffId.trim().isEmpty()) {
            user.setStaffId(staffId.trim().toUpperCase());
        }
        user.setActive(true);

        try {
            int userId = userDAO.create(user, password);
            user.setId(userId);

            if (role == User.Role.lecturer) {
                try {
                    createLecturerOffice(userId, officeNumber, wing, floor);
                } catch (SQLException officeError) {
                    try {
                        userDAO.delete(userId);
                    } catch (SQLException cleanupError) {
                        LOGGER.log(Level.WARNING, "Failed to roll back lecturer signup after office creation error", cleanupError);
                    }
                    throw officeError;
                }
            }

            LOGGER.log(Level.INFO, "New user registered: {0} [{1}]", new Object[]{email, role});

            // Flash success message in session, then redirect to login
            req.getSession(true).setAttribute("registerSuccess",
                    "Account created successfully! You can now sign in.");
            resp.sendRedirect(req.getContextPath() + "/login");

        } catch (IllegalArgumentException e) {
            // Duplicate email
            forward(req, resp, "That email address is already registered.", name, email, phone, gender, roleStr, department);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error during registration", e);
            forward(req, resp, "A system error occurred. Please try again later.", name, email, phone, gender, roleStr, department);
        }
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private void forward(HttpServletRequest req, HttpServletResponse resp,
                         String error, String name, String email,
                         String phone, String gender, String role, String department)
            throws ServletException, IOException {

        req.setAttribute("registerError",  error);
        req.setAttribute("activeTab",      "signup");
        req.setAttribute("regName",        name    != null ? name    : "");
        req.setAttribute("regEmail",       email   != null ? email   : "");
        req.setAttribute("regPhone",       phone   != null ? phone   : "");
        req.setAttribute("regGender",      gender  != null ? gender  : "");
        req.setAttribute("regRole",        role    != null ? role    : "lecturer");
        req.setAttribute("regDepartment",  department != null ? department : "");
        req.getRequestDispatcher("/index.jsp").forward(req, resp);
    }

    private String buildDepartment(User.Role role, String department,
                                   String staffId, String wing,
                                   String officeNumber, String floor) {
        StringBuilder sb = new StringBuilder();
        if (department != null && !department.trim().isEmpty()) {
            sb.append(department.trim());
        }
        if (staffId != null && !staffId.trim().isEmpty()) {
            if (sb.length() > 0) sb.append("; ");
            sb.append("Staff ID: ").append(staffId.trim().toUpperCase());
        }
        if (wing != null && !wing.trim().isEmpty()) {
            if (sb.length() > 0) sb.append("; ");
            sb.append("Wing: ").append(wing.trim());
        }
        if (officeNumber != null && !officeNumber.trim().isEmpty()) {
            if (sb.length() > 0) sb.append("; ");
            sb.append("Office: ").append(officeNumber.trim());
        }
        if (floor != null && !floor.trim().isEmpty()) {
            if (sb.length() > 0) sb.append("; ");
            sb.append("Floor: ").append(floor.trim());
        }
        return sb.length() > 0 ? sb.toString() : null;
    }

    private void createLecturerOffice(int lecturerId, String officeNumber, String wing, String floor) throws SQLException {
        String officeName = officeNumber.trim().toUpperCase();
        String officeLocation = "Wing " + wing.trim().toUpperCase();

        Facility existingOffice = facilityDAO.findByNameAndLocation(officeName, officeLocation);
        if (existingOffice != null && existingOffice.getAssignedLecturerId() != null) {
            throw new SQLException("This office is already assigned to another lecturer.");
        }

        if (existingOffice != null) {
            if (!facilityDAO.assignLecturer(existingOffice.getId(), lecturerId)) {
                throw new SQLException("Failed to assign the existing office to the lecturer.");
            }
            return;
        }

        Facility office = new Facility();
        office.setName(officeName);
        office.setLocation(officeLocation);
        office.setFacilityType(Facility.FacilityType.office);
        office.setCapacity(1);
        office.setStatus(Facility.Status.occupied);
        office.setDescription("Lecturer office auto-created during signup; Floor: " + floor.trim());
        office.setAssignedLecturerId(lecturerId);
        facilityDAO.create(office);
    }
}
