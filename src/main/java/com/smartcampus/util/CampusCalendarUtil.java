package com.smartcampus.util;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.MonthDay;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Calendar helpers for lecturer check-in and cleaning visibility.
 */
public final class CampusCalendarUtil {

    private CampusCalendarUtil() {}

    /** Returns {@code true} when the date falls on Saturday or Sunday. */
    public static boolean isWeekend(LocalDate date) {
        DayOfWeek dayOfWeek = date.getDayOfWeek();
        return dayOfWeek == DayOfWeek.SATURDAY || dayOfWeek == DayOfWeek.SUNDAY;
    }

    /** Returns {@code true} when the date is a supported public holiday. */
    public static boolean isPublicHoliday(LocalDate date) {
        return getPublicHolidayName(date) != null;
    }

    /** Returns {@code true} when the date is a working day (weekday and not a public holiday). */
    public static boolean isWorkingDay(LocalDate date) {
        return !isWeekend(date) && !isPublicHoliday(date);
    }

    /** Returns a human-readable message for the current date, or an empty string on working days. */
    public static String getDayNotice(LocalDate date) {
        String holidayName = getPublicHolidayName(date);
        if (holidayName != null) {
            return "Today is a public holiday: " + holidayName + ".";
        }
        if (isWeekend(date)) {
            return "Today is on a weekend.";
        }
        return "";
    }

    /** Returns the public holiday name, or {@code null} if the date is not a holiday. */
    public static String getPublicHolidayName(LocalDate date) {
        Map<MonthDay, String> fixedHolidays = new LinkedHashMap<>();
        fixedHolidays.put(MonthDay.of(1, 1), "New Year's Day");
        fixedHolidays.put(MonthDay.of(5, 1), "Labour Day");
        fixedHolidays.put(MonthDay.of(6, 1), "Madaraka Day");
        fixedHolidays.put(MonthDay.of(10, 20), "Mashujaa Day");
        fixedHolidays.put(MonthDay.of(12, 12), "Jamhuri Day");
        fixedHolidays.put(MonthDay.of(12, 25), "Christmas Day");
        fixedHolidays.put(MonthDay.of(12, 26), "Boxing Day");

        String fixedHolidayName = fixedHolidays.get(MonthDay.from(date));
        if (fixedHolidayName != null) {
            return fixedHolidayName;
        }

        LocalDate easterSunday = calculateEasterSunday(date.getYear());
        if (date.equals(easterSunday.minusDays(2))) {
            return "Good Friday";
        }
        if (date.equals(easterSunday.plusDays(1))) {
            return "Easter Monday";
        }

        return null;
    }

    /** Calculates Easter Sunday using the Anonymous Gregorian algorithm. */
    private static LocalDate calculateEasterSunday(int year) {
        int a = year % 19;
        int b = year / 100;
        int c = year % 100;
        int d = b / 4;
        int e = b % 4;
        int f = (b + 8) / 25;
        int g = (b - f + 1) / 3;
        int h = (19 * a + b - d - g + 15) % 30;
        int i = c / 4;
        int k = c % 4;
        int l = (32 + 2 * e + 2 * i - h - k) % 7;
        int m = (a + 11 * h + 22 * l) / 451;
        int month = (h + l - 7 * m + 114) / 31;
        int day = ((h + l - 7 * m + 114) % 31) + 1;
        return LocalDate.of(year, month, day);
    }
}