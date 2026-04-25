package com.medifinder.servlet;

import com.medifinder.dao.MedicineDAO;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class SearchServlet extends HttpServlet {

    private final MedicineDAO medicineDAO = new MedicineDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String query = normalize(firstNonBlank(
                request.getParameter("query"),
                request.getParameter("q")));
        String sort = normalize(request.getParameter("sort")).toLowerCase();
        String distance = normalize(request.getParameter("distance")).toLowerCase();
        String rating = normalize(request.getParameter("rating"));
        boolean availability = request.getParameter("availability") != null;
        String userLatStr = request.getParameter("userLat");
        String userLonStr = request.getParameter("userLon");

        if (isBlank(userLatStr)) {
            Object latObj = request.getSession().getAttribute("userLat");
            if (latObj != null) {
                userLatStr = latObj.toString();
            }
        }
        if (isBlank(userLonStr)) {
            Object lonObj = request.getSession().getAttribute("userLon");
            if (lonObj == null) {
                lonObj = request.getSession().getAttribute("userLng");
            }
            if (lonObj != null) {
                userLonStr = lonObj.toString();
            }
        }

        System.out.println("UserLat: " + userLatStr);
        System.out.println("UserLon: " + userLonStr);

        Double userLat = null;
        Double userLon = null;
        try {
            userLat = Double.parseDouble(normalize(userLatStr));
            userLon = Double.parseDouble(normalize(userLonStr));
        } catch (Exception e) {
            userLat = null;
            userLon = null;
        }

        if (userLat != null && userLon != null) {
            request.getSession().setAttribute("userLat", userLat);
            request.getSession().setAttribute("userLon", userLon);
            request.getSession().setAttribute("userLng", userLon);
        }

        List<Map<String, String>> resultList;
        if (userLat != null && userLon != null) {
            resultList = medicineDAO.searchMedicines(
                    query,
                    sort,
                    distance,
                    rating,
                    availability,
                    userLat.doubleValue(),
                    userLon.doubleValue());
        } else {
            resultList = medicineDAO.searchMedicines(query, sort, distance, rating, availability);
        }

        request.setAttribute("medicines", resultList);
        request.setAttribute("searchQuery", query);
        request.setAttribute("selectedSort", sort);
        request.setAttribute("selectedDistance", distance);
        request.setAttribute("selectedRating", rating);
        request.setAttribute("availabilityOnly", Boolean.valueOf(availability));
        request.setAttribute("hasPriceFilter", Boolean.valueOf(!sort.isEmpty()));
        request.setAttribute("hasDistanceFilter", Boolean.valueOf(!distance.isEmpty()));
        request.setAttribute("hasRatingFilter", Boolean.valueOf(!rating.isEmpty()));
        request.setAttribute("hasAvailabilityFilter", Boolean.valueOf(availability));
        request.setAttribute("hasBackendMedicines", Boolean.TRUE);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/search.jsp");
        dispatcher.forward(request, response);
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }

    private boolean isBlank(String value) {
        return normalize(value).isEmpty();
    }

    private String firstNonBlank(String first, String second) {
        String firstValue = normalize(first);
        if (!firstValue.isEmpty()) {
            return firstValue;
        }
        return normalize(second);
    }
}
