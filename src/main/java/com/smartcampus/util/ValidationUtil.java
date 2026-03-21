package com.smartcampus.util;

import java.util.regex.Pattern;

/**
 * Common input-validation helpers.
 * All methods are stateless and thread-safe.
 */
public final class ValidationUtil {

    /** RFC-5322-inspired email pattern (pragmatic subset). */
    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[a-zA-Z0-9._%+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}$");

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

    /** Returns {@code true} when {@code email} matches a valid email pattern. */
    public static boolean isValidEmail(String email) {
        return isNotBlank(email) && EMAIL_PATTERN.matcher(email.trim()).matches();
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
     * Rules: 2–150 characters, not blank.
     */
    public static boolean isValidName(String name) {
        if (isBlank(name)) return false;
        int len = name.trim().length();
        return len >= 2 && len <= 150;
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
