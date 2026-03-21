package com.smartcampus.servlet;

import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Terminates the user session and redirects to the login page.
 * Mapped to /logout in web.xml.
 */
public class LogoutServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(LogoutServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        doLogout(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        doLogout(req, resp);
    }

    private void doLogout(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session != null) {
            String userName = (String) session.getAttribute("userName");
            LOGGER.log(Level.INFO, "User logged out: {0}", userName);
            session.invalidate();
        }

        // Expire the JSESSIONID cookie explicitly (belt-and-suspenders alongside session.invalidate())
        Cookie[] cookies = req.getCookies();
        if (cookies != null) {
            for (Cookie c : cookies) {
                if ("JSESSIONID".equals(c.getName())) {
                    c.setMaxAge(0);
                    c.setPath(req.getContextPath().isEmpty() ? "/" : req.getContextPath());
                    c.setHttpOnly(true);
                    c.setSecure(req.isSecure()); // honour the scheme of the current request
                    resp.addCookie(c);
                }
            }
        }

        resp.sendRedirect(req.getContextPath() + "/login");
    }
}
