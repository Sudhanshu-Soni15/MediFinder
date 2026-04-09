<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!doctype html>
<html lang="en">

<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>MediFinder - Find Medicines Near You</title>

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

    .serif {
      font-family: "Spectral", serif;
    }

    .glass {
      background: rgba(255, 255, 255, 0.75);
      backdrop-filter: blur(14px);
      border: 1px solid rgba(255, 255, 255, 0.7);
    }

    .floaty {
      animation: float 6s ease-in-out infinite;
    }

    @keyframes float {
      0%,
      100% {
        transform: translateY(0);
      }

      50% {
        transform: translateY(-12px);
      }
    }

    .stagger > * {
      animation: fadeUp 0.7s ease forwards;
      opacity: 0;
    }

    .stagger > *:nth-child(1) {
      animation-delay: 0.05s;
    }

    .stagger > *:nth-child(2) {
      animation-delay: 0.15s;
    }

    .stagger > *:nth-child(3) {
      animation-delay: 0.25s;
    }

    .stagger > *:nth-child(4) {
      animation-delay: 0.35s;
    }

    @keyframes fadeUp {
      from {
        opacity: 0;
        transform: translateY(16px);
      }

      to {
        opacity: 1;
        transform: translateY(0);
      }
    }

    @media (prefers-reduced-motion: reduce) {
      .floaty {
        animation: none;
      }

      .stagger > * {
        animation: none;
        opacity: 1;
      }
    }

    .section {
      animation: fadeUp 0.8s ease forwards;
    }
  </style>
</head>

<body class="text-ink" data-search-url="<c:url value='/search.jsp' />">
  <jsp:include page="/includes/navbar.jsp">
    <jsp:param name="active" value="home" />
  </jsp:include>

  <main>
    <c:choose>
      <c:when test="${empty sessionScope.userEmail}">
        <jsp:include page="/includes/hero.jsp" />

        <section class="px-4 py-6 sm:px-6 sm:py-8">
          <div class="mx-auto max-w-6xl">
            <div class="glass flex flex-col gap-5 rounded-3xl p-6 shadow-soft sm:p-8 lg:flex-row lg:items-center lg:justify-between">
              <div class="max-w-2xl">
                <p class="text-xs font-semibold uppercase tracking-[0.25em] text-teal">Pharmacy onboarding</p>
                <h2 class="mt-3 text-2xl font-bold text-ink sm:text-3xl">Are you a pharmacy?</h2>
                <p class="mt-3 text-sm text-slate-600 sm:text-base">
                  Join MediFinder to publish medicine listings, manage stock visibility, and reach nearby customers from one dashboard.
                </p>
              </div>
              <a href="pharmacy_signup.jsp" class="inline-flex items-center justify-center rounded-2xl border border-orange-200 bg-orange-50 px-6 py-3 text-sm font-semibold text-orange-600 transition hover:border-orange-300 hover:bg-orange-100">
                Register your pharmacy
              </a>
            </div>
          </div>
        </section>

        <jsp:include page="/includes/popular-medicines.jsp" />
        <jsp:include page="/includes/features.jsp" />
        <jsp:include page="/includes/cta.jsp" />
      </c:when>
      <c:otherwise>
        <section class="relative overflow-hidden px-4 py-12 sm:px-6 sm:py-16 lg:py-24" style="background: var(--bg-gradient)">
          <div class="absolute right-20 top-20 h-72 w-72 rounded-full bg-teal/30 blur-3xl"></div>
          <div class="absolute -bottom-10 -left-10 h-72 w-72 rounded-full bg-coral/20 blur-3xl"></div>

          <div class="mx-auto max-w-6xl">
            <div class="glass rounded-3xl p-8 shadow-soft sm:p-10">
              <p class="text-xs font-semibold uppercase tracking-[0.25em] text-teal">Unified MediFinder</p>
              <h1 class="mt-4 text-4xl font-bold text-ink sm:text-5xl">Welcome back, <c:out value="${sessionScope.userName}" /></h1>
              <p class="mt-4 max-w-2xl text-base text-slate-600 sm:text-lg">
                MediFinder keeps medicine discovery and pharmacy operations inside one shared platform. Choose your next action below.
              </p>

              <c:choose>
                <c:when test="${sessionScope.role eq 'ADMIN'}">
                  <div class="mt-8 max-w-xl rounded-2xl border border-slate-200 bg-white/80 px-6 py-5 text-sm text-slate-600">
                    Admin session is active. Role-aware navigation is enabled and further admin tools can be attached here.
                  </div>
                </c:when>
                <c:when test="${sessionScope.role eq 'PHARMACY'}">
                  <div class="mt-8 grid gap-4 sm:grid-cols-2">
                    <a href="pharmacy_dashboard.jsp" class="inline-flex items-center justify-center rounded-2xl bg-gradient-to-r from-orange-500 to-pink-500 px-6 py-4 text-sm font-semibold text-white shadow-lg transition hover:scale-[1.01] hover:shadow-xl">
                      Go to Dashboard
                    </a>
                    <a href="add_medicine.jsp" class="inline-flex items-center justify-center rounded-2xl border border-orange-200 bg-orange-50 px-6 py-4 text-sm font-semibold text-orange-600 transition hover:border-orange-300 hover:bg-orange-100">
                      Add Medicine
                    </a>
                  </div>
                </c:when>
                <c:otherwise>
                  <div class="mt-8 grid gap-4 sm:grid-cols-3">
                    <a href="search.jsp" class="inline-flex items-center justify-center rounded-2xl bg-gradient-to-r from-orange-500 to-pink-500 px-6 py-4 text-sm font-semibold text-white shadow-lg transition hover:scale-[1.01] hover:shadow-xl">
                      Search Medicines
                    </a>
                    <a href="cart.jsp" class="inline-flex items-center justify-center rounded-2xl border border-orange-200 bg-orange-50 px-6 py-4 text-sm font-semibold text-orange-600 transition hover:border-orange-300 hover:bg-orange-100">
                      View Cart
                    </a>
                    <a href="my_orders.jsp" class="inline-flex items-center justify-center rounded-2xl border border-orange-200 bg-orange-50 px-6 py-4 text-sm font-semibold text-orange-600 transition hover:border-orange-300 hover:bg-orange-100">
                      My Orders
                    </a>
                  </div>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
        </section>

        <jsp:include page="/includes/features.jsp" />
      </c:otherwise>
    </c:choose>
  </main>

  <jsp:include page="/includes/footer.jsp" />

  <script src="js/main.js"></script>
</body>

</html>
