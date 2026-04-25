<%@ page import="com.medifinder.dao.CartDAO,java.util.ArrayList,java.util.List,java.util.Map" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
String uri = request.getServletPath();
boolean isAuthPage = uri != null && (uri.contains("login.jsp") || uri.contains("signup.jsp") || uri.contains("pharmacy_login.jsp") || uri.contains("pharmacy_signup.jsp"));
boolean isLoginPage = uri != null && uri.contains("login.jsp");
int cartCount = 0;

List<Map<String, String>> navCart = (List<Map<String, String>>) session.getAttribute("cart");
if ("USER".equals(session.getAttribute("role")) && session.getAttribute("userEmail") != null) {
  try {
    CartDAO cartDAO = new CartDAO();
    navCart = cartDAO.getCartByUser(String.valueOf(session.getAttribute("userEmail")));
    session.setAttribute("cart", navCart);
  } catch (Exception ignore) {
    if (navCart == null) {
      navCart = new ArrayList<Map<String, String>>();
    }
  }
}
if (navCart != null) {
  for (Map<String, String> cartItem : navCart) {
    try {
      cartCount += Integer.parseInt(cartItem.get("quantity"));
    } catch (Exception ignore) {
      cartCount += 1;
    }
  }
}

request.setAttribute("isAuthPage", Boolean.valueOf(isAuthPage));
request.setAttribute("isLoginPage", Boolean.valueOf(isLoginPage));
request.setAttribute("cartCount", Integer.valueOf(cartCount));
%>
<c:url var="searchPageUrl" value="/search.jsp" />
<c:url var="cartPageUrl" value="/cart.jsp" />
<c:url var="ordersPageUrl" value="/my_orders.jsp" />
<c:url var="loginPageUrl" value="/login.jsp" />
<c:url var="signupPageUrl" value="/signup.jsp" />
<c:url var="logoutPageUrl" value="/logout.jsp" />
<c:url var="pharmacyDashboardPageUrl" value="/pharmacy_dashboard.jsp" />
<c:url var="addMedicinePageUrl" value="/add_medicine.jsp" />
<c:url var="pharmacySignupPageUrl" value="/pharmacy_signup.jsp" />
<c:url var="adminLoginPageUrl" value="/admin_login.jsp" />
<c:url var="adminPanelPageUrl" value="/admin_panel.jsp" />
<nav class="sticky top-0 z-50 border-b border-slate-100 bg-white/80 px-4 py-3 backdrop-blur-md sm:px-6 sm:py-4">
  <div class="mx-auto flex w-full max-w-7xl items-center justify-between gap-4">
    <c:choose>
      <c:when test="${isAuthPage}">
        <a href="home.jsp" class="flex min-w-0 items-center gap-3">
          <div class="grid h-10 w-10 shrink-0 place-items-center rounded-xl bg-gradient-to-r from-orange-500 to-pink-500 text-sm font-bold text-white shadow-md">
            MF
          </div>
          <span class="truncate text-lg font-bold tracking-tight sm:text-xl md:text-2xl">MediFinder</span>
        </a>

        <div class="flex items-center gap-3">
          <c:choose>
            <c:when test="${isLoginPage}">
              <a href="${signupPageUrl}" class="whitespace-nowrap rounded-full bg-gradient-to-r from-[#f97316] to-[#fb7185] px-4 py-2 text-sm font-semibold text-white shadow-lg transition hover:scale-105 sm:px-5">
                Sign Up
              </a>
            </c:when>
            <c:otherwise>
              <a href="${loginPageUrl}" class="whitespace-nowrap rounded-full border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-ink shadow-sm transition hover:border-slate-300 hover:bg-slate-50 sm:px-5">
                Login
              </a>
            </c:otherwise>
          </c:choose>
        </div>
      </c:when>

      <c:otherwise>
        <a href="home.jsp" class="flex min-w-0 items-center gap-3">
          <div class="grid h-10 w-10 shrink-0 place-items-center rounded-xl bg-gradient-to-r from-orange-500 to-pink-500 text-sm font-bold text-white shadow-md">
            MF
          </div>
          <span class="truncate text-lg font-bold tracking-tight sm:text-xl md:text-2xl">MediFinder</span>
        </a>

        <div class="hidden items-center gap-4 text-sm font-medium md:flex lg:gap-6">
          <c:choose>
            <c:when test="${empty sessionScope.userEmail}">
              <a href="home.jsp" class="transition duration-200 ${param.active eq 'home' ? 'text-ink opacity-100' : 'opacity-70 hover:text-teal hover:text-orange-500 hover:opacity-100'}">
                Home
              </a>
              <a href="${loginPageUrl}" class="opacity-70 transition duration-200 hover:text-teal hover:text-orange-500 hover:opacity-100">Login</a>
              <a href="${pharmacySignupPageUrl}" class="whitespace-nowrap rounded-full border border-orange-200 bg-orange-50 px-4 py-2 text-sm font-semibold text-orange-600 transition hover:border-orange-300 hover:bg-orange-100 sm:px-5">
                For Pharmacies
              </a>
              <a href="${signupPageUrl}" class="whitespace-nowrap rounded-full bg-gradient-to-r from-[#f97316] to-[#fb7185] px-4 py-2 text-sm font-semibold text-white shadow-lg transition hover:scale-105 sm:px-5">
                Sign Up
              </a>
            </c:when>
            <c:when test="${sessionScope.role eq 'ADMIN'}">
              <a href="home.jsp" class="transition duration-200 ${param.active eq 'home' ? 'text-ink opacity-100' : 'opacity-70 hover:text-teal hover:text-orange-500 hover:opacity-100'}">
                Home
              </a>
              <a href="${adminPanelPageUrl}" class="transition duration-200 ${param.active eq 'admin' ? 'text-ink opacity-100' : 'opacity-70 hover:text-teal hover:text-orange-500 hover:opacity-100'}">
                Admin Panel
              </a>
              <a href="${logoutPageUrl}" class="whitespace-nowrap rounded-full border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-ink shadow-sm transition hover:border-slate-300 hover:bg-slate-50 sm:px-5">
                Logout
              </a>
            </c:when>
            <c:when test="${sessionScope.role eq 'USER'}">
              <a href="${searchPageUrl}" class="transition duration-200 ${param.active eq 'search' ? 'text-ink opacity-100' : 'opacity-70 hover:text-teal hover:text-orange-500 hover:opacity-100'}">
                Search Medicines
              </a>
              <a href="${adminLoginPageUrl}" class="transition duration-200 ${param.active eq 'admin' ? 'text-ink opacity-100' : 'opacity-70 hover:text-teal hover:text-orange-500 hover:opacity-100'}">
                Admin Panel
              </a>
              <a href="${cartPageUrl}" class="inline-flex items-center gap-2 transition duration-200 ${param.active eq 'cart' ? 'text-ink opacity-100' : 'opacity-70 hover:text-teal hover:text-orange-500 hover:opacity-100'}">
                <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3h2l1.2 7.2A2 2 0 0 0 8.2 12H18a2 2 0 0 0 2-1.6l1-5.4H7.1" />
                  <circle cx="9" cy="19" r="1.5" fill="currentColor" stroke="none" />
                  <circle cx="17" cy="19" r="1.5" fill="currentColor" stroke="none" />
                </svg>
                <span>Cart</span>
                <c:if test="${cartCount gt 0}">
                  <span class="inline-flex min-w-[1.5rem] items-center justify-center rounded-full bg-orange-500 px-2 py-0.5 text-xs font-semibold text-white">${cartCount}</span>
                </c:if>
              </a>
              <a href="${ordersPageUrl}" class="transition duration-200 ${param.active eq 'orders' ? 'text-ink opacity-100' : 'opacity-70 hover:text-teal hover:text-orange-500 hover:opacity-100'}">
                My Orders
              </a>
              <a href="${logoutPageUrl}" class="whitespace-nowrap rounded-full border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-ink shadow-sm transition hover:border-slate-300 hover:bg-slate-50 sm:px-5">
                Logout
              </a>
            </c:when>
            <c:when test="${sessionScope.role eq 'PHARMACY'}">
              <a href="${pharmacyDashboardPageUrl}" class="transition duration-200 ${param.active eq 'dashboard' ? 'text-gray-900 opacity-100' : 'text-gray-700 opacity-70 hover:text-orange-500 hover:opacity-100'}">
                Dashboard
              </a>
              <a href="pharmacy_orders.jsp" class="transition duration-200 ${param.active eq 'orders' ? 'text-gray-900 opacity-100' : 'text-gray-700 opacity-70 hover:text-orange-500 hover:opacity-100'}">
                Orders
              </a>
              <a href="${addMedicinePageUrl}" class="transition duration-200 ${param.active eq 'addmedicine' ? 'text-gray-900 opacity-100' : 'text-gray-700 opacity-70 hover:text-orange-500 hover:opacity-100'}">
                Add Medicine
              </a>
              <a href="${adminLoginPageUrl}" class="transition duration-200 ${param.active eq 'admin' ? 'text-gray-900 opacity-100' : 'text-gray-700 opacity-70 hover:text-orange-500 hover:opacity-100'}">
                Admin Panel
              </a>
              <a href="${logoutPageUrl}" class="whitespace-nowrap rounded-full border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-ink shadow-sm transition hover:border-slate-300 hover:bg-slate-50 sm:px-5">
                Logout
              </a>
            </c:when>
          </c:choose>
        </div>

        <details class="relative md:hidden">
          <summary class="list-none cursor-pointer rounded-full bg-white px-4 py-2 text-sm font-semibold shadow-soft">
            Menu
          </summary>
          <div class="absolute right-0 mt-3 w-[min(16rem,calc(100vw-2rem))] space-y-1 rounded-2xl border border-slate-100 bg-white p-4 text-sm font-medium shadow-soft">
            <c:choose>
              <c:when test="${empty sessionScope.userEmail}">
                <a href="home.jsp" class="block rounded-lg px-2 py-1 transition duration-200 ${param.active eq 'home' ? 'text-ink opacity-100' : 'opacity-70 hover:text-teal hover:text-orange-500 hover:opacity-100'}">
                  Home
                </a>
                <a href="${loginPageUrl}" class="block rounded-lg px-2 py-1 opacity-70 transition duration-200 hover:text-teal hover:text-orange-500 hover:opacity-100">Login</a>
                <a href="${pharmacySignupPageUrl}" class="block rounded-lg px-2 py-1 font-semibold text-orange-600 transition hover:text-orange-700">
                  For Pharmacies
                </a>
                <a href="${signupPageUrl}" class="mt-3 block rounded-full bg-ink px-4 py-2 text-center text-white">
                  Sign Up
                </a>
              </c:when>
              <c:when test="${sessionScope.role eq 'ADMIN'}">
                <a href="home.jsp" class="block rounded-lg px-2 py-1 transition duration-200 ${param.active eq 'home' ? 'text-ink opacity-100' : 'opacity-70 hover:text-teal hover:text-orange-500 hover:opacity-100'}">
                  Home
                </a>
                <a href="${adminPanelPageUrl}" class="block rounded-lg px-2 py-1 transition duration-200 ${param.active eq 'admin' ? 'text-ink opacity-100' : 'opacity-70 hover:text-teal hover:text-orange-500 hover:opacity-100'}">
                  Admin Panel
                </a>
                <a href="${logoutPageUrl}" class="mt-3 block rounded-full border border-slate-200 px-4 py-2 text-center text-ink transition hover:bg-slate-50">
                  Logout
                </a>
              </c:when>
              <c:when test="${sessionScope.role eq 'USER'}">
                <a href="${searchPageUrl}" class="block rounded-lg px-2 py-1 transition duration-200 ${param.active eq 'search' ? 'text-ink opacity-100' : 'opacity-70 hover:text-teal hover:text-orange-500 hover:opacity-100'}">
                  Search Medicines
                </a>
                <a href="${adminLoginPageUrl}" class="block rounded-lg px-2 py-1 transition duration-200 ${param.active eq 'admin' ? 'text-ink opacity-100' : 'opacity-70 hover:text-teal hover:text-orange-500 hover:opacity-100'}">
                  Admin Panel
                </a>
                <a href="${cartPageUrl}" class="flex items-center justify-between rounded-lg px-2 py-1 transition duration-200 ${param.active eq 'cart' ? 'text-ink opacity-100' : 'opacity-70 hover:text-teal hover:text-orange-500 hover:opacity-100'}">
                  <span class="inline-flex items-center gap-2">
                    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3h2l1.2 7.2A2 2 0 0 0 8.2 12H18a2 2 0 0 0 2-1.6l1-5.4H7.1" />
                      <circle cx="9" cy="19" r="1.5" fill="currentColor" stroke="none" />
                      <circle cx="17" cy="19" r="1.5" fill="currentColor" stroke="none" />
                    </svg>
                    <span>Cart</span>
                  </span>
                  <c:if test="${cartCount gt 0}">
                    <span class="inline-flex min-w-[1.5rem] items-center justify-center rounded-full bg-orange-500 px-2 py-0.5 text-xs font-semibold text-white">${cartCount}</span>
                  </c:if>
                </a>
                <a href="${ordersPageUrl}" class="block rounded-lg px-2 py-1 transition duration-200 ${param.active eq 'orders' ? 'text-ink opacity-100' : 'opacity-70 hover:text-teal hover:text-orange-500 hover:opacity-100'}">
                  My Orders
                </a>
                <a href="${logoutPageUrl}" class="mt-3 block rounded-full border border-slate-200 px-4 py-2 text-center text-ink transition hover:bg-slate-50">
                  Logout
                </a>
              </c:when>
              <c:when test="${sessionScope.role eq 'PHARMACY'}">
                <a href="${pharmacyDashboardPageUrl}" class="block rounded-lg px-2 py-1 transition duration-200 ${param.active eq 'dashboard' ? 'text-gray-900 opacity-100' : 'text-gray-700 opacity-70 hover:text-orange-500 hover:opacity-100'}">
                  Dashboard
                </a>
                <a href="pharmacy_orders.jsp" class="block rounded-lg px-2 py-1 transition duration-200 ${param.active eq 'orders' ? 'text-gray-900 opacity-100' : 'text-gray-700 opacity-70 hover:text-orange-500 hover:opacity-100'}">
                  Orders
                </a>
                <a href="${addMedicinePageUrl}" class="block rounded-lg px-2 py-1 transition duration-200 ${param.active eq 'addmedicine' ? 'text-gray-900 opacity-100' : 'text-gray-700 opacity-70 hover:text-orange-500 hover:opacity-100'}">
                  Add Medicine
                </a>
                <a href="${adminLoginPageUrl}" class="block rounded-lg px-2 py-1 transition duration-200 ${param.active eq 'admin' ? 'text-gray-900 opacity-100' : 'text-gray-700 opacity-70 hover:text-orange-500 hover:opacity-100'}">
                  Admin Panel
                </a>
                <a href="${logoutPageUrl}" class="mt-3 block rounded-full border border-slate-200 px-4 py-2 text-center text-ink transition hover:bg-slate-50">
                  Logout
                </a>
              </c:when>
            </c:choose>
          </div>
        </details>
      </c:otherwise>
    </c:choose>
  </div>
</nav>
