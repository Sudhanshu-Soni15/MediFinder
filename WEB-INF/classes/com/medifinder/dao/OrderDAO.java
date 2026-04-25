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

public class OrderDAO {
    private static final String ORDERS_TABLE = "public.mf_orders";
    private static final String ORDER_ITEMS_TABLE = "public.mf_order_items";

    public void ensureTables() {
        String ordersSql = "CREATE TABLE IF NOT EXISTS " + ORDERS_TABLE + " ("
                + "order_id VARCHAR(60) PRIMARY KEY, "
                + "user_email VARCHAR(255) NOT NULL, "
                + "user_name VARCHAR(255), "
                + "pharmacy_name VARCHAR(255), "
                + "pharmacy_email VARCHAR(255), "
                + "delivery_type VARCHAR(80), "
                + "pickup_time VARCHAR(100), "
                + "address TEXT, "
                + "delivery_time VARCHAR(100), "
                + "delivery_charge NUMERIC(12,2) DEFAULT 0, "
                + "payment_method VARCHAR(40), "
                + "payment_status VARCHAR(40), "
                + "status VARCHAR(40), "
                + "total_price NUMERIC(12,2), "
                + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
                + ")";

        String orderItemsSql = "CREATE TABLE IF NOT EXISTS " + ORDER_ITEMS_TABLE + " ("
                + "id SERIAL PRIMARY KEY, "
                + "order_id VARCHAR(60) NOT NULL REFERENCES " + ORDERS_TABLE + "(order_id) ON DELETE CASCADE, "
                + "medicine_id VARCHAR(60), "
                + "name VARCHAR(255), "
                + "strip_info VARCHAR(255), "
                + "tablets_per_strip INT DEFAULT 10, "
                + "quantity INT DEFAULT 1, "
                + "price NUMERIC(12,2) DEFAULT 0"
                + ")";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement ordersStatement = connection.prepareStatement(ordersSql);
             PreparedStatement itemsStatement = connection.prepareStatement(orderItemsSql)) {
            ordersStatement.execute();
            itemsStatement.execute();
        } catch (SQLException e) {
            throw new IllegalStateException("Failed to ensure order tables.", e);
        }
    }

    public boolean placeOrder(Map<String, Object> order) {
        ensureTables();

        String insertOrderSql = "INSERT INTO " + ORDERS_TABLE + " "
                + "(order_id, user_email, user_name, pharmacy_name, pharmacy_email, delivery_type, "
                + "pickup_time, address, delivery_time, delivery_charge, payment_method, payment_status, status, total_price) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        String insertItemSql = "INSERT INTO " + ORDER_ITEMS_TABLE + " "
                + "(order_id, medicine_id, name, strip_info, tablets_per_strip, quantity, price) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        List<Map<String, String>> items = castItems(order.get("items"));

        try (Connection connection = DBConnection.getConnection()) {
            connection.setAutoCommit(false);
            try (PreparedStatement orderStatement = connection.prepareStatement(insertOrderSql);
                 PreparedStatement itemStatement = connection.prepareStatement(insertItemSql)) {

                orderStatement.setString(1, asString(order.get("orderId")));
                orderStatement.setString(2, asString(order.get("userEmail")));
                orderStatement.setString(3, asString(order.get("userName")));
                orderStatement.setString(4, asString(order.get("pharmacyName")));
                orderStatement.setString(5, asString(order.get("pharmacyEmail")));
                orderStatement.setString(6, asString(order.get("deliveryType")));
                orderStatement.setString(7, asString(order.get("pickupTime")));
                orderStatement.setString(8, asString(order.get("address")));
                orderStatement.setString(9, asString(order.get("deliveryTime")));
                orderStatement.setDouble(10, asDouble(order.get("deliveryCharge")));
                orderStatement.setString(11, asString(order.get("paymentMethod")));
                orderStatement.setString(12, asString(order.get("paymentStatus")));
                orderStatement.setString(13, asString(order.get("status")));
                orderStatement.setDouble(14, asDouble(order.get("totalPrice")));
                orderStatement.executeUpdate();

                for (Map<String, String> item : items) {
                    itemStatement.setString(1, asString(order.get("orderId")));
                    itemStatement.setString(2, value(item, "id"));
                    itemStatement.setString(3, value(item, "name"));
                    itemStatement.setString(4, value(item, "stripInfo"));
                    itemStatement.setInt(5, asInt(item.get("tabletsPerStrip"), 10));
                    itemStatement.setInt(6, asInt(item.get("quantity"), 1));
                    itemStatement.setDouble(7, asDouble(item.get("price")));
                    itemStatement.addBatch();
                }
                itemStatement.executeBatch();

                connection.commit();
                return true;
            } catch (Exception e) {
                connection.rollback();
                throw e;
            } finally {
                connection.setAutoCommit(true);
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Failed to place order in database: " + e.getMessage(), e);
        }
    }

    public List<Map<String, Object>> getUserOrders(String userEmail) {
        ensureTables();
        List<Map<String, Object>> orders = new ArrayList<Map<String, Object>>();

        String ordersSql = "SELECT order_id, user_email, user_name, pharmacy_name, pharmacy_email, "
                + "delivery_type, pickup_time, address, delivery_time, delivery_charge, payment_method, "
                + "payment_status, status, total_price "
                + "FROM " + ORDERS_TABLE + " WHERE user_email = ? ORDER BY created_at DESC";

        String itemsSql = "SELECT medicine_id, name, strip_info, tablets_per_strip, quantity, price "
                + "FROM " + ORDER_ITEMS_TABLE + " WHERE order_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement ordersStatement = connection.prepareStatement(ordersSql);
             PreparedStatement itemsStatement = connection.prepareStatement(itemsSql)) {
            ordersStatement.setString(1, userEmail);

            try (ResultSet orderResult = ordersStatement.executeQuery()) {
                while (orderResult.next()) {
                    Map<String, Object> order = new LinkedHashMap<String, Object>();
                    String orderId = value(orderResult, "order_id");
                    order.put("orderId", orderId);
                    order.put("userEmail", value(orderResult, "user_email"));
                    order.put("userName", value(orderResult, "user_name"));
                    order.put("pharmacyName", value(orderResult, "pharmacy_name"));
                    order.put("pharmacyEmail", value(orderResult, "pharmacy_email"));
                    order.put("deliveryType", value(orderResult, "delivery_type"));
                    order.put("pickupTime", value(orderResult, "pickup_time"));
                    order.put("address", value(orderResult, "address"));
                    order.put("deliveryTime", value(orderResult, "delivery_time"));
                    order.put("deliveryCharge", value(orderResult, "delivery_charge"));
                    order.put("paymentMethod", value(orderResult, "payment_method"));
                    order.put("paymentStatus", value(orderResult, "payment_status"));
                    order.put("status", value(orderResult, "status"));
                    order.put("totalPrice", value(orderResult, "total_price"));

                    List<Map<String, String>> items = new ArrayList<Map<String, String>>();
                    itemsStatement.setString(1, orderId);
                    try (ResultSet itemResult = itemsStatement.executeQuery()) {
                        while (itemResult.next()) {
                            Map<String, String> item = new LinkedHashMap<String, String>();
                            item.put("id", value(itemResult, "medicine_id"));
                            item.put("name", value(itemResult, "name"));
                            item.put("stripInfo", value(itemResult, "strip_info"));
                            item.put("tabletsPerStrip", value(itemResult, "tablets_per_strip"));
                            item.put("quantity", value(itemResult, "quantity"));
                            item.put("price", value(itemResult, "price"));
                            items.add(item);
                        }
                    }
                    order.put("items", items);
                    orders.add(order);
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Failed to load user orders from database.", e);
        }

        return orders;
    }

    public String getOrderStatusForUser(String orderId, String userEmail) {
        ensureTables();
        String sql = "SELECT status FROM " + ORDERS_TABLE + " WHERE order_id = ? AND user_email = ?";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, orderId);
            statement.setString(2, userEmail);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return value(resultSet, "status");
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Failed to check order status.", e);
        }
        return null;
    }

    public boolean cancelOrder(String orderId, String userEmail) {
        ensureTables();
        String sql = "UPDATE " + ORDERS_TABLE + " SET status = 'CANCELLED' "
                + "WHERE order_id = ? AND user_email = ? AND status NOT IN ('CANCELLED', 'COMPLETED')";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, orderId);
            statement.setString(2, userEmail);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new IllegalStateException("Failed to cancel order.", e);
        }
    }
    

    public List<Map<String, Object>> getPharmacyOrders(String pharmacyEmail) {
    ensureTables();
    List<Map<String, Object>> orders = new ArrayList<Map<String, Object>>();

    String ordersSql = "SELECT order_id, user_email, user_name, pharmacy_name, pharmacy_email, "
            + "delivery_type, pickup_time, address, delivery_time, delivery_charge, payment_method, "
            + "payment_status, status, total_price "
            + "FROM " + ORDERS_TABLE + " WHERE pharmacy_email = ? ORDER BY created_at DESC";

    String itemsSql = "SELECT medicine_id, name, strip_info, tablets_per_strip, quantity, price "
            + "FROM " + ORDER_ITEMS_TABLE + " WHERE order_id = ?";

    try (Connection connection = DBConnection.getConnection();
         PreparedStatement ordersStatement = connection.prepareStatement(ordersSql);
         PreparedStatement itemsStatement = connection.prepareStatement(itemsSql)) {
        ordersStatement.setString(1, pharmacyEmail);

        try (ResultSet orderResult = ordersStatement.executeQuery()) {
            while (orderResult.next()) {
                Map<String, Object> order = new LinkedHashMap<String, Object>();
                String orderId = value(orderResult, "order_id");
                order.put("orderId", orderId);
                order.put("userEmail", value(orderResult, "user_email"));
                order.put("userName", value(orderResult, "user_name"));
                order.put("pharmacyName", value(orderResult, "pharmacy_name"));
                order.put("pharmacyEmail", value(orderResult, "pharmacy_email"));
                order.put("deliveryType", value(orderResult, "delivery_type"));
                order.put("pickupTime", value(orderResult, "pickup_time"));
                order.put("address", value(orderResult, "address"));
                order.put("deliveryTime", value(orderResult, "delivery_time"));
                order.put("deliveryCharge", value(orderResult, "delivery_charge"));
                order.put("paymentMethod", value(orderResult, "payment_method"));
                order.put("paymentStatus", value(orderResult, "payment_status"));
                order.put("status", value(orderResult, "status"));
                order.put("totalPrice", value(orderResult, "total_price"));

                List<Map<String, String>> items = new ArrayList<Map<String, String>>();
                itemsStatement.setString(1, orderId);
                try (ResultSet itemResult = itemsStatement.executeQuery()) {
                    while (itemResult.next()) {
                        Map<String, String> item = new LinkedHashMap<String, String>();
                        item.put("id", value(itemResult, "medicine_id"));
                        item.put("name", value(itemResult, "name"));
                        item.put("stripInfo", value(itemResult, "strip_info"));
                        item.put("tabletsPerStrip", value(itemResult, "tablets_per_strip"));
                        item.put("quantity", value(itemResult, "quantity"));
                        item.put("price", value(itemResult, "price"));
                        items.add(item);
                    }
                }
                order.put("items", items);
                orders.add(order);
            }
        }
    } catch (SQLException e) {
        throw new IllegalStateException("Failed to load pharmacy orders from database.", e);
    }

    return orders;
}

public boolean updateOrderStatus(String orderId, String pharmacyEmail, String newStatus) {
    ensureTables();
    String sql = "UPDATE " + ORDERS_TABLE + " SET status = ? "
            + "WHERE order_id = ? AND pharmacy_email = ?";
    try (Connection connection = DBConnection.getConnection();
         PreparedStatement statement = connection.prepareStatement(sql)) {
        statement.setString(1, newStatus);
        statement.setString(2, orderId);
        statement.setString(3, pharmacyEmail);
        return statement.executeUpdate() > 0;
    } catch (SQLException e) {
        throw new IllegalStateException("Failed to update order status.", e);
    }
}

    @SuppressWarnings("unchecked")
    private List<Map<String, String>> castItems(Object value) {
        if (value instanceof List<?>) {
            return (List<Map<String, String>>) value;
        }
        return new ArrayList<Map<String, String>>();
    }

    private String value(ResultSet resultSet, String column) throws SQLException {
        String value = resultSet.getString(column);
        return value == null ? "" : value;
    }

    private String value(Map<String, String> map, String key) {
        String value = map.get(key);
        return value == null ? "" : value;
    }

    private String asString(Object value) {
        return value == null ? "" : String.valueOf(value);
    }

    private double asDouble(Object value) {
        if (value == null) {
            return 0.0;
        }
        try {
            return Double.parseDouble(String.valueOf(value));
        } catch (Exception e) {
            return 0.0;
        }
    }

    private int asInt(String value, int defaultValue) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return defaultValue;
        }
    }
}
