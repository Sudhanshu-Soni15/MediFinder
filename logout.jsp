<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%
Cookie clearEmail = new Cookie("mf_email", "");
Cookie clearName = new Cookie("mf_name", "");
Cookie clearRole = new Cookie("mf_role", "");
String cookiePath = request.getContextPath().isEmpty() ? "/" : request.getContextPath();

clearEmail.setMaxAge(0);
clearName.setMaxAge(0);
clearRole.setMaxAge(0);
clearEmail.setPath(cookiePath);
clearName.setPath(cookiePath);
clearRole.setPath(cookiePath);
response.addCookie(clearEmail);
response.addCookie(clearName);
response.addCookie(clearRole);

session.invalidate();
response.sendRedirect("login.jsp");
%>
