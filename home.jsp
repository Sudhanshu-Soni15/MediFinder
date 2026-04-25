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
              <div class="flex flex-col gap-3 sm:flex-row sm:items-center">
                <a href="pharmacy_signup.jsp" class="inline-flex items-center justify-center rounded-2xl border border-orange-200 bg-orange-50 px-6 py-3 text-sm font-semibold text-orange-600 transition hover:border-orange-300 hover:bg-orange-100">
                  Register your pharmacy
                </a>
                <a href="admin_login.jsp" class="inline-flex items-center justify-center rounded-2xl border border-slate-200 bg-white/80 px-6 py-3 text-sm font-semibold text-slate-700 transition hover:bg-white">
                  Admin Panel
                </a>
              </div>
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
                  <div class="mt-8 grid gap-4 sm:grid-cols-2">
                    <a href="admin_panel.jsp" class="inline-flex items-center justify-center rounded-2xl bg-gradient-to-r from-orange-500 to-pink-500 px-6 py-4 text-sm font-semibold text-white shadow-lg transition hover:scale-[1.01] hover:shadow-xl">
                      Open Admin Panel
                    </a>
                    <a href="logout.jsp" class="inline-flex items-center justify-center rounded-2xl border border-orange-200 bg-orange-50 px-6 py-4 text-sm font-semibold text-orange-600 transition hover:border-orange-300 hover:bg-orange-100">
                      Logout
                    </a>
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
<c:if test="${sessionScope.role eq 'USER'}">
  <!-- Floating location button -->
  <div id="locationWidget" style="position:fixed;bottom:24px;right:24px;z-index:9999;">
    <button onclick="document.getElementById('locationModal').style.display='flex'"
      style="background:linear-gradient(to right,#f97316,#fb7185);color:white;border:none;border-radius:9999px;padding:12px 20px;font-size:14px;font-weight:600;cursor:pointer;box-shadow:0 4px 20px rgba(0,0,0,0.2);display:flex;align-items:center;gap:8px;">
      <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M12 2v3M12 19v3M2 12h3M19 12h3"/></svg>
      <span id="locationBtnLabel">Set My Location</span>
    </button>
  </div>

  <!-- Location Modal -->
  <div id="locationModal" style="display:none;position:fixed;inset:0;z-index:10000;background:rgba(0,0,0,0.4);align-items:center;justify-content:center;">
    <div style="background:white;border-radius:24px;padding:32px;max-width:420px;width:90%;box-shadow:0 20px 60px rgba(0,0,0,0.3);">
      <h2 style="font-size:20px;font-weight:700;color:#2b1f1b;margin:0 0 8px;">Set Your Location</h2>
      <p style="font-size:14px;color:#64748b;margin:0 0 20px;">We use your location to show distance to nearby pharmacies.</p>
      <div id="locationStatus" style="font-size:13px;color:#64748b;margin-bottom:16px;">Click the button below to detect your GPS location.</div>
      <button onclick="detectLocation()"
        style="width:100%;background:linear-gradient(to right,#f97316,#fb7185);color:white;border:none;border-radius:12px;padding:12px;font-size:14px;font-weight:600;cursor:pointer;margin-bottom:12px;">
        Detect My Location
      </button>
      <button onclick="document.getElementById('locationModal').style.display='none'"
        style="width:100%;background:#f1f5f9;color:#2b1f1b;border:none;border-radius:12px;padding:12px;font-size:14px;font-weight:600;cursor:pointer;">
        Cancel
      </button>
    </div>
  </div>

  <script>
    // Show label if location already saved
    (function() {
      var saved = sessionStorage.getItem('mf_location_set');
      if (saved) {
        var el = document.getElementById('locationBtnLabel');
        if (el) el.textContent = 'Location Set ✓';
      }
    })();

    function detectLocation() {
      var statusEl = document.getElementById('locationStatus');
      if (!navigator.geolocation) {
        statusEl.style.color = '#ef4444';
        statusEl.textContent = 'Geolocation is not supported by your browser.';
        return;
      }
      statusEl.style.color = '#64748b';
      statusEl.textContent = 'Detecting your location...';
      navigator.geolocation.getCurrentPosition(
        function(pos) {
          var lat = pos.coords.latitude;
          var lng = pos.coords.longitude;
          statusEl.textContent = 'Got location (' + lat.toFixed(4) + ', ' + lng.toFixed(4) + '). Saving...';
          fetch('set-location', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'lat=' + lat + '&lng=' + lng
          }).then(function(r) {
            if (r.ok) {
              statusEl.style.color = '#16a34a';
              statusEl.textContent = 'Location saved! Distance values will now reflect your position.';
              sessionStorage.setItem('mf_location_set', '1');
              var btn = document.getElementById('locationBtnLabel');
              if (btn) btn.textContent = 'Location Set ✓';
              setTimeout(function() {
                document.getElementById('locationModal').style.display = 'none';
              }, 1500);
            } else {
              statusEl.style.color = '#ef4444';
              statusEl.textContent = 'Failed to save location. Please try again.';
            }
          }).catch(function() {
            statusEl.style.color = '#ef4444';
            statusEl.textContent = 'Network error. Please try again.';
          });
        },
        function(err) {
          statusEl.style.color = '#ef4444';
          statusEl.textContent = 'Location access denied. Please allow location in browser settings.';
        }
      );
    }
  </script>
</c:if>
</body>

</html>
