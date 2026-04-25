package com.medifinder.servlet;

import com.medifinder.dao.CartDAO;
import com.medifinder.dao.MedicineDAO;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class MedicineDetailsServlet extends HttpServlet {

    private final MedicineDAO medicineDAO = new MedicineDAO();
    private final CartDAO cartDAO = new CartDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isUserLoggedIn(request.getSession(false))) {
            response.sendRedirect("login.jsp");
            return;
        }

        loadMedicineDetails(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isUserLoggedIn(session)) {
            response.sendRedirect("login.jsp");
            return;
        }

        if (request.getParameter("addToCart") == null) {
            loadMedicineDetails(request, response);
            return;
        }

        handleAddToCart(request, response, session);
    }

    private void loadMedicineDetails(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer medicineId = parseId(request.getParameter("id"));
        Map<String, Object> medicine = null;
        List<Map<String, Object>> pharmacyResults = new ArrayList<Map<String, Object>>();
        Double userLat = resolveCoordinate(request, "userLat", "userLat");
        Double userLon = resolveCoordinate(request, "userLon", "userLon");

        if (userLon == null) {
            userLon = resolveCoordinate(request, "userLon", "userLng");
        }

        if (userLat != null && userLon != null) {
            request.getSession().setAttribute("userLat", userLat);
            request.getSession().setAttribute("userLon", userLon);
            request.getSession().setAttribute("userLng", userLon);
        }

        if (medicineId != null) {
            medicine = medicineDAO.getMedicineById(medicineId.intValue(), userLat, userLon);
            if (medicine != null) {
                pharmacyResults = medicineDAO.getPharmaciesByMedicineId(medicineId.intValue(), userLat, userLon);
                prioritizeSelectedPharmacy(pharmacyResults, request.getParameter("pharmacyEmail"));
            }
        }

        if (medicine == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
        }

        request.setAttribute("medicine", medicine);
        request.setAttribute("pharmacyResults", pharmacyResults);
        request.setAttribute("relatedMedicines", new ArrayList<Object>());

        RequestDispatcher dispatcher = request.getRequestDispatcher("/medicine_details.jsp");
        dispatcher.forward(request, response);
    }

    private void handleAddToCart(
            HttpServletRequest request,
            HttpServletResponse response,
            HttpSession session) throws IOException {

        String cartMedicineId = defaultIfBlank(request.getParameter("id"), "0");
        String cartMedicineName = defaultIfBlank(request.getParameter("name"), "Medicine");
        String cartPrice = sanitizePrice(request.getParameter("price"));
        String cartPharmacyName = defaultIfBlank(request.getParameter("pharmacyName"), "Partner Pharmacy");
        String cartPharmacyEmail = normalize(request.getParameter("pharmacyEmail"));
        String cartStripInfo = normalize(request.getParameter("stripInfo"));
        String cartTabletsPerStrip = sanitizePositiveInteger(request.getParameter("tabletsPerStrip"), "10");
        String cartAvailable = normalize(request.getParameter("available"));
        Object userEmail = session.getAttribute("userEmail");
        String currentUserEmail = userEmail == null ? "" : normalize(String.valueOf(userEmail));
        int cartQuantity = parseQuantity(request.getParameter("quantity"));

        if (cartStripInfo.isEmpty()) {
            cartStripInfo = "1 strip = 10 tablets";
        }
        if (cartTabletsPerStrip.isEmpty()) {
            cartTabletsPerStrip = "10";
        }

        String redirectUrl = buildRedirectUrl(cartMedicineId, cartPharmacyEmail);
        String cartMessage;
        String cartMessageKey;

        if (!"true".equalsIgnoreCase(cartAvailable)) {
            cartMessage = "This medicine is currently out of stock at the selected pharmacy.";
            cartMessageKey = "cartError";
            response.sendRedirect(redirectUrl + "&" + cartMessageKey + "=" + encode(cartMessage));
            return;
        }

        List<Map<String, String>> cart = new ArrayList<Map<String, String>>();
        try {
            cart = cartDAO.getCartByUser(currentUserEmail);
        } catch (Exception ignore) {
            Object existingCart = session.getAttribute("cart");
            if (existingCart instanceof List<?>) {
                cart = (List<Map<String, String>>) existingCart;
            }
        }

        if (!cart.isEmpty()) {
            String existingPharmacyKey = normalize(cart.get(0).get("pharmacyEmail"));
            if (existingPharmacyKey.isEmpty()) {
                existingPharmacyKey = normalize(cart.get(0).get("pharmacyName"));
            }

            String currentPharmacyKey = cartPharmacyEmail.isEmpty() ? cartPharmacyName : cartPharmacyEmail;
            if (!existingPharmacyKey.isEmpty()
                    && !currentPharmacyKey.isEmpty()
                    && !existingPharmacyKey.equalsIgnoreCase(currentPharmacyKey)) {
                cartMessage = "Cart contains items from another pharmacy. Clear cart to continue.";
                cartMessageKey = "cartError";
                response.sendRedirect(redirectUrl + "&" + cartMessageKey + "=" + encode(cartMessage));
                return;
            }
        }

        boolean updated = false;
        for (Map<String, String> cartItem : cart) {
            String existingItemPharmacyKey = normalize(cartItem.get("pharmacyEmail"));
            if (existingItemPharmacyKey.isEmpty()) {
                existingItemPharmacyKey = normalize(cartItem.get("pharmacyName"));
            }

            String currentItemPharmacyKey = cartPharmacyEmail.isEmpty() ? cartPharmacyName : cartPharmacyEmail;
            if (cartMedicineId.equalsIgnoreCase(normalize(cartItem.get("id")))
                    && currentItemPharmacyKey.equalsIgnoreCase(existingItemPharmacyKey)) {
                int existingQuantity = parseQuantity(cartItem.get("quantity"));
                cartItem.put("quantity", String.valueOf(existingQuantity + cartQuantity));
                cartItem.put("price", cartPrice);
                cartItem.put("stripInfo", cartStripInfo);
                cartItem.put("tabletsPerStrip", cartTabletsPerStrip);
                cartItem.put("pharmacyEmail", cartPharmacyEmail);
                updated = true;
                break;
            }
        }

        if (!updated) {
            Map<String, String> cartItem = new LinkedHashMap<String, String>();
            cartItem.put("id", cartMedicineId);
            cartItem.put("name", cartMedicineName);
            cartItem.put("price", cartPrice);
            cartItem.put("quantity", String.valueOf(cartQuantity));
            cartItem.put("pharmacyName", cartPharmacyName);
            cartItem.put("pharmacyEmail", cartPharmacyEmail);
            cartItem.put("stripInfo", cartStripInfo);
            cartItem.put("tabletsPerStrip", cartTabletsPerStrip);
            cart.add(cartItem);
        }

        try {
            cartDAO.saveCart(currentUserEmail, cart);
            session.setAttribute("cart", cart);
            cartMessage = updated ? "Cart quantity updated successfully." : "Medicine added to cart.";
            cartMessageKey = "cartMessage";
        } catch (Exception ex) {
            cartMessage = "Failed to save cart in database: " + ex.getMessage();
            cartMessageKey = "cartError";
        }

        response.sendRedirect(redirectUrl + "&" + cartMessageKey + "=" + encode(cartMessage));
    }

    private boolean isUserLoggedIn(HttpSession session) {
        return session != null && "USER".equals(session.getAttribute("role"));
    }

    private void prioritizeSelectedPharmacy(
            List<Map<String, Object>> pharmacyResults,
            String selectedPharmacyEmail) {

        String safeEmail = normalize(selectedPharmacyEmail);
        if (safeEmail.isEmpty()) {
            return;
        }

        for (int index = 0; index < pharmacyResults.size(); index++) {
            Map<String, Object> pharmacy = pharmacyResults.get(index);
            Object email = pharmacy.get("email");
            if (email != null && safeEmail.equalsIgnoreCase(String.valueOf(email).trim())) {
                if (index > 0) {
                    pharmacyResults.remove(index);
                    pharmacyResults.add(0, pharmacy);
                }
                return;
            }
        }
    }

    private String buildRedirectUrl(String medicineId, String pharmacyEmail) {
        StringBuilder redirectUrl = new StringBuilder("MedicineDetailsServlet?id=");
        redirectUrl.append(encode(medicineId));

        if (!normalize(pharmacyEmail).isEmpty()) {
            redirectUrl.append("&pharmacyEmail=").append(encode(pharmacyEmail));
        }

        return redirectUrl.toString();
    }

    private String encode(String value) {
        return URLEncoder.encode(normalize(value), StandardCharsets.UTF_8);
    }

    private String defaultIfBlank(String value, String fallback) {
        String normalized = normalize(value);
        return normalized.isEmpty() ? fallback : normalized;
    }

    private String sanitizePrice(String value) {
        String normalized = normalize(value);
        if (normalized.isEmpty()) {
            return "0";
        }

        try {
            double parsed = Double.parseDouble(normalized);
            return parsed < 0 ? "0" : normalized;
        } catch (Exception e) {
            return "0";
        }
    }

    private String sanitizePositiveInteger(String value, String fallback) {
        String normalized = normalize(value);
        if (normalized.isEmpty()) {
            return fallback;
        }

        try {
            return Integer.parseInt(normalized) > 0 ? normalized : fallback;
        } catch (Exception e) {
            return fallback;
        }
    }

    private Integer parseId(String value) {
        try {
            return Integer.valueOf(normalize(value));
        } catch (Exception e) {
            return null;
        }
    }

    private Double resolveCoordinate(HttpServletRequest request, String parameterName, String sessionAttribute) {
        String value = normalize(request.getParameter(parameterName));
        if (value.isEmpty()) {
            Object sessionValue = request.getSession().getAttribute(sessionAttribute);
            if (sessionValue != null) {
                value = normalize(String.valueOf(sessionValue));
            }
        }

        if (value.isEmpty()) {
            return null;
        }

        try {
            return Double.valueOf(value);
        } catch (Exception e) {
            return null;
        }
    }

    private int parseQuantity(String value) {
        try {
            int quantity = Integer.parseInt(normalize(value));
            return quantity < 1 ? 1 : quantity;
        } catch (Exception e) {
            return 1;
        }
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }
}
