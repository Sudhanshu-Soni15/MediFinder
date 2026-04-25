<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%
if (session.getAttribute("role") == null) {
  response.sendRedirect("login.jsp");
  return;
}

response.sendRedirect("my_orders.jsp");
%>
