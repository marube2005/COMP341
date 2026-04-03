package com.smartcampus.util;

import java.util.regex.Pattern;

/**
 * Common input-validation helpers.
 * All methods are stateless and thread-safe.
 */
public final class ValidationUtil {

    /**
     * Egerton University email pattern.
     * Required format: {@code name.role@egerton.ac.ke}
     * where {@code role} is one of: admin, lecturer, janitor, supervisor.
     */
    private static final Pattern EMAIL_PATTERN =
            Pattern.compile(
                "^[a-zA-Z0-9._\\-]+\\.(admin|lecturer|janitor|supervisor)@egerton\\.ac\\.ke$",
                Pattern.CASE_INSENSITIVE);

    /** Phone: optional leading +, digits, dashes, spaces, parentheses, 7–15 chars. */
    private static final Pattern PHONE_PATTERN =
            Pattern.compile("^[+]?[\\d\\s()\\-]{7,15}$");

    private ValidationUtil() {}

    // ─── Null / blank ─────────────────────────────────────────

    /** Returns {@code true} when {@code value} is not null and not blank. */
    public static boolean isNotBlank(String value) {
        return value != null && !value.trim().isEmpty();
    }

    /** Returns {@code true} when {@code value} is null or blank. */
    public static boolean isBlank(String value) {
        return !isNotBlank(value);
    }

    // ─── Email ────────────────────────────────────────────────

    /**
     * Returns {@code true} when {@code email} follows the Egerton University
     * format {@code name.role@egerton.ac.ke} (case-insensitive).
     */
    public static boolean isValidEmail(String email) {
        return isNotBlank(email) && EMAIL_PATTERN.matcher(email.trim()).matches();
    }

    /**
     * Returns {@code true} when the role embedded in the email address matches
     * the supplied {@code role} string (case-insensitive).
     * <p>Assumes the email has already been validated with {@link #isValidEmail}.
     * Example: {@code isEmailRoleMatch("john.janitor@egerton.ac.ke", "janitor")} → {@code true}.
     *
     * @param email   a valid Egerton email address
     * @param role    the role string to compare against (e.g. "janitor", "admin")
     */
    public static boolean isEmailRoleMatch(String email, String role) {
        if (isBlank(email) || isBlank(role)) return false;
        // Extract the segment between the last '.' before '@' and '@'
        String lower = email.trim().toLowerCase();
        int atIdx = lower.indexOf('@');
        if (atIdx < 0) return false;
        int dotIdx = lower.lastIndexOf('.', atIdx - 1);
        if (dotIdx < 0) return false;
        String emailRole = lower.substring(dotIdx + 1, atIdx);
        return emailRole.equals(role.trim().toLowerCase());
    }

    /**
     * Returns the staff ID prefix for the given role, or {@code null} for roles
     * that do not use a staff ID (e.g. lecturer).
     *
     * @param role  role string: "janitor", "admin", or "supervisor"
     * @return prefix string (e.g. {@code "JAN"}) or {@code null}
     */
    public static String getStaffIdPrefix(String role) {
        if (isBlank(role)) return null;
        switch (role.trim().toLowerCase()) {
            case "janitor":    return "JAN";
            case "admin":      return "ADM";
            case "supervisor": return "SUP";
            default:           return null;
        }
    }

    /**
     * Validates a staff ID for the given role.
     * <ul>
     *   <li>Janitor    → {@code JAN-YYYY-NNN}</li>
     *   <li>Admin      → {@code ADM-YYYY-NNN}</li>
     *   <li>Supervisor → {@code SUP-YYYY-NNN}</li>
     * </ul>
     * Returns {@code false} for roles that do not require a staff ID (e.g. lecturer).
     *
     * @param staffId  the staff ID string to validate
     * @param role     the role string: "janitor", "admin", or "supervisor"
     */
    public static boolean isValidStaffId(String staffId, String role) {
        if (isBlank(staffId)) return false;
        String prefix = getStaffIdPrefix(role);
        if (prefix == null) return false;
        return staffId.trim().toUpperCase().matches(prefix + "-\\d{4}-\\d{3}");
    }

    // ─── Password ─────────────────────────────────────────────

    /**
     * Validates a plain-text password.
     * Rules:
     * <ul>
     *   <li>At least 6 characters</li>
     *   <li>No longer than 72 characters (BCrypt limit)</li>
     * </ul>
     */
    public static boolean isValidPassword(String password) {
        return password != null && password.length() >= 6 && password.length() <= 72;
    }

    // ─── Name ─────────────────────────────────────────────────

    /**
     * Validates a person or facility name.
     * Default rules: 2–150 characters, not blank.
     *
     * <p>This is a convenience overload that uses 150 as the maximum length.
     * For fields with different database/UI limits, prefer
     * {@link #isValidName(String, int)} with an explicit {@code maxLength}.
     */
    public static boolean isValidName(String name) {
        return isValidName(name, 150);
    }

    /**
     * Validates a person or facility name with a caller-specified maximum length.
     * Rules: 2–{@code maxLength} characters, not blank.
     *
     * @param name the value to validate
     * @param maxLength the maximum allowed length for {@code name}
     * @return {@code true} if {@code name} is non-blank and its trimmed length is between 2 and {@code maxLength} (inclusive)
     */
    public static boolean isValidName(String name, int maxLength) {
        if (isBlank(name)) return false;
        int len = name.trim().length();
        return len >= 2 && len <= maxLength;
    }

    // ─── Phone ────────────────────────────────────────────────

    /** Returns {@code true} when {@code phone} matches a permissive phone pattern, or is blank (optional). */
    public static boolean isValidPhoneOrBlank(String phone) {
        if (isBlank(phone)) return true;
        return PHONE_PATTERN.matcher(phone.trim()).matches();
    }

    // ─── Integer / positive integer ───────────────────────────

    /**
     * Parses an integer from a string parameter, returning {@code defaultValue} on failure.
     */
    public static int parseIntOrDefault(String value, int defaultValue) {
        if (isBlank(value)) return defaultValue;
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    /** Returns {@code true} when the value represents a positive integer (≥ 1). */
    public static boolean isPositiveInt(String value) {
        return parseIntOrDefault(value, -1) >= 1;
    }

    // ─── Length guard ─────────────────────────────────────────

    /**
     * Returns {@code true} when {@code value} is not blank and does not exceed {@code maxLength}.
     */
    public static boolean isWithinLength(String value, int maxLength) {
        return isNotBlank(value) && value.trim().length() <= maxLength;
    }
}
