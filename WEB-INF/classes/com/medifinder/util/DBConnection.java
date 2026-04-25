package com.medifinder.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public final class DBConnection {

    private static final String URL = "jdbc:postgresql://localhost:5432/medifinder_db";
    private static final String USERNAME = "postgres";
    private static final String PASSWORD = "password";

    private DBConnection() {
        // Utility class; prevent instantiation.
    }

    public static Connection getConnection() {
        try {
            Class.forName("org.postgresql.Driver");
            return DriverManager.getConnection(URL, USERNAME, PASSWORD);
        } catch (ClassNotFoundException e) {
            throw new IllegalStateException("PostgreSQL JDBC driver not found in classpath.", e);
        } catch (SQLException e) {
            throw new IllegalStateException("Failed to connect to PostgreSQL database: " + URL, e);
        }
    }
}
