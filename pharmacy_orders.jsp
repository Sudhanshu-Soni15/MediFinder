<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List,java.util.Map"%>
<%@ page import="com.medifinder.dao.OrderDAO"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
if (session.getAttribute("userEmail") == null || !"PHARMACY".equals(session.getAttribute("role"))) {
  response.sendRedirect("login.jsp");
  return;
}
String pharmacyEmail = String.valueOf(session.getAttribute("userEmail"));
OrderDAO orderDAO = new OrderDAO();
List<Map<String, Object>> pharmacyOrders = orderDAO.getPharmacyOrders(pharmacyEmail);
request.setAttribute("pharmacyOrders", pharmacyOrders);
%>
<!doctype html>
<html lang="en">

<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>MediFinder | Pharmacy Orders</title>

  <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700&family=Spectral:ital,wght@0,400;0,600;1,600&display=swap" rel="stylesheet" />

  <script src="https://cdn.tailwindcss.com"></script>
  <script>
    tailwind.config = {
      theme: {
        extend: {
          colors: {
            ink: "#2b1f1b",
            fog: "#fff7ed",
            mint: "#f97316",
            teal: "#f59e0b",
            coral: "#fb7185",
          },
          boxShadow: {
            soft: "0 20px 60px -30px rgba(15, 23, 42, 0.45)",
          },
        },
      },
    };
  </script>

  <style>
    :root {
      --bg-gradient: radial-gradient(800px circle at 5% 10%, rgba(245, 158, 11, 0.2), transparent 40%),
        radial-gradient(700px circle at 95% 0%, rgba(251, 113, 133, 0.2), transparent 40%),
        linear-gradient(180deg, #fff7ed 0%, #f8fafc 100%);
    }

    body {
      font-family: "Space Grotesk", system-ui, -apple-system, sans-serif;
      background: #fff7ed;
      color: #2b1f1b;
      min-height: 100vh;
    }

    .glass {
      background: rgba(255, 255, 255, 0.75);
      backdrop-filter: blur(14px);
      border: 1px solid rgba(255, 255, 255, 0.7);
    }
  </style>
</head>

<body class="text-ink">
  <div class="min-h-screen flex flex-col">
    <jsp:include page="/includes/navbar.jsp">
      <jsp:param name="active" value="orders" />
    </jsp:include>

    <main class="flex-1">
      <section class="relative overflow-hidden px-4 py-12 sm:px-6 sm:py-16 lg:py-20" style="background: var(--bg-gradient)">
        <div class="pointer-events-none absolute right-20 top-16 h-72 w-72 rounded-full bg-teal/20 blur-3xl"></div>
        <div class="pointer-events-none absolute -bottom-8 left-0 h-72 w-72 rounded-full bg-coral/20 blur-3xl"></div>

        <div class="relative z-10 mx-auto max-w-6xl">
          <div class="max-w-3xl">
            <p class="text-xs font-semibold uppercase tracking-[0.25em] text-teal">Pharmacy portal</p>
            <h1 class="mt-4 text-4xl font-bold text-ink sm:text-5xl">Incoming Orders</h1>
            <p class="mt-4 text-base text-slate-600 sm:text-lg">Manage and process customer orders</p>
          </div>

          <section class="glass mt-10 rounded-3xl p-6 shadow-soft sm:p-8">
            <!-- <div class="grid gap-6 xl:grid-cols-2"> -->
              
              <c:choose>
  <c:when test="${empty pharmacyOrders}">
    <div class="mt-8 rounded-3xl border border-dashed border-slate-300 bg-white/80 px-6 py-16 text-center text-slate-500">
      <p class="text-lg font-medium">No incoming orders yet</p>
      <p class="mt-2 text-sm">Orders placed by MediFinder users will appear here.</p>
    </div>
  </c:when>
  <c:otherwise>
    <div class="grid gap-6 xl:grid-cols-2">
      <c:forEach var="order" items="${pharmacyOrders}">
        <article class="rounded-3xl border border-white/80 bg-white/90 p-5 shadow-sm transition duration-200 hover:-translate-y-1 hover:shadow-xl">
          <div class="flex items-start justify-between gap-4">
            <div>
              <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Order ID</p>
              <h3 class="mt-2 text-xl font-bold text-ink"><c:out value="${order.orderId}" /></h3>
              <p class="mt-2 text-sm text-slate-600">Customer: <c:out value="${order.userName}" /></p>
            </div>
            <span class="rounded-full px-3 py-1 text-xs font-semibold ${order.status eq 'CANCELLED' ? 'bg-red-100 text-red-700' : order.status eq 'COMPLETED' ? 'bg-slate-200 text-slate-700' : order.status eq 'PLACED' ? 'bg-amber-100 text-amber-700' : order.status eq 'PREPARING' ? 'bg-blue-100 text-blue-700' : 'bg-emerald-100 text-emerald-700'}">
              <c:out value="${order.status}" />
            </span>
          </div>

          <div class="mt-5 grid gap-3 sm:grid-cols-2">
            <div class="rounded-2xl bg-slate-50 p-4">
              <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Delivery Type</p>
              <p class="mt-2 text-sm font-semibold text-ink"><c:out value="${order.deliveryType}" /></p>
            </div>
            <div class="rounded-2xl bg-slate-50 p-4">
              <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Total</p>
              <p class="mt-2 text-sm font-semibold text-ink">&#8377;<c:out value="${order.totalPrice}" /></p>
            </div>
          </div>

          <div class="mt-4 rounded-2xl bg-slate-50 p-4">
            <c:choose>
              <c:when test="${order.deliveryType eq 'Pickup from Pharmacy'}">
                <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Pickup Time</p>
                <p class="mt-2 text-sm font-semibold text-ink"><c:out value="${order.pickupTime}" /></p>
              </c:when>
              <c:otherwise>
                <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Delivery Address</p>
                <p class="mt-2 text-sm font-semibold text-ink"><c:out value="${order.address}" /></p>
                <p class="mt-2 text-sm text-slate-600">Delivery window: <c:out value="${order.deliveryTime}" /></p>
              </c:otherwise>
            </c:choose>
          </div>

          <div class="mt-4 space-y-3">
            <c:forEach var="item" items="${order.items}">
              <div class="rounded-2xl bg-slate-50 p-4">
                <div class="flex items-center justify-between gap-4">
                  <div>
                    <p class="font-semibold text-ink"><c:out value="${item.name}" /></p>
                    <p class="mt-1 text-sm text-slate-600"><c:out value="${item.stripInfo}" /></p>
                  </div>
                  <div class="text-right text-sm text-slate-600">
                    <p>Qty: <c:out value="${item.quantity}" /></p>
                  </div>
                </div>
              </div>
            </c:forEach>
          </div>

          <div class="mt-5 grid gap-3 sm:grid-cols-2">
            <c:if test="${order.status eq 'PLACED'}">
              <form method="post" action="pharmacy_dashboard.jsp">
                <input type="hidden" name="orderId" value="<c:out value='${order.orderId}' />" />
                <input type="hidden" name="orderAction" value="accept" />
                <button type="submit" class="inline-flex w-full items-center justify-center rounded-2xl bg-gradient-to-r from-orange-500 to-pink-500 px-4 py-3 text-sm font-semibold text-white shadow-md transition hover:scale-[1.01] hover:shadow-lg">
                  Accept Order
                </button>
              </form>
            </c:if>
            <c:if test="${order.status eq 'PREPARING'}">
              <form method="post" action="pharmacy_dashboard.jsp">
                <input type="hidden" name="orderId" value="<c:out value='${order.orderId}' />" />
                <input type="hidden" name="orderAction" value="ready" />
                <button type="submit" class="inline-flex w-full items-center justify-center rounded-2xl border border-orange-200 bg-orange-50 px-4 py-3 text-sm font-semibold text-orange-600 transition hover:border-orange-300 hover:bg-orange-100">
                  Mark Ready
                </button>
              </form>
            </c:if>
            <c:if test="${order.deliveryType eq 'Home Delivery' and order.status eq 'READY'}">
              <form method="post" action="pharmacy_dashboard.jsp">
                <input type="hidden" name="orderId" value="<c:out value='${order.orderId}' />" />
                <input type="hidden" name="orderAction" value="dispatch" />
                <button type="submit" class="inline-flex w-full items-center justify-center rounded-2xl border border-orange-200 bg-orange-50 px-4 py-3 text-sm font-semibold text-orange-600 transition hover:border-orange-300 hover:bg-orange-100">
                  Out for Delivery
                </button>
              </form>
            </c:if>
            <c:if test="${(order.deliveryType eq 'Pickup from Pharmacy' and order.status eq 'READY') or (order.deliveryType eq 'Home Delivery' and order.status eq 'OUT FOR DELIVERY')}">
              <form method="post" action="pharmacy_dashboard.jsp">
                <input type="hidden" name="orderId" value="<c:out value='${order.orderId}' />" />
                <input type="hidden" name="orderAction" value="complete" />
                <button type="submit" class="inline-flex w-full items-center justify-center rounded-2xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm font-semibold text-emerald-700 transition hover:border-emerald-300 hover:bg-emerald-100">
                  Completed
                </button>
              </form>
            </c:if>
          </div>
        </article>
      </c:forEach>
    </div>
  </c:otherwise>
</c:choose>

            <!-- </div> -->
          </section>
        </div>
      </section>
    </main>

    <jsp:include page="/includes/footer.jsp" />
  </div>
</body>

</html>
