<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.medifinder.util.DBConnection,java.sql.Connection,java.sql.PreparedStatement,java.sql.ResultSet,java.util.ArrayList,java.util.LinkedHashMap,java.util.List,java.util.Map"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
if (session.getAttribute("userEmail") == null || !"PHARMACY".equals(session.getAttribute("role"))) {
  response.sendRedirect("login.jsp");
  return;
}

String medicineName = request.getParameter("name");
String description = request.getParameter("description");
String price = request.getParameter("price");
String stock = request.getParameter("stock");
String error = null;
boolean isPost = "POST".equalsIgnoreCase(request.getMethod());

medicineName = medicineName == null ? "" : medicineName.trim();
description = description == null ? "" : description.trim();
price = price == null ? "" : price.trim();
stock = stock == null ? "" : stock.trim();

if (isPost) {
  List<Map<String, String>> medicines = (List<Map<String, String>>) application.getAttribute("medicines");
  if (medicines == null) {
    medicines = new ArrayList<Map<String, String>>();
  }

  if (medicineName.isEmpty() || price.isEmpty() || stock.isEmpty()) {
    error = "All fields are required.";
  } else if (!price.matches("\\d+(\\.\\d{1,2})?")) {
    error = "Enter a valid price.";
  } else if (!stock.matches("\\d+")) {
    error = "Stock must be a whole number.";
  } else {
    String pharmacyEmail = String.valueOf(session.getAttribute("userEmail"));
    String pharmacyName = String.valueOf(session.getAttribute("userName"));
    String ensureDescSql = "ALTER TABLE public.medicines ADD COLUMN IF NOT EXISTS description TEXT";
    String insertSql = "INSERT INTO public.medicines "
        + "(medicine_name, description, price, stock, pharmacy_email, pharmacy_name, tablets_per_strip, strip_info, distance, rating) "
        + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?) "
        + "RETURNING medicine_id";

    try (Connection connection = DBConnection.getConnection();
         PreparedStatement ensureDesc = connection.prepareStatement(ensureDescSql);
         PreparedStatement statement = connection.prepareStatement(insertSql)) {
      ensureDesc.execute();

      statement.setString(1, medicineName);
      statement.setString(2, description);
      statement.setDouble(3, Double.parseDouble(price));
      statement.setInt(4, Integer.parseInt(stock));
      statement.setString(5, pharmacyEmail);
      statement.setString(6, pharmacyName);
      statement.setInt(7, 10);
      statement.setString(8, "1 strip = 10 tablets");
      statement.setDouble(9, 1.0);
      statement.setDouble(10, 4.0);

      String generatedMedicineId = "";
      try (ResultSet rs = statement.executeQuery()) {
        if (rs.next()) {
          generatedMedicineId = String.valueOf(rs.getInt(1));
        }
      }

      Map<String, String> medicine = new LinkedHashMap<String, String>();
      medicine.put("id", generatedMedicineId);
      medicine.put("name", medicineName);
      medicine.put("description", description);
      medicine.put("price", price);
      medicine.put("stock", stock);
      medicine.put("pharmacyEmail", pharmacyEmail);
      medicine.put("pharmacyName", pharmacyName);
      medicines.add(medicine);
      application.setAttribute("medicines", medicines);

      response.sendRedirect("pharmacy_dashboard.jsp");
      return;
    } catch (Exception ex) {
      error = "Failed to save medicine to database: " + ex.getMessage();
    }
  }
}

request.setAttribute("error", error);
request.setAttribute("medicineFormName", medicineName);
request.setAttribute("medicineFormDescription", description);
request.setAttribute("medicineFormPrice", price);
request.setAttribute("medicineFormStock", stock);
%>
<!doctype html>
<html lang="en">

<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>MediFinder | Add Medicine</title>

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
      <jsp:param name="active" value="addmedicine" />
    </jsp:include>

    <main class="flex-1">
      <section class="relative overflow-hidden px-4 py-12 sm:px-6 sm:py-16" style="background: var(--bg-gradient)">
        <div class="absolute right-20 top-16 h-72 w-72 rounded-full bg-teal/20 blur-3xl"></div>
        <div class="absolute -bottom-8 left-0 h-72 w-72 rounded-full bg-coral/20 blur-3xl"></div>

        <div class="mx-auto flex min-h-[70vh] max-w-6xl items-center justify-center">
          <div class="glass w-full max-w-lg rounded-3xl p-6 shadow-soft sm:p-8">
            <div class="text-center">
              <div class="mx-auto grid h-14 w-14 place-items-center rounded-2xl bg-gradient-to-r from-orange-500 to-pink-500 text-base font-bold text-white shadow-md">
                MF
              </div>
              <h1 class="mt-5 text-3xl font-bold text-ink sm:text-4xl">Add Medicine</h1>
              <p class="mt-3 text-sm text-slate-600 sm:text-base">Publish a medicine listing for your pharmacy</p>
            </div>

            <form id="addMedicineForm" method="post" action="add_medicine.jsp" class="mt-8 space-y-5">
              <c:if test="${not empty error}">
                <p class="rounded-2xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-500">
                  <c:out value="${error}" />
                </p>
              </c:if>

              <div>
                <label for="name" class="mb-2 block text-sm font-semibold text-ink">Medicine Name</label>
                <input id="name" name="name" type="text" value="<c:out value='${medicineFormName}' />" placeholder="Enter medicine name" class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-700 outline-none transition focus:border-orange-300 focus:bg-white focus:ring-4 focus:ring-orange-100" required />
              </div>

              <div>
                <label for="description" class="mb-2 block text-sm font-semibold text-ink">Description</label>
                <textarea id="description" name="description" rows="3" placeholder="Enter medicine description" class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-700 outline-none transition focus:border-orange-300 focus:bg-white focus:ring-4 focus:ring-orange-100"><c:out value='${medicineFormDescription}' /></textarea>
              </div>

              <div class="grid gap-5 sm:grid-cols-2">
                <div>
                  <label for="price" class="mb-2 block text-sm font-semibold text-ink">Price</label>
                  <input id="price" name="price" type="text" value="<c:out value='${medicineFormPrice}' />" placeholder="e.g. 45" class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-700 outline-none transition focus:border-orange-300 focus:bg-white focus:ring-4 focus:ring-orange-100" required />
                </div>

                <div>
                  <label for="stock" class="mb-2 block text-sm font-semibold text-ink">Stock</label>
                  <input id="stock" name="stock" type="number" min="0" value="<c:out value='${medicineFormStock}' />" placeholder="Available units" class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-700 outline-none transition focus:border-orange-300 focus:bg-white focus:ring-4 focus:ring-orange-100" required />
                </div>
              </div>

              <button id="addMedicineSubmitBtn" type="submit" class="w-full rounded-2xl bg-gradient-to-r from-orange-500 to-pink-500 px-6 py-3 text-sm font-semibold text-white shadow-lg transition hover:scale-[1.01] hover:shadow-xl disabled:cursor-not-allowed disabled:opacity-60">
                Save Medicine
              </button>
            </form>

            <p class="mt-6 text-center text-sm text-slate-600">
              Return to
              <a href="pharmacy_dashboard.jsp" class="font-semibold text-orange-600 transition hover:text-orange-700">Pharmacy Dashboard</a>
            </p>
          </div>
        </div>
      </section>
    </main>

    <jsp:include page="/includes/footer.jsp" />
  </div>

  <script>
    (function () {
      const form = document.getElementById("addMedicineForm");
      const nameInput = document.getElementById("name");
      const descInput = document.getElementById("description");
      const priceInput = document.getElementById("price");
      const stockInput = document.getElementById("stock");
      const submitButton = document.getElementById("addMedicineSubmitBtn");

      function updateSubmitState() {
        submitButton.disabled =
          nameInput.value.trim() === "" ||
          priceInput.value.trim() === "" ||
          stockInput.value.trim() === "";
      }

      nameInput.addEventListener("input", updateSubmitState);
      descInput.addEventListener("input", updateSubmitState);
      priceInput.addEventListener("input", updateSubmitState);
      stockInput.addEventListener("input", updateSubmitState);
      form.addEventListener("submit", updateSubmitState);
      updateSubmitState();
    })();
  </script>
</body>

</html>
