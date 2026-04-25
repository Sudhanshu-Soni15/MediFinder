package com.medifinder.dao;

import com.medifinder.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

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

    public List<Map<String, String>> getAllPharmacies() {
        List<Map<String, String>> pharmacies = new ArrayList<Map<String, String>>();
        String sql = "SELECT pharmacy_id, name, address, phone, email, latitude, longitude "
                + "FROM pharmacies ORDER BY pharmacy_id ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, String> row = new LinkedHashMap<String, String>();
                row.put("pharmacy_id", String.valueOf(rs.getInt("pharmacy_id")));
                row.put("name", safe(rs, "name"));
                row.put("address", safe(rs, "address"));
                row.put("phone", safe(rs, "phone"));
                row.put("email", safe(rs, "email"));
                row.put("latitude", safe(rs, "latitude"));
                row.put("longitude", safe(rs, "longitude"));
                pharmacies.add(row);
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Failed to load pharmacies.", e);
        }

        return pharmacies;
    }

    private String safe(ResultSet rs, String col) throws SQLException {
        String v = rs.getString(col);
        return v == null ? "" : v.trim();
    }
}