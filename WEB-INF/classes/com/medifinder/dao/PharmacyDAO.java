package com.medifinder.dao;

import com.medifinder.util.DBConnection;
import java.sql.*;

public class PharmacyDAO {

    // Returns null if email already exists, else returns pharmacy name
    public String registerPharmacy(String name, String address, String phone,
                                    String email, String password, double latitude, double longitude) {
        String checkSql = "SELECT pharmacy_id FROM pharmacies WHERE email = ?";
        String insertSql = "INSERT INTO pharmacies (name, address, phone, email, password, latitude, longitude) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection()) {

            try (PreparedStatement check = conn.prepareStatement(checkSql)) {
                check.setString(1, email);
                try (ResultSet rs = check.executeQuery()) {
                    if (rs.next()) return null; // already registered
                }
            }

            try (PreparedStatement insert = conn.prepareStatement(insertSql)) {
                insert.setString(1, name);
                insert.setString(2, address);
                insert.setString(3, phone);
                insert.setString(4, email);
                insert.setString(5, password);
                insert.setDouble(6, latitude);
                insert.setDouble(7, longitude);
                insert.executeUpdate();
            }

            return name;

        } catch (SQLException e) {
            throw new IllegalStateException("Failed to register pharmacy.", e);
        }
    }

    // Returns pharmacy name if credentials match, null if not found
    public String[] loginPharmacy(String email, String password) {
        String sql = "SELECT name FROM pharmacies WHERE email = ? AND password = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new String[]{ rs.getString("name"), "PHARMACY" };
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Failed to login pharmacy.", e);
        }
        return null;
    }
}
