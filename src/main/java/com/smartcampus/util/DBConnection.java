package com.smartcampus.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Database connection utility for the SmartCampus application.
 * Reads connection parameters from system properties / environment variables
 * so that the application can be configured without recompilation.
 *
 * Environment / JVM system properties:
 *   DB_URL      – full JDBC URL  (default: jdbc:mysql://localhost:3306/smartcampus?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true)
 *   DB_USER     – database username (default: root)
 *   DB_PASSWORD – database password (default: empty string)
 */
public class DBConnection {

    private static final Logger LOGGER = Logger.getLogger(DBConnection.class.getName());

    private static final String DEFAULT_URL  = "jdbc:mysql://localhost:3306/smartcampus"
            + "?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&characterEncoding=UTF-8";
    private static final String DEFAULT_USER = "root";
    private static final String DEFAULT_PASS = "@Has10201";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "MySQL JDBC driver not found on classpath", e);
            throw new ExceptionInInitializerError(e);
        }
    }

    private DBConnection() {
        // utility class – not instantiable
    }

    /**
     * Returns a new JDBC {@link Connection}. The caller is responsible for
     * closing it (preferably in a try-with-resources block).
     *
     * @return a live database connection
     * @throws SQLException if a connection cannot be established
     */
    public static Connection getConnection() throws SQLException {
        String url  = getProperty("DB_URL",      DEFAULT_URL);
        String user = getProperty("DB_USER",     DEFAULT_USER);
        String pass = getProperty("DB_PASSWORD", DEFAULT_PASS);
        return DriverManager.getConnection(url, user, pass);
    }

    /** Returns a system property, falling back to an environment variable, then to the default. */
    private static String getProperty(String key, String defaultValue) {
        String value = System.getProperty(key);
        if (value == null || value.isEmpty()) {
            value = System.getenv(key);
        }
        return (value != null && !value.isEmpty()) ? value : defaultValue;
    }

    /**
     * Silently closes a {@link Connection}, logging any {@link SQLException}.
     *
     * @param connection the connection to close (may be {@code null})
     */
    public static void close(Connection connection) {
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Error closing database connection", e);
            }
        }
    }
}
