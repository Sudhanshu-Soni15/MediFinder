<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.medifinder.dao.OrderDAO,java.util.ArrayList,java.util.List,java.util.Map"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
if (!"USER".equals(session.getAttribute("role"))) {
  response.sendRedirect("login.jsp");
  return;
}

String orderMessage = request.getParameter("orderMessage");
String orderMessageType = orderMessage == null || orderMessage.trim().isEmpty() ? null : "success";
boolean isPost = "POST".equalsIgnoreCase(request.getMethod());
String currentUserEmail = String.valueOf(session.getAttribute("userEmail"));
OrderDAO orderDAO = new OrderDAO();

if (isPost && request.getParameter("cancelOrderId") != null) {
  String cancelOrderId = request.getParameter("cancelOrderId");
  try {
    String existingStatus = orderDAO.getOrderStatusForUser(cancelOrderId, currentUserEmail);
    if (existingStatus == null || existingStatus.trim().isEmpty()) {
      orderMessage = "Order not found.";
      orderMessageType = "error";
    } else if ("CANCELLED".equals(existingStatus) || "COMPLETED".equals(existingStatus)) {
      orderMessage = "This order cannot be cancelled now.";
      orderMessageType = "error";
    } else {
      boolean updated = orderDAO.cancelOrder(cancelOrderId, currentUserEmail);
      if (updated) {
        orderMessage = "Order cancelled successfully.";
        orderMessageType = "success";
      } else {
        orderMessage = "Order not found.";
        orderMessageType = "error";
      }
    }
  } catch (Exception ex) {
    orderMessage = "Unable to cancel order due to database error.";
    orderMessageType = "error";
  }
}

List<Map<String, Object>> userOrders = new ArrayList<Map<String, Object>>();
try {
  userOrders = orderDAO.getUserOrders(currentUserEmail);
} catch (Exception ex) {
  if (orderMessage == null || orderMessage.trim().isEmpty()) {
    orderMessage = "Unable to load orders from database.";
    orderMessageType = "error";
  }
}

request.setAttribute("userOrders", userOrders);
request.setAttribute("orderMessage", orderMessage);
request.setAttribute("orderMessageType", orderMessageType);
%>
<!doctype html>
<html lang="en">

<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>MediFinder | My Orders</title>

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
        radial-gradient(700px circle at 95% 0%, rgba(251, 113, 133, 0.16), transparent 40%),
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
        <div class="absolute right-20 top-16 h-72 w-72 rounded-full bg-teal/30 blur-3xl"></div>
        <div class="absolute -bottom-8 left-0 h-72 w-72 rounded-full bg-coral/20 blur-3xl"></div>

        <div class="mx-auto max-w-6xl">
          <div class="max-w-3xl">
            <p class="text-xs font-semibold uppercase tracking-[0.25em] text-teal">Order history</p>
            <h1 class="mt-4 text-4xl font-bold text-ink sm:text-5xl">My Orders</h1>
            <p class="mt-4 text-base text-slate-600 sm:text-lg">Track pickup and delivery orders, including COD status.</p>
          </div>

          <c:if test="${not empty orderMessage}">
            <div class="mt-8 rounded-2xl border px-4 py-3 text-sm font-medium shadow-soft ${orderMessageType eq 'success' ? 'border-emerald-200 bg-emerald-50 text-emerald-700' : 'border-red-200 bg-red-50 text-red-700'}">
              <c:out value="${orderMessage}" />
            </div>
          </c:if>

          <c:choose>
            <c:when test="${empty userOrders}">
              <div class="glass mt-10 rounded-3xl p-8 text-center shadow-soft sm:p-10">
                <h2 class="text-2xl font-bold text-ink">No orders yet</h2>
                <p class="mt-3 text-sm text-slate-600">Your placed orders will appear here after checkout.</p>
                <a href="search.jsp" class="mt-6 inline-flex items-center justify-center rounded-2xl bg-gradient-to-r from-orange-500 to-pink-500 px-6 py-3 text-sm font-semibold text-white shadow-lg transition hover:scale-[1.01] hover:shadow-xl">
                  Search Medicines
                </a>
              </div>
            </c:when>
            <c:otherwise>
              <div class="mt-10 grid gap-6 xl:grid-cols-2">
                <c:forEach var="order" items="${userOrders}">
                  <article class="glass flex h-full flex-col rounded-3xl p-6 shadow-soft transition duration-200 hover:-translate-y-1 hover:shadow-xl">
                    <div class="flex items-start justify-between gap-4">
                      <div>
                        <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Order ID</p>
                        <h2 class="mt-2 text-2xl font-bold text-ink"><c:out value="${order.orderId}" /></h2>
                      </div>
                      <span class="rounded-full px-3 py-1 text-xs font-semibold ${order.status eq 'CANCELLED' ? 'bg-red-100 text-red-700' : order.status eq 'COMPLETED' ? 'bg-slate-200 text-slate-700' : 'bg-emerald-100 text-emerald-700'}">
                        <c:out value="${order.status}" />
                      </span>
                    </div>

                    <div class="mt-6 grid gap-4 sm:grid-cols-2">
                      <div class="rounded-2xl bg-white/90 p-4 shadow-sm">
                        <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Pharmacy</p>
                        <p class="mt-2 text-sm font-semibold text-ink"><c:out value="${order.pharmacyName}" /></p>
                      </div>
                      <div class="rounded-2xl bg-white/90 p-4 shadow-sm">
                        <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Delivery Type</p>
                        <p class="mt-2 text-sm font-semibold text-ink"><c:out value="${order.deliveryType}" /></p>
                      </div>
                      <div class="rounded-2xl bg-white/90 p-4 shadow-sm">
                        <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Payment</p>
                        <p class="mt-2 text-sm font-semibold text-ink"><c:out value="${order.paymentMethod}" /> / <c:out value="${order.paymentStatus}" /></p>
                      </div>
                      <div class="rounded-2xl bg-white/90 p-4 shadow-sm">
                        <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Total Price</p>
                        <p class="mt-2 text-sm font-semibold text-ink">&#8377;<c:out value="${order.totalPrice}" /></p>
                      </div>
                    </div>

                    <div class="mt-4 rounded-2xl bg-white/90 p-5 shadow-sm">
                      <c:choose>
                        <c:when test="${order.deliveryType eq 'Pickup from Pharmacy'}">
                          <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Pickup Time</p>
                          <p class="mt-2 text-sm font-semibold text-ink"><c:out value="${order.pickupTime}" /></p>
                        </c:when>
                        <c:otherwise>
                          <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Delivery Details</p>
                          <p class="mt-2 text-sm font-semibold text-ink"><c:out value="${order.address}" /></p>
                          <p class="mt-2 text-sm text-slate-600">Delivery window: <c:out value="${order.deliveryTime}" /></p>
                          <p class="mt-1 text-sm text-slate-600">Delivery charge: &#8377;<c:out value="${order.deliveryCharge}" /></p>
                        </c:otherwise>
                      </c:choose>
                    </div>

                    <div class="mt-6 rounded-2xl bg-white/90 p-5 shadow-sm">
                      <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Items</p>
                      <div class="mt-4 space-y-3">
                        <c:forEach var="item" items="${order.items}">
                          <div class="rounded-2xl border border-slate-100 bg-slate-50 p-4">
                            <div class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
                              <div>
                                <p class="font-semibold text-ink"><c:out value="${item.name}" /></p>
                                <p class="mt-1 text-sm text-slate-600"><c:out value="${item.stripInfo}" /></p>
                              </div>
                              <div class="text-sm text-slate-600 sm:text-right">
                                <p>Qty: <c:out value="${item.quantity}" /></p>
                                <p>Total tablets: ${item.quantity * item.tabletsPerStrip}</p>
                                <p class="font-semibold text-ink">&#8377;<c:out value="${item.price}" /> / strip</p>
                              </div>
                            </div>
                          </div>
                        </c:forEach>
                      </div>
                    </div>

                    <div class="mt-6">
                      <c:choose>
                        <c:when test="${order.status ne 'CANCELLED' and order.status ne 'COMPLETED'}">
                          <form method="post" action="my_orders.jsp">
                            <input type="hidden" name="cancelOrderId" value="<c:out value='${order.orderId}' />" />
                            <button type="submit" class="inline-flex w-full items-center justify-center rounded-2xl border border-red-200 bg-red-50 px-4 py-3 text-sm font-semibold text-red-600 transition hover:border-red-300 hover:bg-red-100">
                              Cancel Order
                            </button>
                          </form>
                        </c:when>
                        <c:otherwise>
                          <button type="button" class="inline-flex w-full items-center justify-center rounded-2xl border border-slate-200 bg-slate-100 px-4 py-3 text-sm font-semibold text-slate-400" disabled>
                            <c:out value="${order.status eq 'COMPLETED' ? 'Order Completed' : 'Order Cancelled'}" />
                          </button>
                        </c:otherwise>
                      </c:choose>
                    </div>
                  </article>
                </c:forEach>
              </div>
            </c:otherwise>
          </c:choose>
        </div>
      </section>
    </main>

    <jsp:include page="/includes/footer.jsp" />
  </div>
</body>

</html>
