<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="com.medifinder.dao.PharmacyDAO"%>
<%
if (session.getAttribute("userEmail") != null) {
    response.sendRedirect("home.jsp");
    return;
}

String pName     = request.getParameter("name");
String pAddress  = request.getParameter("address");
String pPhone    = request.getParameter("phone");
String pEmail    = request.getParameter("email");
String pPassword = request.getParameter("password");
String pConfirm  = request.getParameter("confirmPassword");
String latStr    = request.getParameter("latitude");
String lonStr    = request.getParameter("longitude");
String error     = null;
boolean isPost   = "POST".equalsIgnoreCase(request.getMethod());
Double latitude  = null;
Double longitude = null;

pName     = pName == null ? "" : pName.trim();
pAddress  = pAddress == null ? "" : pAddress.trim();
pPhone    = pPhone == null ? "" : pPhone.replaceAll("\\D", "");
pEmail    = pEmail == null ? "" : pEmail.trim();
pPassword = pPassword == null ? "" : pPassword;
pConfirm  = pConfirm == null ? "" : pConfirm;
latStr    = latStr == null ? "" : latStr.trim();
lonStr    = lonStr == null ? "" : lonStr.trim();

if (!latStr.isEmpty() && !lonStr.isEmpty()) {
    try {
        latitude = Double.valueOf(latStr);
        longitude = Double.valueOf(lonStr);
    } catch (Exception ignore) {
        latitude = null;
        longitude = null;
    }
}

if (isPost) {
    if (pName.isEmpty() || pAddress.isEmpty() || pPhone.isEmpty()
            || pEmail.isEmpty() || pPassword.isEmpty() || pConfirm.isEmpty()) {
        error = "All fields are required.";
    } else if (!pPhone.matches("\\d{10}")) {
        error = "Phone number must be 10 digits.";
    } else if (pPassword.length() < 6) {
        error = "Password must be at least 6 characters.";
    } else if (!pPassword.equals(pConfirm)) {
        error = "Passwords do not match.";
    } else if (latitude == null || longitude == null) {
        error = "Please select address from suggestions";
    } else {
        PharmacyDAO pharmacyDAO = new PharmacyDAO();
        String registeredName = pharmacyDAO.registerPharmacy(
                pName, pAddress, pPhone, pEmail, pPassword, latitude.doubleValue(), longitude.doubleValue());

        if (registeredName == null) {
            error = "A pharmacy with this email is already registered.";
        } else {
            session.setAttribute("userEmail", pEmail);
            session.setAttribute("userName", registeredName);
            session.setAttribute("role", "PHARMACY");
            response.sendRedirect("pharmacy_dashboard.jsp");
            return;
        }
    }
}

request.setAttribute("error", error);
request.setAttribute("pName", pName);
request.setAttribute("pAddress", pAddress);
request.setAttribute("pPhone", pPhone);
request.setAttribute("pEmail", pEmail);
request.setAttribute("pLatitude", latStr);
request.setAttribute("pLongitude", lonStr);
%>
<!doctype html>
<html lang="en">

<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>MediFinder | Register Pharmacy</title>

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

        <div class="mx-auto flex min-h-[70vh] max-w-6xl items-center justify-center py-8">
          <div class="glass w-full max-w-xl rounded-3xl p-6 shadow-soft sm:p-8">

            <div class="text-center">
              <div class="mx-auto grid h-14 w-14 place-items-center rounded-2xl bg-gradient-to-r from-orange-500 to-pink-500 text-base font-bold text-white shadow-md">
                MF
              </div>
              <h1 class="mt-5 text-3xl font-bold text-ink sm:text-4xl">Register Pharmacy</h1>
              <p class="mt-3 text-sm text-slate-600 sm:text-base">Join MediFinder as a pharmacy partner</p>
            </div>

            <form id="pharmacySignupForm" method="post" action="pharmacy_signup.jsp" class="mt-8 space-y-5">

              <c:if test="${not empty error}">
                <p class="rounded-2xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-500">
                  <c:out value="${error}" />
                </p>
              </c:if>

              <!-- Pharmacy Name -->
              <div>
                <label for="name" class="mb-2 block text-sm font-semibold text-ink">Pharmacy Name</label>
                <input id="name" name="name" type="text"
                  value="<c:out value='${pName}' />"
                  placeholder="Enter pharmacy name"
                  class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-700 outline-none transition focus:border-orange-300 focus:bg-white focus:ring-4 focus:ring-orange-100"
                  required />
              </div>

              <!-- Address -->
              <div>
                <label for="address" class="mb-2 block text-sm font-semibold text-ink">Address</label>
                <div class="relative">
                  <input id="address" name="address" type="text"
                    value="<c:out value='${pAddress}' />"
                    placeholder="Full pharmacy address"
                    autocomplete="off"
                    class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-700 outline-none transition focus:border-orange-300 focus:bg-white focus:ring-4 focus:ring-orange-100"
                    required />
                  <input id="latitude" name="latitude" type="hidden" value="<c:out value='${pLatitude}' />" />
                  <input id="longitude" name="longitude" type="hidden" value="<c:out value='${pLongitude}' />" />
                  <div id="addressSuggestions" class="absolute left-0 right-0 z-20 mt-2 hidden overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-soft"></div>
                </div>
              </div>

              <!-- Email and Phone -->
              <div class="grid gap-5 sm:grid-cols-2">
                <div>
                  <label for="email" class="mb-2 block text-sm font-semibold text-ink">Email</label>
                  <input id="email" name="email" type="email"
                    value="<c:out value='${pEmail}' />"
                    placeholder="Pharmacy email"
                    class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-700 outline-none transition focus:border-orange-300 focus:bg-white focus:ring-4 focus:ring-orange-100"
                    required />
                </div>

                <div>
                  <label for="phone" class="mb-2 block text-sm font-semibold text-ink">Phone Number</label>
                  <input id="phone" name="phone" type="tel"
                    value="<c:out value='${pPhone}' />"
                    placeholder="10-digit number"
                    pattern="[0-9]{10}" maxlength="10" inputmode="numeric"
                    class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-700 outline-none transition focus:border-orange-300 focus:bg-white focus:ring-4 focus:ring-orange-100"
                    required />
                </div>
              </div>

              <!-- Password and Confirm -->
              <div class="grid gap-5 sm:grid-cols-2">
                <div>
                  <label for="password" class="mb-2 block text-sm font-semibold text-ink">Password</label>
                  <input id="password" name="password" type="password"
                    placeholder="Minimum 6 characters"
                    class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-700 outline-none transition focus:border-orange-300 focus:bg-white focus:ring-4 focus:ring-orange-100"
                    required />
                </div>

                <div>
                  <label for="confirmPassword" class="mb-2 block text-sm font-semibold text-ink">Confirm Password</label>
                  <input id="confirmPassword" name="confirmPassword" type="password"
                    placeholder="Confirm your password"
                    class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-700 outline-none transition focus:border-orange-300 focus:bg-white focus:ring-4 focus:ring-orange-100"
                    required />
                </div>
              </div>

              <button id="submitBtn" type="submit"
                class="w-full rounded-2xl bg-gradient-to-r from-orange-500 to-pink-500 px-6 py-3 text-sm font-semibold text-white shadow-lg transition hover:scale-[1.01] hover:shadow-xl disabled:cursor-not-allowed disabled:opacity-60">
                Register Pharmacy
              </button>
            </form>

            <p class="mt-6 text-center text-sm text-slate-600">
              Already registered?
              <a href="login.jsp" class="font-semibold text-orange-600 transition hover:text-orange-700">Login here</a>
            </p>

          </div>
        </div>
      </section>
    </main>

    <jsp:include page="/includes/footer.jsp" />
  </div>

  <script>
    (function () {
      const nameInput    = document.getElementById("name");
      const addressInput = document.getElementById("address");
      const emailInput   = document.getElementById("email");
      const phoneInput   = document.getElementById("phone");
      const passInput    = document.getElementById("password");
      const confirmInput = document.getElementById("confirmPassword");
      const latitudeInput = document.getElementById("latitude");
      const longitudeInput = document.getElementById("longitude");
      const suggestionsBox = document.getElementById("addressSuggestions");
      const submitBtn    = document.getElementById("submitBtn");
      let activeRequest = 0;
      let debounceTimer = null;

      function clearSuggestions() {
        suggestionsBox.innerHTML = "";
        suggestionsBox.classList.add("hidden");
      }

      function clearCoordinates() {
        latitudeInput.value = "";
        longitudeInput.value = "";
      }

      function renderSuggestions(results) {
        suggestionsBox.innerHTML = "";

        if (!Array.isArray(results) || results.length === 0) {
          suggestionsBox.innerHTML = '<div class="p-3 text-sm text-gray-500">No results found</div>';
          suggestionsBox.classList.remove("hidden");
          return;
        }

        results.sort(function (a, b) {
          return (Number(b.importance) || 0) - (Number(a.importance) || 0);
        });

        results.forEach(function (result) {
          const full = result.display_name || "";
          const main = full.split(",")[0] || full;
          const button = document.createElement("button");
          button.type = "button";
          button.className = "block w-full border-b border-slate-100 px-4 py-3 text-left transition hover:bg-orange-50 last:border-b-0";
          button.innerHTML =
            '<div>' +
              '<div class="font-medium text-slate-800">' + main.replace(/</g, "&lt;").replace(/>/g, "&gt;") + '</div>' +
              '<div class="text-xs text-slate-500">' + full.replace(/</g, "&lt;").replace(/>/g, "&gt;") + '</div>' +
            '</div>';
          button.addEventListener("click", function () {
            addressInput.value = result.display_name || "";
            latitudeInput.value = result.lat || "";
            longitudeInput.value = result.lon || "";
            clearSuggestions();
            updateSubmitState();
          });
          suggestionsBox.appendChild(button);
        });

        suggestionsBox.classList.remove("hidden");
      }

      function fetchSuggestions(query) {
        activeRequest += 1;
        const requestId = activeRequest;
        suggestionsBox.innerHTML = '<div class="p-3 text-sm text-slate-500">Loading...</div>';
        suggestionsBox.classList.remove("hidden");

        fetch("https://nominatim.openstreetmap.org/search?q=" + encodeURIComponent(query) + "&format=json&limit=10&countrycodes=in&addressdetails=1&viewbox=68,6,97,37&bounded=1", {
          headers: {
            "Accept": "application/json"
          }
        })
          .then(function (response) {
            if (!response.ok) {
              throw new Error("Failed to fetch address suggestions.");
            }
            return response.json();
          })
          .then(function (results) {
            if (requestId !== activeRequest) {
              return;
            }
            renderSuggestions(results);
          })
          .catch(function () {
            if (requestId !== activeRequest) {
              return;
            }
            clearSuggestions();
          });
      }

      function sanitizePhone() {
        phoneInput.value = phoneInput.value.replace(/\D/g, "").slice(0, 10);
      }

      function updateSubmitState() {
        sanitizePhone();
        submitBtn.disabled =
          nameInput.value.trim() === "" ||
          addressInput.value.trim() === "" ||
          emailInput.value.trim() === "" ||
          phoneInput.value.trim() === "" ||
          passInput.value === "" ||
          confirmInput.value === "" ||
          latitudeInput.value.trim() === "" ||
          longitudeInput.value.trim() === "";
      }

      function handleAddressInput() {
        clearCoordinates();
        updateSubmitState();
        clearSuggestions();

        const query = addressInput.value.trim();
        if (query.length < 3) {
          return;
        }

        clearTimeout(debounceTimer);
        debounceTimer = setTimeout(function () {
          fetchSuggestions(query);
        }, 350);
      }

      [nameInput, emailInput, phoneInput, passInput, confirmInput]
        .forEach(el => el.addEventListener("input", updateSubmitState));

      addressInput.addEventListener("input", handleAddressInput);
      document.addEventListener("click", function (event) {
        if (!suggestionsBox.contains(event.target) && event.target !== addressInput) {
          clearSuggestions();
        }
      });

      updateSubmitState();
    })();
  </script>
</body>

</html>