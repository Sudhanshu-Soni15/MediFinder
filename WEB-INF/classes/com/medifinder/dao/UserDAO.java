package com.medifinder.dao;

import com.medifinder.util.DBConnection;
import java.sql.*;

public class UserDAO {

    // Returns null if email already exists, else returns the new user's name
    public String registerUser(String name, String email, String phone, String password) {
        String checkSql = "SELECT user_id FROM users WHERE email = ?";
        String insertSql = "INSERT INTO users (name, email, phone, password, role) VALUES (?, ?, ?, ?, 'USER')";

        try (Connection conn = DBConnection.getConnection()) {

            // Check duplicate email
            try (PreparedStatement check = conn.prepareStatement(checkSql)) {
                check.setString(1, email);
                try (ResultSet rs = check.executeQuery()) {
                    if (rs.next()) return null; // email already taken
                }
            }

            // Insert new user
            try (PreparedStatement insert = conn.prepareStatement(insertSql)) {
                insert.setString(1, name);
                insert.setString(2, email);
                insert.setString(3, phone);
                insert.setString(4, password); // hash in production!
                insert.executeUpdate();
            }

            return name;

        } catch (SQLException e) {
            throw new IllegalStateException("Failed to register user.", e);
        }
    }

    // Returns role ("USER") if credentials match, null if not found
    public String[] loginUser(String email, String password) {
        String sql = "SELECT name, role FROM users WHERE email = ? AND password = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new String[]{ rs.getString("name"), rs.getString("role") };
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Failed to login user.", e);
        }
        return null;
    }
}