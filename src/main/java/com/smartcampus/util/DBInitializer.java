package com.smartcampus.util;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Scanner;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * ServletContextListener that automatically initialises the SmartCampus
 * MySQL database on application startup.
 *
 * <p>On first deployment (or when the database does not yet exist) it:
 * <ol>
 *   <li>Connects to MySQL <em>without</em> specifying a database, using the
 *       configured admin credentials.</li>
 *   <li>Reads {@code schema.sql} from the classpath (packaged in
 *       {@code WEB-INF/classes/}) and executes every SQL statement it
 *       contains.</li>
 * </ol>
 *
 * <p>Because {@code schema.sql} uses {@code CREATE DATABASE IF NOT EXISTS},
 * {@code CREATE TABLE IF NOT EXISTS}, and {@code INSERT IGNORE}, the
 * initialiser is fully <em>idempotent</em> – safe to run on every startup.
 *
 * <h3>Configuration (environment variables or JVM system properties)</h3>
 * <table>
 *   <tr><th>Variable</th><th>Default</th><th>Purpose</th></tr>
 *   <tr><td>DB_ADMIN_USER</td><td>root</td><td>MySQL user that can CREATE DATABASE</td></tr>
 *   <tr><td>DB_ADMIN_PASSWORD</td><td>root</td><td>Password for DB_ADMIN_USER</td></tr>
 *   <tr><td>DB_HOST</td><td>localhost</td><td>MySQL host</td></tr>
 *   <tr><td>DB_PORT</td><td>3306</td><td>MySQL port</td></tr>
 * </table>
 *
 * <p>This class is registered in {@code WEB-INF/web.xml} using a
 * {@code <listener>} element so that it runs before any servlet handles
 * a request.
 */
public class DBInitializer implements ServletContextListener {

    private static final Logger LOGGER = Logger.getLogger(DBInitializer.class.getName());

    /** JDBC URL template for connecting to MySQL without a specific database. */
    private static final String HOST_URL_TEMPLATE =
            "jdbc:mysql://%s:%s?useSSL=false&serverTimezone=UTC"
          + "&allowPublicKeyRetrieval=true&characterEncoding=UTF-8";

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        LOGGER.info("DBInitializer: starting database initialisation…");
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            runSchemaScript();
            LOGGER.info("DBInitializer: database initialisation complete.");
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "DBInitializer: MySQL JDBC driver not found", e);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "DBInitializer: database initialisation failed", e);
        }
    }

    // ─── Private helpers ──────────────────────────────────────

    /**
     * Connects to MySQL using admin credentials and runs the bundled
     * {@code schema.sql} script.
     */
    private void runSchemaScript() throws Exception {
        String host    = getProperty("DB_HOST",           "localhost");
        String port    = getProperty("DB_PORT",           "3306");
        String adminUser = getProperty("DB_ADMIN_USER",   "root");
        String adminPass = getProperty("DB_ADMIN_PASSWORD", "@Has10201");

        String hostUrl = String.format(HOST_URL_TEMPLATE, host, port);

        try (Connection conn = DriverManager.getConnection(hostUrl, adminUser, adminPass)) {
            executeScript(conn, "schema.sql");
        }
    }

    /**
     * Reads {@code resourceName} from the classpath, splits it on
     * {@code ;} boundaries, and executes each non-empty SQL statement.
     *
     * <p>Errors on individual statements are logged as warnings rather
     * than aborting the script, because some statements (e.g. duplicate
     * {@code INSERT IGNORE} rows or an already-existing user) may produce
     * non-fatal errors on repeated runs.
     */
    private void executeScript(Connection conn, String resourceName) throws Exception {
        InputStream is = getClass().getClassLoader().getResourceAsStream(resourceName);
        if (is == null) {
            LOGGER.warning("DBInitializer: " + resourceName
                    + " not found on classpath – skipping schema initialisation.");
            return;
        }

        String script;
        try (Scanner scanner = new Scanner(is, StandardCharsets.UTF_8)) {
            script = scanner.useDelimiter("\\A").next();
        }

        int executed = 0;
        int skipped  = 0;
        try (Statement stmt = conn.createStatement()) {
            for (String rawSql : script.split(";")) {
                // Remove comment-only lines (lines whose first non-whitespace chars are --)
                // without touching -- sequences that may appear inside string literals.
                String sql = rawSql.replaceAll("(?m)^\\s*--[^\n]*", "").strip();
                if (sql.isEmpty()) {
                    skipped++;
                    continue;
                }
                try {
                    stmt.execute(sql);
                    executed++;
                } catch (SQLException e) {
                    // Log as warning – many failures are harmless on repeated runs
                    // (e.g. "user already exists", "duplicate entry")
                    LOGGER.log(Level.WARNING,
                            "DBInitializer: statement produced a warning/error (may be harmless): "
                          + sql.substring(0, Math.min(120, sql.length())).replace('\n', ' '),
                            e);
                    skipped++;
                }
            }
        }
        LOGGER.info(String.format(
                "DBInitializer: schema.sql executed – %d statements ran, %d skipped.",
                executed, skipped));
    }

    /**
     * Returns a configuration value, checking JVM system properties first,
     * then environment variables, then falling back to {@code defaultValue}.
     */
    private static String getProperty(String key, String defaultValue) {
        String v = System.getProperty(key);
        if (v == null || v.isEmpty()) v = System.getenv(key);
        return (v != null && !v.isEmpty()) ? v : defaultValue;
    }
}
