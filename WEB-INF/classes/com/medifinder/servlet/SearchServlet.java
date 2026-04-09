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

        List<Map<String, String>> resultList =
                medicineDAO.searchMedicines(query, sort, distance, rating, availability);

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

    private String firstNonBlank(String first, String second) {
        String firstValue = normalize(first);
        if (!firstValue.isEmpty()) {
            return firstValue;
        }
        return normalize(second);
    }
}
