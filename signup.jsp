<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="com.medifinder.dao.UserDAO"%>
<%
if (session.getAttribute("userEmail") != null) {
    response.sendRedirect("home.jsp");
    return;
}

String fullName       = request.getParameter("fullName");
String email          = request.getParameter("email");
String phoneNumber    = request.getParameter("phoneNumber");
String password       = request.getParameter("password");
String confirmPassword = request.getParameter("confirmPassword");
String error = null;
boolean isPost = "POST".equalsIgnoreCase(request.getMethod());

fullName       = fullName == null ? "" : fullName.trim();
email          = email == null ? "" : email.trim();
phoneNumber    = phoneNumber == null ? "" : phoneNumber.replaceAll("\\D", "");
password       = password == null ? "" : password;
confirmPassword = confirmPassword == null ? "" : confirmPassword;

if (isPost) {
    if (fullName.isEmpty() || email.isEmpty() || phoneNumber.isEmpty()
            || password.isEmpty() || confirmPassword.isEmpty()) {
        error = "All fields are required.";
    } else if (!phoneNumber.matches("\\d{10}")) {
        error = "Phone number must be 10 digits.";
    } else if (password.length() < 6) {
        error = "Password must be at least 6 characters.";
    } else if (!password.equals(confirmPassword)) {
        error = "Confirm password must match.";
    } else {
        UserDAO userDAO = new UserDAO();
        String registeredName = userDAO.registerUser(fullName, email, phoneNumber, password);

        if (registeredName == null) {
            error = "An account with this email already exists.";
        } else {
            session.setAttribute("userEmail", email);
            session.setAttribute("userName", registeredName);
            session.setAttribute("role", "USER");
            response.sendRedirect("home.jsp");
            return;
        }
    }
}

request.setAttribute("error", error);
request.setAttribute("signupFullName", fullName);
request.setAttribute("signupEmail", email);
request.setAttribute("signupPhoneNumber", phoneNumber);
%>
<!doctype html>
<html lang="en">

<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>MediFinder | Sign Up</title>

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
          <div class="glass w-full max-w-lg rounded-3xl p-6 shadow-soft sm:p-8">
            <div class="text-center">
              <div class="mx-auto grid h-14 w-14 place-items-center rounded-2xl bg-gradient-to-r from-orange-500 to-pink-500 text-base font-bold text-white shadow-md">
                MF
              </div>
              <h1 class="mt-5 text-3xl font-bold text-ink sm:text-4xl">Create Account</h1>
              <p class="mt-3 text-sm text-slate-600 sm:text-base">Join MediFinder</p>
            </div>

            <div class="mt-8">
              <button type="button" onclick="alert('Google login coming soon!')" class="flex w-full items-center justify-center gap-3 rounded-xl border border-slate-300 bg-white px-4 py-3 text-sm font-medium text-slate-700 transition hover:bg-slate-50">
                <svg class="h-5 w-5" viewBox="0 0 24 24" aria-hidden="true">
                  <path fill="#4285F4" d="M21.805 10.023h-9.18v3.955h5.268c-.227 1.272-.954 2.35-2.04 3.073v2.555h3.3c1.933-1.78 3.052-4.404 3.052-7.53 0-.67-.06-1.313-.17-1.953z" />
                  <path fill="#34A853" d="M12.625 22c2.767 0 5.088-.916 6.784-2.394l-3.3-2.555c-.916.614-2.087.98-3.484.98-2.678 0-4.948-1.808-5.758-4.24H3.457v2.636A10.243 10.243 0 0 0 12.625 22z" />
                  <path fill="#FBBC05" d="M6.867 13.79a6.141 6.141 0 0 1 0-3.58V7.573H3.457a10.243 10.243 0 0 0 0 8.855z" />
                  <path fill="#EA4335" d="M12.625 5.97c1.5 0 2.848.516 3.907 1.53l2.93-2.93C17.708 2.94 15.388 2 12.625 2A10.243 10.243 0 0 0 3.457 7.573l3.41 2.636c.81-2.432 3.08-4.24 5.758-4.24z" />
                </svg>
                Continue with Google
              </button>
            </div>

            <div class="my-6 flex items-center gap-4">
              <div class="h-px flex-1 bg-slate-200"></div>
              <span class="text-xs font-semibold uppercase tracking-[0.2em] text-slate-400">or</span>
              <div class="h-px flex-1 bg-slate-200"></div>
            </div>

            <form id="signupForm" method="post" action="signup.jsp" class="space-y-5">
              <c:if test="${not empty error}">
                <p class="rounded-2xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-500">
                  <c:out value="${error}" />
                </p>
              </c:if>

              <div>
                <label for="fullName" class="mb-2 block text-sm font-semibold text-ink">Full Name</label>
                <input id="fullName" name="fullName" type="text" value="<c:out value='${signupFullName}' />" placeholder="Enter your full name" class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-700 outline-none transition focus:border-orange-300 focus:bg-white focus:ring-4 focus:ring-orange-100" required />
              </div>

              <div class="grid gap-5 sm:grid-cols-2">
                <div>
                  <label for="email" class="mb-2 block text-sm font-semibold text-ink">Email</label>
                  <input id="email" name="email" type="email" value="<c:out value='${signupEmail}' />" placeholder="Enter your email" class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-700 outline-none transition focus:border-orange-300 focus:bg-white focus:ring-4 focus:ring-orange-100" required />
                </div>

                <div>
                  <label for="phoneNumber" class="mb-2 block text-sm font-semibold text-ink">Phone Number</label>
                  <input id="phoneNumber" name="phoneNumber" type="tel" value="<c:out value='${signupPhoneNumber}' />" placeholder="10-digit mobile number" pattern="[0-9]{10}" maxlength="10" inputmode="numeric" class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-700 outline-none transition focus:border-orange-300 focus:bg-white focus:ring-4 focus:ring-orange-100" required />
                </div>
              </div>

              <div class="grid gap-5 sm:grid-cols-2">
                <div>
                  <label for="password" class="mb-2 block text-sm font-semibold text-ink">Password</label>
                  <input id="password" name="password" type="password" placeholder="Minimum 6 characters" class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-700 outline-none transition focus:border-orange-300 focus:bg-white focus:ring-4 focus:ring-orange-100" required />
                </div>

                <div>
                  <label for="confirmPassword" class="mb-2 block text-sm font-semibold text-ink">Confirm Password</label>
                  <input id="confirmPassword" name="confirmPassword" type="password" placeholder="Confirm your password" class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-700 outline-none transition focus:border-orange-300 focus:bg-white focus:ring-4 focus:ring-orange-100" required />
                </div>
              </div>

              <button id="signupSubmitBtn" type="submit" class="w-full rounded-2xl bg-gradient-to-r from-orange-500 to-pink-500 px-6 py-3 text-sm font-semibold text-white shadow-lg transition hover:scale-[1.01] hover:shadow-xl disabled:cursor-not-allowed disabled:opacity-60">
                Create Account
              </button>
            </form>

            <p class="mt-6 text-center text-sm text-slate-600">
              Already have an account?
              <a href="login.jsp" class="font-semibold text-orange-600 transition hover:text-orange-700">Login</a>
            </p>
          </div>
        </div>
      </section>
    </main>

    <jsp:include page="/includes/footer.jsp" />
  </div>

  <script>
    (function () {
      const form = document.getElementById("signupForm");
      const fullNameInput = document.getElementById("fullName");
      const emailInput = document.getElementById("email");
      const phoneNumberInput = document.getElementById("phoneNumber");
      const passwordInput = document.getElementById("password");
      const confirmPasswordInput = document.getElementById("confirmPassword");
      const submitButton = document.getElementById("signupSubmitBtn");

      function sanitizePhoneNumber() {
        phoneNumberInput.value = phoneNumberInput.value.replace(/\D/g, "").slice(0, 10);
      }

      function updateSubmitState() {
        sanitizePhoneNumber();
        submitButton.disabled =
          fullNameInput.value.trim() === "" ||
          emailInput.value.trim() === "" ||
          phoneNumberInput.value.trim() === "" ||
          passwordInput.value === "" ||
          confirmPasswordInput.value === "";
      }

      fullNameInput.addEventListener("input", updateSubmitState);
      emailInput.addEventListener("input", updateSubmitState);
      phoneNumberInput.addEventListener("input", updateSubmitState);
      passwordInput.addEventListener("input", updateSubmitState);
      confirmPasswordInput.addEventListener("input", updateSubmitState);
      form.addEventListener("submit", updateSubmitState);
      updateSubmitState();
    })();
  </script>
</body>

</html>
