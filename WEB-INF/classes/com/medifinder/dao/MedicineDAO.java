package com.medifinder.dao;

import com.medifinder.util.DBConnection;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class MedicineDAO {

    private static final Pattern DOSAGE_PATTERN =
            Pattern.compile("(\\d+(?:\\.\\d+)?\\s*(?:mg|ml|mcg|g))", Pattern.CASE_INSENSITIVE);

public List<Map<String, String>> searchMedicines(
        String query,
        String sort,
        String distance,
        String rating,
        boolean availability) {
    return searchMedicines(query, sort, distance, rating, availability, 0, 0);
}

public List<Map<String, String>> searchMedicines(
        String query,
        String sort,
        String distance,
        String rating,
        boolean availability,
        double userLat,
        double userLng) {

        List<Map<String, String>> medicines = new ArrayList<Map<String, String>>();

        String safeQuery = query == null ? "" : query.trim();
        String safeSort = sort == null ? "" : sort.trim().toLowerCase();
        String safeDistance = distance == null ? "" : distance.trim().toLowerCase();
        String safeRating = rating == null ? "" : rating.trim();

      boolean hasLocation = userLat != 0 && userLng != 0;
String distanceExpr = hasLocation
    ? "(6371 * acos(cos(radians(" + userLat + ")) * cos(radians(p.latitude)) "
      + "* cos(radians(p.longitude) - radians(" + userLng + ")) "
      + "+ sin(radians(" + userLat + ")) * sin(radians(p.latitude))))"
    : "m.distance";
String latitudeExpr = hasLocation ? "p.latitude" : "NULL";
String longitudeExpr = hasLocation ? "p.longitude" : "NULL";

StringBuilder sql = new StringBuilder(
        "SELECT m.medicine_id, m.medicine_name, m.price, m.stock, " 
                + distanceExpr + " AS distance, " + latitudeExpr + " AS latitude, "
                + longitudeExpr + " AS longitude, m.rating, "
                + "m.pharmacy_email, m.pharmacy_name, m.tablets_per_strip, m.strip_info "
                + "FROM public.medicines m "
                + (hasLocation ? "LEFT JOIN public.pharmacies p ON m.pharmacy_email = p.email " : "")
                + "WHERE m.medicine_name ILIKE ?");

if (availability) {
            sql.append(" AND COALESCE(m.stock, 0) > 0");
        }

        boolean filterByRating = !safeRating.isEmpty();
        if (filterByRating) {
            sql.append(" AND COALESCE(m.rating, 0) >= ?");
        }

        if ("low".equals(safeSort)) {
            sql.append(" ORDER BY COALESCE(price, 0) ASC");
        } else if ("high".equals(safeSort)) {
            sql.append(" ORDER BY COALESCE(price, 0) DESC");
        } else if ("near".equals(safeDistance)) {
            sql.append(" ORDER BY distance ASC NULLS LAST");
        } else if ("far".equals(safeDistance)) {
            sql.append(" ORDER BY distance DESC NULLS LAST");
        }

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {

            int index = 1;
            statement.setString(index++, "%" + safeQuery + "%");

            if (filterByRating) {
                statement.setDouble(index++, Double.parseDouble(safeRating));
            }

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    Map<String, String> row = new LinkedHashMap<String, String>();
                    row.put("id", value(resultSet, "medicine_id"));
                    row.put("name", value(resultSet, "medicine_name"));
                    row.put("price", safeValue(resultSet, "price", "0"));
                    row.put("stock", safeValue(resultSet, "stock", "0"));
                    row.put("distance", safeValue(resultSet, "distance", "N/A"));
                    row.put("latitude", value(resultSet, "latitude"));
                    row.put("longitude", value(resultSet, "longitude"));
                    row.put("rating", safeValue(resultSet, "rating", "N/A"));
                    row.put("pharmacyEmail", value(resultSet, "pharmacy_email"));
                    row.put("pharmacyName", value(resultSet, "pharmacy_name"));
                    row.put("tabletsPerStrip", value(resultSet, "tablets_per_strip"));
                    row.put("stripInfo", value(resultSet, "strip_info"));
                    medicines.add(row);
                }
            }

        } catch (NumberFormatException e) {
            throw new IllegalStateException("Invalid rating filter value: " + safeRating, e);
        } catch (SQLException e) {
            throw new IllegalStateException("Failed to search medicines from database.", e);
        }

        return medicines;
    }

    public Map<String, Object> getMedicineById(int id) {
        return getMedicineById(id, null, null);
    }

    public Map<String, Object> getMedicineById(int id, Double userLat, Double userLng) {
        String sql = "SELECT medicine_id, medicine_name, description, manufacturer, category, "
                + "pharmacy_name, tablets_per_strip, strip_info "
                + "FROM public.medicines WHERE medicine_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, id);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (!resultSet.next()) {
                    return null;
                }

                String medicineName = blankToNull(value(resultSet, "medicine_name"));
                Summary summary = getSummaryByMedicineName(connection, medicineName, userLat, userLng);
                int tabletsPerStrip = parseInt(
                        firstNonBlank(
                                value(resultSet, "tablets_per_strip"),
                                summary.tabletsPerStrip == null ? null : String.valueOf(summary.tabletsPerStrip)),
                        10);

                Map<String, Object> medicine = new LinkedHashMap<String, Object>();
                medicine.put("id", String.valueOf(resultSet.getInt("medicine_id")));
                medicine.put("name", firstNonBlank(medicineName, "Medicine"));
                medicine.put(
                        "description",
                        firstNonBlank(
                                value(resultSet, "description"),
                                firstNonBlank(medicineName, "This medicine")
                                        + " is available through the MediFinder pharmacy network."));
                medicine.put(
                        "manufacturer",
                        firstNonBlank(
                                value(resultSet, "manufacturer"),
                                summary.manufacturer,
                                value(resultSet, "pharmacy_name"),
                                "Partner Pharmacy"));
                medicine.put("category", firstNonBlank(value(resultSet, "category"), "General Medicine"));
                medicine.put("dosage", deriveDosage(medicineName));
                medicine.put("stripInfo", firstNonBlank(
                        value(resultSet, "strip_info"),
                        summary.stripInfo,
                        defaultStripInfo(tabletsPerStrip)));
                medicine.put("tabletsPerStrip", String.valueOf(tabletsPerStrip));
                medicine.put("prescription", "Check with pharmacy");
                medicine.put("sideEffects", "Refer to the product packaging for side effects.");
                medicine.put("usage", "Use exactly as directed on the label or by your doctor.");
                medicine.put("availableCount", formatCount(summary.totalPharmacies));
                medicine.put("lowestPrice", summary.lowestPrice == null ? "0" : formatDecimal(summary.lowestPrice));
                medicine.put("highestPrice", summary.highestPrice == null ? "0" : formatDecimal(summary.highestPrice));
                medicine.put("avgDistance", formatDistance(summary.avgDistance));
                return medicine;
            }

        } catch (SQLException e) {
            throw new IllegalStateException("Failed to load medicine details.", e);
        }
    }

    public List<Map<String, Object>> getPharmaciesByMedicineId(int id) {
        return getPharmaciesByMedicineId(id, null, null);
    }

    public List<Map<String, Object>> getPharmaciesByMedicineId(int id, Double userLat, Double userLng) {
        List<Map<String, Object>> pharmacies = new ArrayList<Map<String, Object>>();
        String medicineName = findMedicineNameById(id);
        if (medicineName == null) {
            return pharmacies;
        }

        String distanceExpr = distanceExpression(userLat, userLng, "p.latitude", "p.longitude");
        String sql = "SELECT m.pharmacy_name, m.pharmacy_email, m.price, "
                + distanceExpr + " AS distance, m.rating, m.stock "
                + "FROM public.medicines m "
                + "LEFT JOIN public.pharmacies p ON m.pharmacy_email = p.email "
                + "WHERE medicine_name = ? "
                + "AND (NULLIF(TRIM(COALESCE(m.pharmacy_name, '')), '') IS NOT NULL "
                + "OR NULLIF(TRIM(COALESCE(m.pharmacy_email, '')), '') IS NOT NULL) "
                + "ORDER BY distance ASC NULLS LAST, COALESCE(m.price, 999999), m.pharmacy_name";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, medicineName);

            BigDecimal bestPrice = null;
            List<RowSnapshot> rows = new ArrayList<RowSnapshot>();

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    String pharmacyName = blankToNull(value(resultSet, "pharmacy_name"));
                    String pharmacyEmail = blankToNull(value(resultSet, "pharmacy_email"));
                    BigDecimal price = decimal(resultSet, "price");

                    if (price != null && (bestPrice == null || price.compareTo(bestPrice) < 0)) {
                        bestPrice = price;
                    }

                    rows.add(new RowSnapshot(
                            firstNonBlank(pharmacyName, pharmacyEmail, "Partner Pharmacy"),
                            firstNonBlank(pharmacyEmail, ""),
                            price,
                            decimal(resultSet, "distance"),
                            decimal(resultSet, "rating"),
                            resultSet.getInt("stock")));
                }
            }

            for (RowSnapshot row : rows) {
                Map<String, Object> pharmacy = new LinkedHashMap<String, Object>();
                pharmacy.put("name", row.name);
                pharmacy.put("email", row.email);
                pharmacy.put("price", row.price == null ? "0" : formatDecimal(row.price));
                pharmacy.put("distance", formatDistance(row.distance));
                pharmacy.put("rating", row.rating == null ? "N/A" : formatDecimal(row.rating));
                pharmacy.put("available", Boolean.valueOf(row.stock > 0));
                pharmacy.put(
                        "bestPrice",
                        Boolean.valueOf(row.price != null && bestPrice != null && row.price.compareTo(bestPrice) == 0));
                pharmacies.add(pharmacy);
            }

        } catch (SQLException e) {
            throw new IllegalStateException("Failed to load pharmacies for medicine.", e);
        }

        return pharmacies;
    }

    private String findMedicineNameById(int id) {
        String sql = "SELECT medicine_name FROM public.medicines WHERE medicine_id = ?";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, id);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return blankToNull(value(resultSet, "medicine_name"));
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Failed to resolve medicine name.", e);
        }
        return null;
    }

    public List<Map<String, String>> getMedicinesByPharmacy(String pharmacyEmail) {
    List<Map<String, String>> medicines = new ArrayList<Map<String, String>>();
    String sql = "SELECT medicine_id, medicine_name, price, stock, distance, rating, "
            + "pharmacy_email, pharmacy_name, tablets_per_strip, strip_info "
            + "FROM public.medicines WHERE pharmacy_email = ? ORDER BY medicine_name ASC";

    try (Connection connection = DBConnection.getConnection();
         PreparedStatement statement = connection.prepareStatement(sql)) {
        statement.setString(1, pharmacyEmail);
        try (ResultSet resultSet = statement.executeQuery()) {
            while (resultSet.next()) {
                Map<String, String> row = new LinkedHashMap<String, String>();
                row.put("id", value(resultSet, "medicine_id"));
                row.put("name", value(resultSet, "medicine_name"));
                row.put("price", safeValue(resultSet, "price", "0"));
                row.put("stock", safeValue(resultSet, "stock", "0"));
                row.put("distance", safeValue(resultSet, "distance", "N/A"));
                row.put("rating", safeValue(resultSet, "rating", "N/A"));
                row.put("pharmacyEmail", value(resultSet, "pharmacy_email"));
                row.put("pharmacyName", value(resultSet, "pharmacy_name"));
                row.put("tabletsPerStrip", value(resultSet, "tablets_per_strip"));
                row.put("stripInfo", value(resultSet, "strip_info"));
                medicines.add(row);
            }
        }
    } catch (SQLException e) {
        throw new IllegalStateException("Failed to load pharmacy medicines from database.", e);
    }
    return medicines;
}

public boolean addMedicine(String pharmacyEmail, String pharmacyName, String medicineName,
        double price, int stock, int tabletsPerStrip, String stripInfo) {
    String sql = "INSERT INTO public.medicines "
            + "(medicine_name, price, stock, pharmacy_email, pharmacy_name, tablets_per_strip, strip_info) "
            + "VALUES (?, ?, ?, ?, ?, ?, ?)";
    try (Connection connection = DBConnection.getConnection();
         PreparedStatement statement = connection.prepareStatement(sql)) {
        statement.setString(1, medicineName);
        statement.setDouble(2, price);
        statement.setInt(3, stock);
        statement.setString(4, pharmacyEmail);
        statement.setString(5, pharmacyName);
        statement.setInt(6, tabletsPerStrip);
        statement.setString(7, stripInfo);
        return statement.executeUpdate() > 0;
    } catch (SQLException e) {
        throw new IllegalStateException("Failed to add medicine to database.", e);
    }
}

public boolean updateMedicine(String medicineId, String pharmacyEmail, String medicineName,
        double price, int stock, int tabletsPerStrip, String stripInfo) {
    String sql = "UPDATE public.medicines SET medicine_name = ?, price = ?, stock = ?, "
            + "tablets_per_strip = ?, strip_info = ? "
            + "WHERE medicine_id = ? AND pharmacy_email = ?";
    try (Connection connection = DBConnection.getConnection();
         PreparedStatement statement = connection.prepareStatement(sql)) {
        statement.setString(1, medicineName);
        statement.setDouble(2, price);
        statement.setInt(3, stock);
        statement.setInt(4, tabletsPerStrip);
        statement.setString(5, stripInfo);
        statement.setInt(6, Integer.parseInt(medicineId));
        statement.setString(7, pharmacyEmail);
        return statement.executeUpdate() > 0;
    } catch (NumberFormatException e) {
        return false;
    } catch (SQLException e) {
        throw new IllegalStateException("Failed to update medicine in database.", e);
    }
}

public boolean deleteMedicine(String medicineId, String pharmacyEmail) {
    String sql = "DELETE FROM public.medicines WHERE medicine_id = ? AND pharmacy_email = ?";
    try (Connection connection = DBConnection.getConnection();
         PreparedStatement statement = connection.prepareStatement(sql)) {
        statement.setInt(1, Integer.parseInt(medicineId));
        statement.setString(2, pharmacyEmail);
        return statement.executeUpdate() > 0;
    } catch (NumberFormatException e) {
        return false;
    } catch (SQLException e) {
        throw new IllegalStateException("Failed to delete medicine from database.", e);
    }
}

public void reduceStock(List<Map<String, String>> orderItems) {
    String sql = "UPDATE public.medicines SET stock = GREATEST(0, stock - ?) "
            + "WHERE medicine_id = ? AND pharmacy_email = ?";
    try (Connection connection = DBConnection.getConnection();
         PreparedStatement statement = connection.prepareStatement(sql)) {
        for (Map<String, String> item : orderItems) {
            try {
                int qty = Integer.parseInt(item.get("quantity") == null ? "1" : item.get("quantity"));
                int id = Integer.parseInt(item.get("id") == null ? "" : item.get("id"));
                String pEmail = item.get("pharmacyEmail") == null ? "" : item.get("pharmacyEmail");
                statement.setInt(1, qty);
                statement.setInt(2, id);
                statement.setString(3, pEmail);
                statement.addBatch();
            } catch (NumberFormatException ignored) {
            }
        }
        statement.executeBatch();
    } catch (SQLException e) {
        throw new IllegalStateException("Failed to reduce medicine stock.", e);
    }
}

    private Summary getSummaryByMedicineName(
            Connection connection,
            String medicineName,
            Double userLat,
            Double userLng) throws SQLException {
        Summary summary = new Summary();
        if (medicineName == null) {
            return summary;
        }

        String avgDistanceExpr = hasLocation(userLat, userLng)
                ? "AVG(" + distanceExpression(userLat, userLng, "p.latitude", "p.longitude") + ") "
                + "FILTER (WHERE p.latitude IS NOT NULL AND p.longitude IS NOT NULL "
                + "AND (NULLIF(TRIM(COALESCE(m.pharmacy_name, '')), '') IS NOT NULL "
                + "OR NULLIF(TRIM(COALESCE(m.pharmacy_email, '')), '') IS NOT NULL)) AS avg_distance, "
                : "NULL AS avg_distance, ";

        String sql = "SELECT "
                + "COUNT(*) FILTER (WHERE (NULLIF(TRIM(COALESCE(m.pharmacy_name, '')), '') IS NOT NULL "
                + "OR NULLIF(TRIM(COALESCE(m.pharmacy_email, '')), '') IS NOT NULL)) AS total_pharmacies, "
                + "MIN(m.price) FILTER (WHERE m.price IS NOT NULL AND (NULLIF(TRIM(COALESCE(m.pharmacy_name, '')), '') IS NOT NULL "
                + "OR NULLIF(TRIM(COALESCE(m.pharmacy_email, '')), '') IS NOT NULL)) AS lowest_price, "
                + "MAX(m.price) FILTER (WHERE m.price IS NOT NULL AND (NULLIF(TRIM(COALESCE(m.pharmacy_name, '')), '') IS NOT NULL "
                + "OR NULLIF(TRIM(COALESCE(m.pharmacy_email, '')), '') IS NOT NULL)) AS highest_price, "
                + avgDistanceExpr
                + "MAX(NULLIF(TRIM(m.manufacturer), '')) AS manufacturer, "
                + "MAX(NULLIF(TRIM(m.strip_info), '')) AS strip_info, "
                + "MAX(m.tablets_per_strip) AS tablets_per_strip "
                + "FROM public.medicines m "
                + "LEFT JOIN public.pharmacies p ON m.pharmacy_email = p.email "
                + "WHERE m.medicine_name = ?";

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, medicineName);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    summary.totalPharmacies = resultSet.getInt("total_pharmacies");
                    summary.lowestPrice = decimal(resultSet, "lowest_price");
                    summary.highestPrice = decimal(resultSet, "highest_price");
                    summary.avgDistance = decimal(resultSet, "avg_distance");
                    summary.manufacturer = blankToNull(value(resultSet, "manufacturer"));
                    summary.stripInfo = blankToNull(value(resultSet, "strip_info"));
                    int tabletsPerStrip = resultSet.getInt("tablets_per_strip");
                    summary.tabletsPerStrip = resultSet.wasNull() ? null : Integer.valueOf(tabletsPerStrip);
                }
            }
        }

        return summary;
    }

    private BigDecimal decimal(ResultSet resultSet, String column) throws SQLException {
        BigDecimal value = resultSet.getBigDecimal(column);
        return value == null ? null : value.stripTrailingZeros();
    }

    private boolean hasLocation(Double userLat, Double userLng) {
        return userLat != null && userLng != null;
    }

    private String distanceExpression(Double userLat, Double userLng, String latColumn, String lngColumn) {
        if (!hasLocation(userLat, userLng)) {
            return "NULL";
        }

        return "(6371 * acos(cos(radians(" + userLat + ")) * cos(radians(" + latColumn + ")) "
                + "* cos(radians(" + lngColumn + ") - radians(" + userLng + ")) "
                + "+ sin(radians(" + userLat + ")) * sin(radians(" + latColumn + "))))";
    }

    private String value(ResultSet resultSet, String column) throws SQLException {
        String value = resultSet.getString(column);
        return value == null ? "" : value.trim();
    }

    private String safeValue(ResultSet resultSet, String column, String fallback) throws SQLException {
        String value = value(resultSet, column);
        return value.isEmpty() ? fallback : value;
    }

    private String blankToNull(String value) {
        return value == null || value.trim().isEmpty() ? null : value.trim();
    }

    private String firstNonBlank(String... values) {
        for (String value : values) {
            if (value != null && !value.trim().isEmpty()) {
                return value.trim();
            }
        }
        return "";
    }

    private String deriveDosage(String medicineName) {
        if (medicineName != null) {
            Matcher matcher = DOSAGE_PATTERN.matcher(medicineName);
            if (matcher.find()) {
                return matcher.group(1).replaceAll("\\s+", " ").trim();
            }
        }
        return "Check packaging";
    }

    private String defaultStripInfo(int tabletsPerStrip) {
        return tabletsPerStrip + " tablets/strip";
    }

    private String formatCount(int count) {
        if (count <= 0) {
            return "0 pharmacies";
        }
        return count == 1 ? "1 pharmacy" : count + " pharmacies";
    }

    private String formatDistance(BigDecimal distance) {
        if (distance == null) {
            return "N/A";
        }
        return formatDecimal(distance) + " km";
    }

    private String formatDecimal(BigDecimal value) {
        if (value == null) {
            return "";
        }

        BigDecimal normalized = value.stripTrailingZeros();
        if (normalized.scale() < 0) {
            normalized = normalized.setScale(0, RoundingMode.HALF_UP);
        }
        return normalized.toPlainString();
    }

    private int parseInt(String value, int fallback) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return fallback;
        }
    }

    private static final class Summary {
        private int totalPharmacies;
        private BigDecimal lowestPrice;
        private BigDecimal highestPrice;
        private BigDecimal avgDistance;
        private String manufacturer;
        private String stripInfo;
        private Integer tabletsPerStrip;
    }

    private static final class RowSnapshot {
        private final String name;
        private final String email;
        private final BigDecimal price;
        private final BigDecimal distance;
        private final BigDecimal rating;
        private final int stock;

        private RowSnapshot(
                String name,
                String email,
                BigDecimal price,
                BigDecimal distance,
                BigDecimal rating,
                int stock) {
            this.name = name;
            this.email = email;
            this.price = price;
            this.distance = distance;
            this.rating = rating;
            this.stock = stock;
        }
    }
}
