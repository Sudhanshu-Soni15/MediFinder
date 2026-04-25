<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.medifinder.dao.CartDAO,com.medifinder.dao.OrderDAO,java.net.URLEncoder,java.nio.charset.StandardCharsets,java.util.ArrayList,java.util.LinkedHashMap,java.util.List,java.util.Locale,java.util.Map"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%! 
  private String firstNonBlank(String... values) {
    if (values != null) {
      for (String value : values) {
        if (value != null && !value.trim().isEmpty()) {
          return value.trim();
        }
      }
    }
    return null;
  }

  private String normalize(String value, String defaultValue) {
    return (value == null || value.trim().isEmpty()) ? defaultValue : value.trim();
  }

  private int parseIntSafe(String value, int defaultValue) {
    try {
      int parsed = Integer.parseInt(normalize(value, String.valueOf(defaultValue)));
      return parsed < 1 ? defaultValue : parsed;
    } catch (Exception ignore) {
      return defaultValue;
    }
  }

  private double parseDoubleSafe(String value, double defaultValue) {
    try {
      double parsed = Double.parseDouble(normalize(value, String.valueOf(defaultValue)));
      return parsed < 0 ? defaultValue : parsed;
    } catch (Exception ignore) {
      return defaultValue;
    }
  }
%>
<%
if (!"USER".equals(session.getAttribute("role"))) {
  response.sendRedirect("login.jsp");
  return;
}

Object userEmail = session.getAttribute("userEmail");
String currentUserEmail = userEmail == null ? "" : String.valueOf(userEmail);
CartDAO cartDAO = new CartDAO();
List<Map<String, String>> cart = new ArrayList<Map<String, String>>();
try {
  cart = cartDAO.getCartByUser(currentUserEmail);
  session.setAttribute("cart", cart);
} catch (Exception ignore) {
  Object existingCart = session.getAttribute("cart");
  if (existingCart instanceof List<?>) {
    cart = (List<Map<String, String>>) existingCart;
  }
}

OrderDAO orderDAO = new OrderDAO();

String cartMessage = null;
String cartMessageType = null;
boolean isPost = "POST".equalsIgnoreCase(request.getMethod());
String action = request.getParameter("action");

String requestDeliveryType = request.getParameter("deliveryType");
String requestPickupTime = request.getParameter("pickupTime");
String requestDeliveryAddress = request.getParameter("deliveryAddress");
String requestDeliveryTime = request.getParameter("deliveryTime");

String sessionDeliveryType = (String) session.getAttribute("deliveryType");
String sessionPickupTime = (String) session.getAttribute("pickupTime");
String sessionDeliveryAddress = (String) session.getAttribute("deliveryAddress");
String sessionDeliveryTime = (String) session.getAttribute("deliveryTime");

String deliveryType = firstNonBlank(requestDeliveryType, sessionDeliveryType);
if (deliveryType == null) {
  deliveryType = "pickup";
} else {
  deliveryType = deliveryType.toLowerCase();
  if (!"pickup".equals(deliveryType) && !"delivery".equals(deliveryType)) {
    deliveryType = "pickup";
  }
}

String pickupTime = firstNonBlank(requestPickupTime, sessionPickupTime);
if (pickupTime == null) {
  pickupTime = "1 hour";
}

String deliveryAddress = firstNonBlank(requestDeliveryAddress, sessionDeliveryAddress);
if (deliveryAddress == null) {
  deliveryAddress = "";
}

String deliveryTime = firstNonBlank(requestDeliveryTime, sessionDeliveryTime);
if (deliveryTime == null) {
  deliveryTime = "2 hours";
}

if (isPost) {
  session.setAttribute("deliveryType", deliveryType);
  session.setAttribute("pickupTime", pickupTime);
  session.setAttribute("deliveryAddress", deliveryAddress);
  session.setAttribute("deliveryTime", deliveryTime);
}


if (isPost) {
  if ("update".equals(action)) {
    String itemId = request.getParameter("itemId");
    int quantity = parseIntSafe(request.getParameter("quantity"), 1);

    boolean updated = false;
    for (Map<String, String> cartItem : cart) {
      if (itemId != null && itemId.equals(cartItem.get("id"))) {
        cartItem.put("quantity", String.valueOf(quantity));
        updated = true;
        break;
      }
    }

    cartMessage = updated ? "Cart quantity updated." : "Cart item not found.";
    cartMessageType = updated ? "success" : "error";
  } else if ("remove".equals(action)) {
    String itemId = request.getParameter("itemId");
    boolean removed = false;

    for (int i = 0; i < cart.size(); i++) {
      if (itemId != null && itemId.equals(cart.get(i).get("id"))) {
        cart.remove(i);
        removed = true;
        break;
      }
    }

    cartMessage = removed ? "Item removed from cart." : "Cart item not found.";
    cartMessageType = removed ? "success" : "error";
  } else if ("clear".equals(action)) {
    cart.clear();
    try {
      cartDAO.clearCart(currentUserEmail);
    } catch (Exception ignore) {
    }
    session.removeAttribute("deliveryType");
    session.removeAttribute("pickupTime");
    session.removeAttribute("deliveryAddress");
    session.removeAttribute("deliveryTime");
    cartMessage = "Cart cleared successfully.";
    cartMessageType = "success";
  } else if ("placeOrder".equals(action)) {
    if (cart.isEmpty()) {
      cartMessage = "Your cart is empty.";
      cartMessageType = "error";
    } else if (!"pickup".equals(deliveryType) && !"delivery".equals(deliveryType)) {
      cartMessage = "Please choose a delivery type.";
      cartMessageType = "error";
    } else if ("pickup".equals(deliveryType) && pickupTime.length() == 0) {
      cartMessage = "Please choose a pickup time.";
      cartMessageType = "error";
    } else if ("delivery".equals(deliveryType) && deliveryAddress.length() == 0) {
      cartMessage = "Delivery address is required for home delivery.";
      cartMessageType = "error";
    } else if ("delivery".equals(deliveryType) && deliveryTime.length() == 0) {
      cartMessage = "Please choose a delivery window.";
      cartMessageType = "error";
    } else {
      List<Map<String, String>> orderItems = new ArrayList<Map<String, String>>();
      double itemsTotal = 0.0;
      double deliveryCharge = "delivery".equals(deliveryType) ? 20.0 : 0.0;
      String pharmacyName = cart.get(0).get("pharmacyName");
      String pharmacyEmail = cart.get(0).get("pharmacyEmail");

      for (Map<String, String> cartItem : cart) {
        Map<String, String> orderItem = new LinkedHashMap<String, String>(cartItem);
        orderItems.add(orderItem);

        int quantity = parseIntSafe(cartItem.get("quantity"), 1);
        double price = parseDoubleSafe(cartItem.get("price"), 0.0);

        itemsTotal += quantity * price;
      }

      Map<String, Object> order = new LinkedHashMap<String, Object>();
      order.put("orderId", "ORD-" + System.currentTimeMillis());
      order.put("userEmail", String.valueOf(session.getAttribute("userEmail")));
      order.put("userName", String.valueOf(session.getAttribute("userName")));
      order.put("pharmacyName", pharmacyName);
      order.put("pharmacyEmail", pharmacyEmail);
      order.put("items", orderItems);
      order.put("itemsTotal", String.format(Locale.US, "%.2f", itemsTotal));
      order.put("deliveryType", "pickup".equals(deliveryType) ? "Pickup from Pharmacy" : "Home Delivery");
      order.put("pickupTime", "pickup".equals(deliveryType) ? pickupTime : "");
      order.put("address", "delivery".equals(deliveryType) ? deliveryAddress : "");
      order.put("deliveryTime", "delivery".equals(deliveryType) ? deliveryTime : "");
      order.put("deliveryCharge", String.format(Locale.US, "%.2f", deliveryCharge));
      order.put("paymentMethod", "COD");
      order.put("paymentStatus", "PENDING");
      order.put("status", "PLACED");
      order.put("totalPrice", String.format(Locale.US, "%.2f", itemsTotal + deliveryCharge));
      
      
      try {
        boolean saved = orderDAO.placeOrder(order);
        if (saved) {
          try {
            new com.medifinder.dao.MedicineDAO().reduceStock(orderItems);
          } catch (Exception ignore) {
          }
          cart.clear();
          session.removeAttribute("deliveryType");
          session.removeAttribute("pickupTime");
          session.removeAttribute("deliveryAddress");
          session.removeAttribute("deliveryTime");
          try {
            cartDAO.clearCart(currentUserEmail);
          } catch (Exception ignore) {
          }
          session.setAttribute("cart", cart);
          response.sendRedirect("my_orders.jsp?orderMessage=" + URLEncoder.encode("Order placed successfully.", StandardCharsets.UTF_8));
          return;
        } else {
          cartMessage = "Order could not be placed. Please try again.";
          cartMessageType = "error";
        }
      } catch (Exception ex) {
        cartMessage = "Order placement failed while saving to database: " + ex.getMessage();
        cartMessageType = "error";
      }
    }
  }
  

  session.setAttribute("cart", cart);
  try {
    cartDAO.saveCart(currentUserEmail, cart);
  } catch (Exception ignore) {
  }
}

double itemsTotal = 0.0;
String cartPharmacy = cart.isEmpty() ? "" : String.valueOf(cart.get(0).get("pharmacyName"));
int totalStrips = 0;
int totalTablets = 0;

for (Map<String, String> cartItem : cart) {
  int quantity = parseIntSafe(cartItem.get("quantity"), 1);
  int tabletsPerStrip = parseIntSafe(cartItem.get("tabletsPerStrip"), 10);
  double price = parseDoubleSafe(cartItem.get("price"), 0.0);

  cartItem.put("quantity", String.valueOf(quantity));
  cartItem.put("tabletsPerStrip", String.valueOf(tabletsPerStrip));
  cartItem.put("price", String.format(Locale.US, "%.2f", price));
  cartItem.put("itemTotal", String.format(Locale.US, "%.2f", quantity * price));
  cartItem.put("totalTablets", String.valueOf(quantity * tabletsPerStrip));
  totalStrips += quantity;
  totalTablets += quantity * tabletsPerStrip;
  itemsTotal += quantity * price;
}

session.setAttribute("cart", cart);

double deliveryChargeValue = "delivery".equals(deliveryType) ? 20.0 : 0.0;
double finalTotal = itemsTotal + deliveryChargeValue;

request.setAttribute("cartMessage", cartMessage);
request.setAttribute("cartMessageType", cartMessageType);
request.setAttribute("cartPharmacy", cartPharmacy);
request.setAttribute("itemsTotalDisplay", String.format(Locale.US, "%.2f", itemsTotal));
request.setAttribute("deliveryChargeDisplay", String.format(Locale.US, "%.2f", deliveryChargeValue));
request.setAttribute("finalTotalDisplay", String.format(Locale.US, "%.2f", finalTotal));
request.setAttribute("totalStrips", Integer.valueOf(totalStrips));
request.setAttribute("totalTablets", Integer.valueOf(totalTablets));
request.setAttribute("selectedDeliveryType", deliveryType);
request.setAttribute("selectedPickupTime", pickupTime);
request.setAttribute("selectedDeliveryAddress", deliveryAddress);
request.setAttribute("selectedDeliveryTime", deliveryTime);
%>
<!doctype html>
<html lang="en">

<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>MediFinder | Cart</title>

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
      <jsp:param name="active" value="cart" />
    </jsp:include>

    <main class="flex-1">
      <section class="relative overflow-hidden px-4 py-12 sm:px-6 sm:py-16 lg:py-20" style="background: var(--bg-gradient)">
        <div class="absolute right-20 top-16 h-72 w-72 rounded-full bg-teal/30 blur-3xl"></div>
        <div class="absolute -bottom-8 left-0 h-72 w-72 rounded-full bg-coral/20 blur-3xl"></div>

        <div class="mx-auto max-w-6xl">
          <div class="max-w-3xl">
            <p class="text-xs font-semibold uppercase tracking-[0.25em] text-teal">Cart</p>
            <h1 class="mt-4 text-4xl font-bold text-ink sm:text-5xl">Review your medicine cart</h1>
            <p class="mt-4 text-base text-slate-600 sm:text-lg">Only medicines from one pharmacy can be checked out together.</p>
          </div>

          <c:if test="${not empty cartMessage}">
            <div class="mt-8 rounded-2xl border px-4 py-3 text-sm font-medium shadow-soft ${cartMessageType eq 'success' ? 'border-emerald-200 bg-emerald-50 text-emerald-700' : 'border-red-200 bg-red-50 text-red-700'}">
              <c:out value="${cartMessage}" />
            </div>
          </c:if>

          <c:choose>
            <c:when test="${empty sessionScope.cart}">
              <div class="glass mt-10 rounded-3xl p-8 text-center shadow-soft sm:p-10">
                <h2 class="text-2xl font-bold text-ink">Your cart is empty</h2>
                <p class="mt-3 text-sm text-slate-600">Add medicines from a pharmacy to start an order.</p>
                <a href="search.jsp" class="mt-6 inline-flex items-center justify-center rounded-2xl bg-gradient-to-r from-orange-500 to-pink-500 px-6 py-3 text-sm font-semibold text-white shadow-lg transition hover:scale-[1.01] hover:shadow-xl">
                  Search Medicines
                </a>
              </div>
            </c:when>
            <c:otherwise>
              <div class="mt-10 grid gap-8 lg:grid-cols-[1.35fr_0.95fr]">
              
                <section class="space-y-5">
                  <c:forEach var="item" items="${sessionScope.cart}">
                    <article class="glass rounded-3xl p-6 shadow-soft">
                      <div class="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
                        <div>
                          <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Medicine</p>
                          <h2 class="mt-2 text-2xl font-bold text-ink"><c:out value="${item.name}" /></h2>
                          <p class="mt-2 text-sm text-slate-600"><c:out value="${item.stripInfo}" /></p>
                          <p class="mt-1 text-sm text-slate-600">Total tablets: <c:out value="${item.totalTablets}" /></p>
                          <p class="mt-1 text-sm text-slate-600">Price per strip: &#8377;<c:out value="${item.price}" /></p>
                        </div>
                        <div class="rounded-2xl bg-white/90 px-4 py-3 text-right shadow-sm">
                          <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Item Total</p>
                          <p class="mt-2 text-xl font-semibold text-ink">&#8377;<c:out value="${item.itemTotal}" /></p>
                        </div>
                      </div>

                    <div class="mt-6 space-y-4">

                    <!-- UPDATE FORM -->
                     <form method="post" action="cart.jsp"
                          class="flex flex-col gap-3 sm:flex-row sm:items-end rounded-2xl bg-white/90 p-4 shadow-sm">

                      <input type="hidden" name="action" value="update" />
                      <input type="hidden" name="itemId" value="<c:out value='${item.id}' />" />
                      <input type="hidden" name="deliveryType" value="<c:out value='${selectedDeliveryType}' />" />
                      <input type="hidden" name="pickupTime" value="<c:out value='${selectedPickupTime}' />" />
                      <input type="hidden" name="deliveryAddress" value="<c:out value='${selectedDeliveryAddress}' />" />
                      <input type="hidden" name="deliveryTime" value="<c:out value='${selectedDeliveryTime}' />" />

                      <div class="flex-1">
                        <label class="mb-2 block text-xs font-semibold uppercase tracking-[0.2em] text-slate-500">
                          Quantity
                        </label>
                        <input type="number" min="1" name="quantity"
                              value="<c:out value='${item.quantity}' />"
                              class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm focus:border-orange-300 focus:ring-4 focus:ring-orange-100" />
                      </div>

                      <button type="submit"
                        class="rounded-xl bg-orange-500 text-white px-5 py-3 text-sm font-semibold hover:bg-orange-600">
                        Update
                      </button>
                      </form>

                    <!-- REMOVE FORM -->
                    <form method="post" action="cart.jsp">
                      <input type="hidden" name="action" value="remove" />
                      <input type="hidden" name="itemId" value="<c:out value='${item.id}' />" />
                      <input type="hidden" name="deliveryType" value="<c:out value='${selectedDeliveryType}' />" />
                      <input type="hidden" name="pickupTime" value="<c:out value='${selectedPickupTime}' />" />
                      <input type="hidden" name="deliveryAddress" value="<c:out value='${selectedDeliveryAddress}' />" />
                      <input type="hidden" name="deliveryTime" value="<c:out value='${selectedDeliveryTime}' />" />

                      <button type="submit"
                        class="w-full rounded-xl border border-red-300 bg-red-50 px-5 py-2 text-sm font-semibold text-red-600 hover:bg-red-100 sm:w-fit">
                        Remove Item
                      </button>
                    </form>

                    </div>
                    </article>
                  </c:forEach>
                </section>

                <aside class="glass rounded-3xl p-6 shadow-soft sm:p-8">
                  <div class="rounded-2xl bg-white/90 p-5 shadow-sm">
                    <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Pharmacy</p>
                    <p class="mt-2 text-xl font-semibold text-ink"><c:out value="${cartPharmacy}" /></p>
                  </div>

                  <div class="mt-4 grid gap-4 sm:grid-cols-2 lg:grid-cols-1">
                    <div class="rounded-2xl bg-white/90 p-5 shadow-sm">
                      <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Total Strips</p>
                      <p class="mt-2 text-xl font-semibold text-ink"><c:out value="${totalStrips}" /></p>
                    </div>
                    <div class="rounded-2xl bg-white/90 p-5 shadow-sm">
                      <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Total Tablets</p>
                      <p class="mt-2 text-xl font-semibold text-ink"><c:out value="${totalTablets}" /></p>
                    </div>
                  </div>

                  <form method="post" action="cart.jsp" class="mt-4 space-y-4">
                    <input type="hidden" name="action" value="placeOrder" />

                    <div class="rounded-2xl border border-slate-100 bg-white/90 p-5 shadow-sm">
                      <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Delivery Type</p>
                      <div class="mt-4 grid gap-3 sm:grid-cols-2 lg:grid-cols-1">
                        <label class="flex cursor-pointer items-center gap-3 rounded-2xl border px-4 py-3 ${selectedDeliveryType eq 'pickup' ? 'border-orange-200 bg-orange-50' : 'border-slate-200 bg-white'}">
                          <input type="radio" name="deliveryType" value="pickup" class="h-4 w-4 border-slate-300 text-orange-500 focus:ring-orange-400" <c:if test="${selectedDeliveryType eq 'pickup'}">checked</c:if> />
                          <span class="text-sm font-semibold text-ink">Pickup from Pharmacy</span>
                        </label>
                        <label class="flex cursor-pointer items-center gap-3 rounded-2xl border px-4 py-3 ${selectedDeliveryType eq 'delivery' ? 'border-orange-200 bg-orange-50' : 'border-slate-200 bg-white'}">
                          <input type="radio" name="deliveryType" value="delivery" class="h-4 w-4 border-slate-300 text-orange-500 focus:ring-orange-400" <c:if test="${selectedDeliveryType eq 'delivery'}">checked</c:if> />
                          <span class="text-sm font-semibold text-ink">Home Delivery (COD)</span>
                        </label>
                      </div>
                    </div>

                    <div id="pickupFields" class="rounded-2xl border border-slate-100 bg-white/90 p-5 shadow-sm ${selectedDeliveryType eq 'pickup' ? '' : 'hidden'}">
                      <label for="pickupTime" class="mb-2 block text-xs font-semibold uppercase tracking-[0.2em] text-slate-500">Pickup Time</label>
                      <select id="pickupTime" name="pickupTime" class="w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-700 outline-none transition focus:border-orange-300 focus:ring-4 focus:ring-orange-100">
                        <option value="30 mins" <c:if test="${selectedPickupTime eq '30 mins'}">selected</c:if>>30 mins</option>
                        <option value="1 hour" <c:if test="${selectedPickupTime eq '1 hour'}">selected</c:if>>1 hour</option>
                        <option value="2 hours" <c:if test="${selectedPickupTime eq '2 hours'}">selected</c:if>>2 hours</option>
                      </select>
                    </div>

                    <div id="deliveryFields" class="space-y-4 ${selectedDeliveryType eq 'delivery' ? '' : 'hidden'}">
                      <div class="rounded-2xl border border-slate-100 bg-white/90 p-5 shadow-sm">
                        <label for="deliveryAddress" class="mb-2 block text-xs font-semibold uppercase tracking-[0.2em] text-slate-500">Delivery Address</label>
                        <textarea id="deliveryAddress" name="deliveryAddress" rows="3" class="w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-700 outline-none transition focus:border-orange-300 focus:ring-4 focus:ring-orange-100"><c:out value="${selectedDeliveryAddress}" /></textarea>
                      </div>
                      <div class="rounded-2xl border border-slate-100 bg-white/90 p-5 shadow-sm">
                        <label for="deliveryTime" class="mb-2 block text-xs font-semibold uppercase tracking-[0.2em] text-slate-500">Delivery Time</label>
                        <select id="deliveryTime" name="deliveryTime" class="w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-700 outline-none transition focus:border-orange-300 focus:ring-4 focus:ring-orange-100">
                          <option value="2 hours" <c:if test="${selectedDeliveryTime eq '2 hours'}">selected</c:if>>2 hours</option>
                          <option value="Same day" <c:if test="${selectedDeliveryTime eq 'Same day'}">selected</c:if>>Same day</option>
                        </select>
                      </div>
                    </div>

                    <div class="rounded-2xl bg-orange-50 p-5" data-items-total="${itemsTotalDisplay}">
                      <div class="flex items-center justify-between text-sm text-slate-600">
                        <span>Items Total</span>
                        <span class="font-semibold text-ink">&#8377;<c:out value="${itemsTotalDisplay}" /></span>
                      </div>
                      <div class="mt-3 flex items-center justify-between text-sm text-slate-600">
                        <span>Delivery Charge</span>
                        <span id="deliveryChargeDisplay" class="font-semibold text-ink">&#8377;<c:out value="${deliveryChargeDisplay}" /></span>
                      </div>
                      <div class="mt-4 flex items-center justify-between border-t border-orange-200 pt-4">
                        <span class="text-xs uppercase tracking-[0.2em] text-orange-600">Final Total</span>
                        <span id="finalTotalDisplay" class="text-3xl font-bold text-ink">&#8377;<c:out value="${finalTotalDisplay}" /></span>
                      </div>
                      <p class="mt-3 text-sm text-slate-600">Payment method: Cash on Delivery</p>
                    </div>

                    <button type="submit" class="inline-flex w-full items-center justify-center rounded-2xl bg-gradient-to-r from-orange-500 to-pink-500 px-6 py-3 text-sm font-semibold text-white shadow-lg transition hover:scale-[1.01] hover:shadow-xl">
                      Place Order
                    </button>
                  </form>

                    <form method="post" action="cart.jsp" class="mt-3">
                      <input type="hidden" name="action" value="clear" />
                      <button type="submit" class="inline-flex w-full items-center justify-center rounded-2xl border border-slate-200 bg-white px-6 py-3 text-sm font-semibold text-ink shadow-sm transition hover:border-slate-300 hover:bg-slate-50">
                        Clear Cart
                    </button>
                  </form>
                </aside>
              </div>
            </c:otherwise>
          </c:choose>
        </div>
      </section>
    </main>

    <jsp:include page="/includes/footer.jsp" />
  </div>

  
  <script>
  (function () {
    var deliveryInputs = document.querySelectorAll("input[name='deliveryType']");
    var pickupFields   = document.getElementById("pickupFields");
    var deliveryFields = document.getElementById("deliveryFields");
    var totalsCard            = document.querySelector("[data-items-total]");
    var deliveryChargeDisplay = document.getElementById("deliveryChargeDisplay");
    var finalTotalDisplay     = document.getElementById("finalTotalDisplay");

    /* ── helpers ── */
    function formatAmount(v) { return v.toFixed(2); }

    function getSelectedDeliveryType() {
      var sel = "pickup";
      deliveryInputs.forEach(function (i) { if (i.checked) sel = i.value; });
      return sel;
    }

    /* ── show/hide sidebar panels + update totals ── */
    function updateDeliveryView() {
      var selected = getSelectedDeliveryType();

      if (selected === "delivery") {
        pickupFields.classList.add("hidden");
        deliveryFields.classList.remove("hidden");
      } else {
        pickupFields.classList.remove("hidden");
        deliveryFields.classList.add("hidden");
      }

      if (totalsCard && deliveryChargeDisplay && finalTotalDisplay) {
        var itemsTotal   = parseFloat(totalsCard.getAttribute("data-items-total")) || 0;
        var deliveryCharge = selected === "delivery" ? 20 : 0;
        deliveryChargeDisplay.textContent = "\u20B9" + formatAmount(deliveryCharge);
        finalTotalDisplay.textContent     = "\u20B9" + formatAmount(itemsTotal + deliveryCharge);
      }
    }

    deliveryInputs.forEach(function (i) {
      i.addEventListener("change", updateDeliveryView);
    });
    updateDeliveryView();

    /* ── FIX: sync live sidebar values into every update/remove form ── */
    function syncHiddenFields(form) {
      var deliveryType    = getSelectedDeliveryType();
      var pickupTime      = document.getElementById("pickupTime")      ? document.getElementById("pickupTime").value      : "";
      var deliveryAddress = document.getElementById("deliveryAddress") ? document.getElementById("deliveryAddress").value : "";
      var deliveryTime    = document.getElementById("deliveryTime")    ? document.getElementById("deliveryTime").value    : "";

      function setHidden(name, value) {
        var el = form.querySelector("input[name='" + name + "']");
        if (el) el.value = value;
      }

      setHidden("deliveryType",    deliveryType);
      setHidden("pickupTime",      pickupTime);
      setHidden("deliveryAddress", deliveryAddress);
      setHidden("deliveryTime",    deliveryTime);
    }

    /* attach to every form whose action is update or remove */
    document.querySelectorAll("form[method='post']").forEach(function (form) {
      var actionInput = form.querySelector("input[name='action']");
      if (actionInput && (actionInput.value === "update" || actionInput.value === "remove")) {
        form.addEventListener("submit", function () {
          syncHiddenFields(form);
        });
      }
    });

  })();
</script>
</body>

</html>
