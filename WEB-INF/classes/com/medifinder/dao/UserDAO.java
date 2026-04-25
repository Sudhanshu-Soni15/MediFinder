package com.medifinder.dao;

import com.medifinder.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

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

 public void updateLocation(String email, double latitude, double longitude) {
    String alterSql = "ALTER TABLE users ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION, "
            + "ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION";
    String updateSql = "UPDATE users SET latitude = ?, longitude = ? WHERE email = ?";
    try (Connection conn = DBConnection.getConnection()) {
        try (PreparedStatement alter = conn.prepareStatement(alterSql)) {
            alter.execute();
        }
        try (PreparedStatement update = conn.prepareStatement(updateSql)) {
            update.setDouble(1, latitude);
            update.setDouble(2, longitude);
            update.setString(3, email);
            update.executeUpdate();
        }
    } catch (SQLException e) {
        throw new IllegalStateException("Failed to update user location.", e);
    }
}

public double[] getLocation(String email) {
    String sql = "SELECT latitude, longitude FROM users WHERE email = ?";
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, email);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                double lat = rs.getDouble("latitude");
                double lng = rs.getDouble("longitude");
                if (!rs.wasNull()) {
                    return new double[]{lat, lng};
                }
            }
        }
    } catch (SQLException e) {
        // columns may not exist yet
    }
    return null;
}

public List<Map<String, String>> getAllUsers() {
    List<Map<String, String>> users = new ArrayList<Map<String, String>>();

    // Latitude/longitude might not exist until first location update.
    String sqlWithLocation = "SELECT user_id, name, email, phone, role, latitude, longitude FROM users ORDER BY user_id ASC";
    String sqlWithoutLocation = "SELECT user_id, name, email, phone, role FROM users ORDER BY user_id ASC";

    try (Connection conn = DBConnection.getConnection()) {
        try (PreparedStatement ps = conn.prepareStatement(sqlWithLocation);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, String> row = new LinkedHashMap<String, String>();
                row.put("user_id", String.valueOf(rs.getInt("user_id")));
                row.put("name", safe(rs, "name"));
                row.put("email", safe(rs, "email"));
                row.put("phone", safe(rs, "phone"));
                row.put("role", safe(rs, "role"));
                row.put("latitude", safe(rs, "latitude"));
                row.put("longitude", safe(rs, "longitude"));
                users.add(row);
            }
        } catch (SQLException missingColumns) {
            try (PreparedStatement ps = conn.prepareStatement(sqlWithoutLocation);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> row = new LinkedHashMap<String, String>();
                    row.put("user_id", String.valueOf(rs.getInt("user_id")));
                    row.put("name", safe(rs, "name"));
                    row.put("email", safe(rs, "email"));
                    row.put("phone", safe(rs, "phone"));
                    row.put("role", safe(rs, "role"));
                    row.put("latitude", "");
                    row.put("longitude", "");
                    users.add(row);
                }
            }
        }
    } catch (SQLException e) {
        throw new IllegalStateException("Failed to load users.", e);
    }

    return users;
}

private String safe(ResultSet rs, String col) throws SQLException {
    String v = rs.getString(col);
    return v == null ? "" : v.trim();
}
}