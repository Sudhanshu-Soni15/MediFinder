<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ page import="com.medifinder.dao.UserDAO,com.medifinder.dao.PharmacyDAO,com.medifinder.dao.MedicineDAO,java.util.*"%>
<%
  if (!"ADMIN".equals(session.getAttribute("role"))) {
    response.sendRedirect("admin_login.jsp");
    return;
  }

  UserDAO userDAO = new UserDAO();
  PharmacyDAO pharmacyDAO = new PharmacyDAO();
  MedicineDAO medicineDAO = new MedicineDAO();

  List<Map<String, String>> users = userDAO.getAllUsers();
  List<Map<String, String>> pharmacies = pharmacyDAO.getAllPharmacies();

  // pharmacy_email -> medicines[]
  Map<String, List<Map<String, String>>> pharmacyMedicines = new LinkedHashMap<String, List<Map<String, String>>>();
  for (Map<String, String> p : pharmacies) {
    String email = p.get("email");
    if (email == null) email = "";
    email = email.trim();
    if (!email.isEmpty()) {
      pharmacyMedicines.put(email, medicineDAO.getMedicinesByPharmacy(email));
    } else {
      pharmacyMedicines.put("", new ArrayList<Map<String, String>>());
    }
  }

  request.setAttribute("users", users);
  request.setAttribute("pharmacies", pharmacies);
  request.setAttribute("pharmacyMedicines", pharmacyMedicines);
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>MediFinder | Admin Panel</title>

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
      --bg-gradient: radial-gradient(800px circle at 5% 10%, rgba(245, 158, 11, 0.18), transparent 40%),
        radial-gradient(700px circle at 95% 0%, rgba(251, 113, 133, 0.15), transparent 40%),
        linear-gradient(180deg, #fff7ed 0%, #f8fafc 100%);
    }
    body {
      font-family: "Space Grotesk", system-ui, -apple-system, sans-serif;
      background: #fff7ed;
      color: #2b1f1b;
      min-height: 100vh;
    }
    .glass {
      background: rgba(255, 255, 255, 0.78);
      backdrop-filter: blur(14px);
      border: 1px solid rgba(255, 255, 255, 0.7);
    }
    .mono {
      font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace;
    }
  </style>
</head>
<body class="text-ink">
  <div class="min-h-screen flex flex-col">
    <jsp:include page="/includes/navbar.jsp" />

    <main class="flex-1" style="background: var(--bg-gradient)">
      <section class="px-4 py-10 sm:px-6 sm:py-14">
        <div class="mx-auto max-w-7xl">
          <div class="glass rounded-3xl p-6 shadow-soft sm:p-8">
            <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <p class="text-xs font-semibold uppercase tracking-[0.25em] text-teal">MediFinder</p>
                <h1 class="mt-2 text-3xl font-bold text-ink sm:text-4xl">Admin Panel</h1>
                <p class="mt-2 text-sm text-slate-600 sm:text-base">
                  Viewing all users, pharmacies, and pharmacy medicines.
                </p>
              </div>
              <div class="flex flex-wrap gap-3">
                <a href="home.jsp" class="inline-flex items-center justify-center rounded-2xl border border-orange-200 bg-orange-50 px-5 py-3 text-sm font-semibold text-orange-600 transition hover:border-orange-300 hover:bg-orange-100">
                  Back to Home
                </a>
                <a href="logout.jsp" class="inline-flex items-center justify-center rounded-2xl bg-gradient-to-r from-orange-500 to-pink-500 px-5 py-3 text-sm font-semibold text-white shadow-lg transition hover:scale-[1.01] hover:shadow-xl">
                  Logout
                </a>
              </div>
            </div>

            <div class="mt-8 grid gap-4 sm:grid-cols-3">
              <div class="rounded-2xl border border-slate-200 bg-white/80 px-5 py-4">
                <p class="text-xs font-semibold uppercase tracking-[0.2em] text-slate-500">Total Users</p>
                <p class="mt-2 text-2xl font-bold text-ink"><c:out value="${fn:length(users)}" /></p>
              </div>
              <div class="rounded-2xl border border-slate-200 bg-white/80 px-5 py-4">
                <p class="text-xs font-semibold uppercase tracking-[0.2em] text-slate-500">Total Pharmacies</p>
                <p class="mt-2 text-2xl font-bold text-ink"><c:out value="${fn:length(pharmacies)}" /></p>
              </div>
              <div class="rounded-2xl border border-slate-200 bg-white/80 px-5 py-4">
                <p class="text-xs font-semibold uppercase tracking-[0.2em] text-slate-500">Session</p>
                <p class="mt-2 text-sm text-slate-700">Role: <span class="mono"><c:out value="${sessionScope.role}" /></span></p>
                <p class="mt-1 text-sm text-slate-700">User: <span class="mono"><c:out value="${sessionScope.userName}" /></span></p>
              </div>
            </div>

            <div class="mt-10 grid gap-8 lg:grid-cols-2">
              <!-- Users table -->
              <div class="glass rounded-3xl p-5 shadow-soft sm:p-6">
                <div class="flex items-end justify-between gap-4">
                  <div>
                    <h2 class="text-xl font-bold text-ink">Users</h2>
                    <p class="mt-1 text-sm text-slate-600">All registered users from `users` table.</p>
                  </div>
                </div>

                <div class="mt-5 overflow-hidden rounded-2xl border border-slate-200 bg-white/80">
                  <div class="overflow-x-auto">
                    <table class="min-w-full text-left text-sm">
                      <thead class="bg-slate-50 text-xs uppercase tracking-wider text-slate-600">
                        <tr>
                          <th class="px-4 py-3">ID</th>
                          <th class="px-4 py-3">Name</th>
                          <th class="px-4 py-3">Email</th>
                          <th class="px-4 py-3">Phone</th>
                          <th class="px-4 py-3">Role</th>
                          <th class="px-4 py-3">Lat</th>
                          <th class="px-4 py-3">Lng</th>
                        </tr>
                      </thead>
                      <tbody class="divide-y divide-slate-200">
                        <c:forEach var="u" items="${users}">
                          <tr class="hover:bg-orange-50/50">
                            <td class="px-4 py-3 mono text-slate-700"><c:out value="${u.user_id}" /></td>
                            <td class="px-4 py-3 font-semibold text-ink"><c:out value="${u.name}" /></td>
                            <td class="px-4 py-3 text-slate-700"><c:out value="${u.email}" /></td>
                            <td class="px-4 py-3 text-slate-700"><c:out value="${u.phone}" /></td>
                            <td class="px-4 py-3"><span class="rounded-full bg-slate-100 px-3 py-1 text-xs font-semibold text-slate-700"><c:out value="${u.role}" /></span></td>
                            <td class="px-4 py-3 mono text-slate-700"><c:out value="${u.latitude}" /></td>
                            <td class="px-4 py-3 mono text-slate-700"><c:out value="${u.longitude}" /></td>
                          </tr>
                        </c:forEach>
                        <c:if test="${empty users}">
                          <tr>
                            <td class="px-4 py-6 text-center text-slate-500" colspan="7">No users found.</td>
                          </tr>
                        </c:if>
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>

              <!-- Pharmacies + medicines -->
              <div class="glass rounded-3xl p-5 shadow-soft sm:p-6">
                <h2 class="text-xl font-bold text-ink">Pharmacies & Medicines</h2>
                <p class="mt-1 text-sm text-slate-600">All pharmacies with their medicines from `medicines` table.</p>

                <div class="mt-5 space-y-4">
                  <c:forEach var="p" items="${pharmacies}">
                    <div class="rounded-3xl border border-slate-200 bg-white/80 p-5">
                      <div class="flex flex-col gap-2 sm:flex-row sm:items-start sm:justify-between">
                        <div>
                          <p class="text-lg font-bold text-ink"><c:out value="${p.name}" /></p>
                          <p class="mt-1 text-sm text-slate-600"><c:out value="${p.address}" /></p>
                          <div class="mt-3 flex flex-wrap gap-2 text-xs text-slate-700">
                            <span class="rounded-full bg-slate-100 px-3 py-1 mono"><c:out value="${p.email}" /></span>
                            <span class="rounded-full bg-slate-100 px-3 py-1">Phone: <c:out value="${p.phone}" /></span>
                            <span class="rounded-full bg-slate-100 px-3 py-1 mono">Lat: <c:out value="${p.latitude}" /></span>
                            <span class="rounded-full bg-slate-100 px-3 py-1 mono">Lng: <c:out value="${p.longitude}" /></span>
                          </div>
                        </div>
                      </div>

                      <c:set var="pEmail" value="${p.email}" />
                      <c:set var="meds" value="${pharmacyMedicines[pEmail]}" />

                      <div class="mt-4 overflow-hidden rounded-2xl border border-slate-200">
                        <div class="overflow-x-auto">
                          <table class="min-w-full text-left text-sm bg-white">
                            <thead class="bg-slate-50 text-xs uppercase tracking-wider text-slate-600">
                              <tr>
                                <th class="px-4 py-3">Medicine</th>
                                <th class="px-4 py-3">Price</th>
                                <th class="px-4 py-3">Stock</th>
                                <th class="px-4 py-3">Rating</th>
                              </tr>
                            </thead>
                            <tbody class="divide-y divide-slate-200">
                              <c:forEach var="m" items="${meds}">
                                <tr class="hover:bg-orange-50/50">
                                  <td class="px-4 py-3 font-semibold text-ink"><c:out value="${m.name}" /></td>
                                  <td class="px-4 py-3 mono text-slate-700"><c:out value="${m.price}" /></td>
                                  <td class="px-4 py-3 mono text-slate-700"><c:out value="${m.stock}" /></td>
                                  <td class="px-4 py-3 mono text-slate-700"><c:out value="${m.rating}" /></td>
                                </tr>
                              </c:forEach>
                              <c:if test="${empty meds}">
                                <tr>
                                  <td class="px-4 py-4 text-center text-slate-500" colspan="4">No medicines found for this pharmacy.</td>
                                </tr>
                              </c:if>
                            </tbody>
                          </table>
                        </div>
                      </div>
                    </div>
                  </c:forEach>

                  <c:if test="${empty pharmacies}">
                    <div class="rounded-2xl border border-slate-200 bg-white/80 px-5 py-6 text-center text-slate-500">
                      No pharmacies found.
                    </div>
                  </c:if>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </main>

    <jsp:include page="/includes/footer.jsp" />
  </div>
</body>
</html>

