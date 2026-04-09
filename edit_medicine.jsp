<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList,java.util.List,java.util.Map"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
if (session.getAttribute("userEmail") == null || !"PHARMACY".equals(session.getAttribute("role"))) {
  response.sendRedirect("login.jsp");
  return;
}

List<Map<String, String>> medicines = (List<Map<String, String>>) application.getAttribute("medicines");
if (medicines == null) {
  medicines = new ArrayList<Map<String, String>>();
  application.setAttribute("medicines", medicines);
}

String medicineId = request.getParameter("id");
String medicineName = request.getParameter("name");
String price = request.getParameter("price");
String stock = request.getParameter("stock");
String pharmacyEmail = String.valueOf(session.getAttribute("userEmail"));
String error = null;
boolean isPost = "POST".equalsIgnoreCase(request.getMethod());
Map<String, String> editableMedicine = null;

medicineId = medicineId == null ? "" : medicineId.trim();
medicineName = medicineName == null ? "" : medicineName.trim();
price = price == null ? "" : price.trim();
stock = stock == null ? "" : stock.trim();

for (Map<String, String> medicine : medicines) {
  if (medicineId.equals(medicine.get("id")) && pharmacyEmail.equalsIgnoreCase(medicine.get("pharmacyEmail"))) {
    editableMedicine = medicine;
    break;
  }
}

if (editableMedicine == null) {
  response.sendRedirect("pharmacy_dashboard.jsp");
  return;
}

if (!isPost) {
  medicineName = editableMedicine.get("name") == null ? "" : editableMedicine.get("name");
  price = editableMedicine.get("price") == null ? "" : editableMedicine.get("price");
  stock = editableMedicine.get("stock") == null ? "" : editableMedicine.get("stock");
}

if (isPost) {
  if (medicineName.isEmpty() || price.isEmpty() || stock.isEmpty()) {
    error = "All fields are required.";
  } else if (!price.matches("\\d+(\\.\\d{1,2})?")) {
    error = "Enter a valid price.";
  } else if (!stock.matches("\\d+")) {
    error = "Stock must be a whole number.";
  } else {
    editableMedicine.put("name", medicineName);
    editableMedicine.put("price", price);
    editableMedicine.put("stock", stock);
    application.setAttribute("medicines", medicines);
    response.sendRedirect("pharmacy_dashboard.jsp");
    return;
  }
}

request.setAttribute("error", error);
request.setAttribute("medicineFormId", medicineId);
request.setAttribute("medicineFormName", medicineName);
request.setAttribute("medicineFormPrice", price);
request.setAttribute("medicineFormStock", stock);
%>
<!doctype html>
<html lang="en">

<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>MediFinder | Edit Medicine</title>

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
      <jsp:param name="active" value="dashboard" />
    </jsp:include>

    <main class="flex-1">
      <section class="relative overflow-hidden px-4 py-12 sm:px-6 sm:py-16" style="background: var(--bg-gradient)">
        <div class="pointer-events-none absolute right-20 top-16 h-72 w-72 rounded-full bg-teal/20 blur-3xl"></div>
        <div class="pointer-events-none absolute -bottom-8 left-0 h-72 w-72 rounded-full bg-coral/20 blur-3xl"></div>

        <div class="relative z-10 mx-auto flex min-h-[70vh] max-w-6xl items-center justify-center">
          <div class="glass w-full max-w-lg rounded-3xl p-6 shadow-soft sm:p-8">
            <div class="text-center">
              <div class="mx-auto grid h-14 w-14 place-items-center rounded-2xl bg-gradient-to-r from-orange-500 to-pink-500 text-base font-bold text-white shadow-md">
                MF
              </div>
              <h1 class="mt-5 text-3xl font-bold text-ink sm:text-4xl">Edit Medicine</h1>
              <p class="mt-3 text-sm text-slate-600 sm:text-base">Update your medicine listing details</p>
            </div>

            <form id="editMedicineForm" method="post" action="edit_medicine.jsp" class="mt-8 space-y-5">
              <input type="hidden" name="id" value="<c:out value='${medicineFormId}' />" />

              <c:if test="${not empty error}">
                <p class="rounded-2xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-500">
                  <c:out value="${error}" />
                </p>
              </c:if>

              <div>
                <label for="name" class="mb-2 block text-sm font-semibold text-ink">Medicine Name</label>
                <input id="name" name="name" type="text" value="<c:out value='${medicineFormName}' />" placeholder="Enter medicine name" class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-700 outline-none transition focus:border-orange-300 focus:bg-white focus:ring-4 focus:ring-orange-100" required />
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

              <button id="editMedicineSubmitBtn" type="submit" class="w-full rounded-2xl bg-gradient-to-r from-orange-500 to-pink-500 px-6 py-3 text-sm font-semibold text-white shadow-lg transition hover:scale-[1.01] hover:shadow-xl disabled:cursor-not-allowed disabled:opacity-60">
                Update Medicine
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
      const form = document.getElementById("editMedicineForm");
      const nameInput = document.getElementById("name");
      const priceInput = document.getElementById("price");
      const stockInput = document.getElementById("stock");
      const submitButton = document.getElementById("editMedicineSubmitBtn");

      function updateSubmitState() {
        submitButton.disabled =
          nameInput.value.trim() === "" ||
          priceInput.value.trim() === "" ||
          stockInput.value.trim() === "";
      }

      nameInput.addEventListener("input", updateSubmitState);
      priceInput.addEventListener("input", updateSubmitState);
      stockInput.addEventListener("input", updateSubmitState);
      form.addEventListener("submit", updateSubmitState);
      updateSubmitState();
    })();
  </script>
</body>

</html>
