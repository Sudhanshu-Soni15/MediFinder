<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
  // If already admin, go straight in.
  if ("ADMIN".equals(session.getAttribute("role"))) {
    response.sendRedirect("admin_panel.jsp");
    return;
  }

  String adminId = request.getParameter("adminId");
  String adminPassword = request.getParameter("adminPassword");
  String error = null;
  boolean isPost = "POST".equalsIgnoreCase(request.getMethod());

  adminId = adminId == null ? "" : adminId.trim();
  adminPassword = adminPassword == null ? "" : adminPassword.trim();

  if (isPost) {
    if (adminId.isEmpty() || adminPassword.isEmpty()) {
      error = "Admin ID and password are required.";
    } else if ("admin".equals(adminId) && "admin@123".equals(adminPassword)) {
      session.setAttribute("userEmail", "admin");
      session.setAttribute("userName", "Admin");
      session.setAttribute("role", "ADMIN");
      response.sendRedirect("admin_panel.jsp");
      return;
    } else {
      error = "Invalid admin credentials.";
    }
  }

  request.setAttribute("error", error);
  request.setAttribute("adminIdValue", adminId);
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>MediFinder | Admin Login</title>

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
      --bg-gradient: radial-gradient(800px circle at 10% 10%, rgba(245, 158, 11, 0.22), transparent 40%),
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
    <jsp:include page="/includes/navbar.jsp" />

    <main class="flex-1">
      <section class="relative overflow-hidden px-4 py-12 sm:px-6 sm:py-16" style="background: var(--bg-gradient)">
        <div class="absolute right-20 top-16 h-72 w-72 rounded-full bg-teal/20 blur-3xl"></div>
        <div class="absolute -bottom-8 left-0 h-72 w-72 rounded-full bg-coral/20 blur-3xl"></div>

        <div class="mx-auto flex min-h-[70vh] max-w-6xl items-center justify-center">
          <div class="glass w-full max-w-md rounded-3xl p-6 shadow-soft sm:p-8">
            <div class="text-center">
              <div class="mx-auto grid h-14 w-14 place-items-center rounded-2xl bg-gradient-to-r from-orange-500 to-pink-500 text-base font-bold text-white shadow-md">
                AD
              </div>
              <h1 class="mt-5 text-3xl font-bold text-ink sm:text-4xl">Admin Login</h1>
              <p class="mt-3 text-sm text-slate-600 sm:text-base">Enter admin credentials to continue</p>
            </div>

            <form method="post" action="admin_login.jsp" class="mt-8 space-y-5">
              <c:if test="${not empty error}">
                <p class="rounded-2xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-500">
                  <c:out value="${error}" />
                </p>
              </c:if>

              <div>
                <label for="adminId" class="mb-2 block text-sm font-semibold text-ink">Admin ID</label>
                <input id="adminId" name="adminId" type="text" value="<c:out value='${adminIdValue}' />" placeholder="admin" class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-700 outline-none transition focus:border-orange-300 focus:bg-white focus:ring-4 focus:ring-orange-100" required />
              </div>

              <div>
                <label for="adminPassword" class="mb-2 block text-sm font-semibold text-ink">Password</label>
                <input id="adminPassword" name="adminPassword" type="password" placeholder="admin@123" class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-700 outline-none transition focus:border-orange-300 focus:bg-white focus:ring-4 focus:ring-orange-100" required />
              </div>

              <button type="submit" class="w-full rounded-2xl bg-gradient-to-r from-orange-500 to-pink-500 px-6 py-3 text-sm font-semibold text-white shadow-lg transition hover:scale-[1.01] hover:shadow-xl">
                Verify & Open Admin Panel
              </button>
            </form>

            <p class="mt-6 text-center text-sm text-slate-600">
              <a href="home.jsp" class="font-semibold text-orange-600 transition hover:text-orange-700">Back to Home</a>
            </p>
          </div>
        </div>
      </section>
    </main>

    <jsp:include page="/includes/footer.jsp" />
  </div>
</body>
</html>
