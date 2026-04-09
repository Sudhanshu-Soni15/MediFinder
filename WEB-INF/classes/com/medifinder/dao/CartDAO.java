package com.medifinder.dao;

import com.medifinder.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class CartDAO {
    private static final String CART_TABLE = "public.mf_cart_items";

    public void ensureTable() {
        String sql = "CREATE TABLE IF NOT EXISTS " + CART_TABLE + " ("
                + "id SERIAL PRIMARY KEY, "
                + "user_email VARCHAR(255) NOT NULL, "
                + "medicine_id VARCHAR(60) NOT NULL, "
                + "name VARCHAR(255), "
                + "price NUMERIC(12,2) DEFAULT 0, "
                + "quantity INT DEFAULT 1, "
                + "pharmacy_name VARCHAR(255), "
                + "pharmacy_email VARCHAR(255), "
                + "strip_info VARCHAR(255), "
                + "tablets_per_strip INT DEFAULT 10"
                + ")";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.execute();
        } catch (SQLException e) {
            throw new IllegalStateException("Failed to ensure cart table: " + e.getMessage(), e);
        }
    }

    public List<Map<String, String>> getCartByUser(String userEmail) {
        ensureTable();
        List<Map<String, String>> cart = new ArrayList<Map<String, String>>();
        String sql = "SELECT medicine_id, name, price, quantity, pharmacy_name, pharmacy_email, strip_info, tablets_per_strip "
                + "FROM " + CART_TABLE + " WHERE user_email = ? ORDER BY id ASC";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, userEmail);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    Map<String, String> item = new LinkedHashMap<String, String>();
                    item.put("id", value(resultSet, "medicine_id"));
                    item.put("name", value(resultSet, "name"));
                    item.put("price", value(resultSet, "price"));
                    item.put("quantity", value(resultSet, "quantity"));
                    item.put("pharmacyName", value(resultSet, "pharmacy_name"));
                    item.put("pharmacyEmail", value(resultSet, "pharmacy_email"));
                    item.put("stripInfo", value(resultSet, "strip_info"));
                    item.put("tabletsPerStrip", value(resultSet, "tablets_per_strip"));
                    cart.add(item);
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Failed to load cart from database: " + e.getMessage(), e);
        }
        return cart;
    }

    public void saveCart(String userEmail, List<Map<String, String>> cart) {
        ensureTable();
        String deleteSql = "DELETE FROM " + CART_TABLE + " WHERE user_email = ?";
        String insertSql = "INSERT INTO " + CART_TABLE + " "
                + "(user_email, medicine_id, name, price, quantity, pharmacy_name, pharmacy_email, strip_info, tablets_per_strip) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection connection = DBConnection.getConnection()) {
            connection.setAutoCommit(false);
            try (PreparedStatement deleteStatement = connection.prepareStatement(deleteSql);
                 PreparedStatement insertStatement = connection.prepareStatement(insertSql)) {
                deleteStatement.setString(1, userEmail);
                deleteStatement.executeUpdate();

                for (Map<String, String> item : cart) {
                    insertStatement.setString(1, userEmail);
                    insertStatement.setString(2, get(item, "id"));
                    insertStatement.setString(3, get(item, "name"));
                    insertStatement.setDouble(4, asDouble(get(item, "price")));
                    insertStatement.setInt(5, asInt(get(item, "quantity"), 1));
                    insertStatement.setString(6, get(item, "pharmacyName"));
                    insertStatement.setString(7, get(item, "pharmacyEmail"));
                    insertStatement.setString(8, get(item, "stripInfo"));
                    insertStatement.setInt(9, asInt(get(item, "tabletsPerStrip"), 10));
                    insertStatement.addBatch();
                }
                insertStatement.executeBatch();
                connection.commit();
            } catch (Exception e) {
                connection.rollback();
                throw e;
            } finally {
                connection.setAutoCommit(true);
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Failed to save cart in database: " + e.getMessage(), e);
        }
    }

    public void clearCart(String userEmail) {
        ensureTable();
        String sql = "DELETE FROM " + CART_TABLE + " WHERE user_email = ?";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, userEmail);
            statement.executeUpdate();
        } catch (SQLException e) {
            throw new IllegalStateException("Failed to clear cart in database: " + e.getMessage(), e);
        }
    }

    private String value(ResultSet resultSet, String column) throws SQLException {
        String value = resultSet.getString(column);
        return value == null ? "" : value;
    }

    private String get(Map<String, String> map, String key) {
        String value = map.get(key);
        return value == null ? "" : value;
    }

    private int asInt(String value, int fallback) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return fallback;
        }
    }

    private double asDouble(String value) {
        try {
            return Double.parseDouble(value);
        } catch (Exception e) {
            return 0.0;
        }
    }
}
