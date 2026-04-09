<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList,java.util.Collections,java.util.Comparator,java.util.LinkedHashMap,java.util.List,java.util.Map"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
if (!"USER".equals(session.getAttribute("role"))) {
  response.sendRedirect("login.jsp");
  return;
}
List<Map<String, String>> medicines =
    (List<Map<String, String>>) request.getAttribute("medicines");

if (medicines == null) {
    medicines = new ArrayList<>();
}
%>
<!doctype html>
<html lang="en">

<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>MediFinder | Search Medicine</title>

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
  </style>
</head>

<body class="text-ink" data-search-url="<c:url value='/search.jsp' />">
  <div class="min-h-screen flex flex-col">
    <jsp:include page="/includes/navbar.jsp">
      <jsp:param name="active" value="search" />
    </jsp:include>

    <main class="flex-1">
      <section class="relative z-0 overflow-hidden px-4 py-12 sm:px-6 sm:py-16 lg:py-20" style="background: var(--bg-gradient)">
        <div class="absolute right-20 top-20 h-72 w-72 rounded-full bg-teal/30 blur-3xl"></div>
        <div class="absolute -bottom-10 -left-10 h-72 w-72 rounded-full bg-coral/20 blur-3xl"></div>
        <div class="mx-auto flex max-w-5xl flex-col items-center text-center">
          <span class="inline-flex items-center gap-2 rounded-full bg-white/70 px-4 py-2 text-xs font-semibold uppercase tracking-[0.2em] text-teal">
            Smart pharmacy search
          </span>
          <h1 class="mt-6 text-4xl font-bold text-ink sm:text-5xl">Find Medicines Near You</h1>
          <p class="mt-4 max-w-2xl text-base text-slate-600 sm:text-lg">
            Search medicines and compare prices from nearby pharmacies
            instantly.
          </p>
          <div class="mt-8 w-full max-w-3xl">
            <!-- <div
              class="glass flex flex-col gap-3 rounded-2xl p-3 shadow-soft sm:flex-row sm:items-center sm:rounded-full">
              <div class="relative flex-1">
                <span
                  class="pointer-events-none absolute inset-y-0 left-4 flex items-center text-slate-400">
                  <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M21 21l-4.35-4.35M10 18a8 8 0 1 1 0-16 8 8 0 0 1 0 16z" />
                  </svg>
                </span>
                <input id="searchInput" type="text" name="query"
                  value="${searchQuery}"
                  placeholder="Search medicine (e.g. Paracetamol 500mg)"
                  class="w-full rounded-full border border-slate-200 bg-white py-3 pl-12 pr-4 text-sm text-slate-700 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-teal/50" />
              </div>
              <button type="button" data-search-trigger
                class="w-full rounded-full bg-gradient-to-r from-orange-500 to-pink-500 px-6 py-3 text-sm font-semibold text-white shadow-md transition hover:scale-105 sm:w-auto">
                Search
              </button>
            </div> -->

            <form id="searchForm" action="search" method="get" class="glass flex flex-col gap-3 rounded-2xl p-3 shadow-soft sm:flex-row sm:items-center sm:rounded-full">
              <div class="relative flex-1">
                <input id="searchInput" type="text" name="query" value="${searchQuery}" placeholder="Search medicine (e.g. Paracetamol 500mg)" class="w-full rounded-full border border-slate-200 bg-white py-3 pl-12 pr-4 text-sm text-slate-700 focus:outline-none focus:ring-2 focus:ring-teal/50" />
              </div>
              <input type="hidden" name="sort" value="${selectedSort}" />
              <input type="hidden" name="distance" value="${selectedDistance}" />
              <input type="hidden" name="rating" value="${selectedRating}" />
              <c:if test="${availabilityOnly}">
                <input type="hidden" name="availability" value="on" />
              </c:if>

              <button type="submit" class="w-full rounded-full bg-gradient-to-r from-orange-500 to-pink-500 px-6 py-3 text-sm font-semibold text-white shadow-md transition hover:scale-105 sm:w-auto">
                Search
              </button>
            </form>
          </div>
        </div>
      </section>

      <section class="mx-auto w-full max-w-6xl px-4 pb-6 sm:px-6">
        <div class="rounded-2xl bg-white/80 p-4 shadow-soft sm:p-6">
          <form id="filtersForm" action="search" method="get">
            <input type="hidden" name="query" value="${searchQuery}" />
            <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
              <div data-select-card data-select-target="sortPriceSelect" tabindex="0" role="button" aria-haspopup="listbox" aria-label="Sort medicines by price" class="flex cursor-pointer items-center justify-between rounded-xl border px-4 py-3 text-sm font-medium shadow-sm transition hover:shadow-md focus:outline-none focus:ring-2 focus:ring-teal/40 ${hasPriceFilter ? 'border-orange-200 bg-orange-50 text-orange-700' : 'border-transparent bg-white text-slate-600'}">
                <span class="flex items-center gap-2">
                  <svg class="h-4 w-4 text-teal" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h10l3 4-8 8-8-8 3-4z" />
                    <circle cx="15" cy="11" r="1.5" fill="currentColor" stroke="none" />
                  </svg>
                  Sort by Price
                </span>
                <select id="sortPriceSelect" name="sort" class="rounded-lg bg-transparent px-2 py-1 text-current focus:outline-none" aria-label="Sort by price" data-auto-submit="true">
                  <option value="">Any Price</option>
                  <option value="low" <c:if test="${selectedSort eq 'low'}">selected</c:if>>Low to High</option>
                  <option value="high" <c:if test="${selectedSort eq 'high'}">selected</c:if>>High to Low</option>
                </select>
              </div>

              <div data-select-card data-select-target="distanceSelect" tabindex="0" role="button" aria-haspopup="listbox" aria-label="Sort medicines by distance" class="flex cursor-pointer items-center justify-between rounded-xl border px-4 py-3 text-sm font-medium shadow-sm transition hover:shadow-md focus:outline-none focus:ring-2 focus:ring-teal/40 ${hasDistanceFilter ? 'border-orange-200 bg-orange-50 text-orange-700' : 'border-transparent bg-white text-slate-600'}">
                <span class="flex items-center gap-2">
                  <svg class="h-4 w-4 text-teal" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 22s7-7.5 7-12a7 7 0 1 0-14 0c0 4.5 7 12 7 12z" />
                    <circle cx="12" cy="10" r="2.5" />
                  </svg>
                  Sort by Distance
                </span>
                <select id="distanceSelect" name="distance" class="rounded-lg bg-transparent px-2 py-1 text-current focus:outline-none" aria-label="Sort by distance" data-auto-submit="true">
                  <option value="">Any Distance</option>
                  <option value="near" <c:if test="${selectedDistance eq 'near'}">selected</c:if>>Nearest</option>
                  <option value="far" <c:if test="${selectedDistance eq 'far'}">selected</c:if>>Farthest</option>
                </select>
              </div>

              <label class="flex cursor-pointer items-center gap-3 rounded-xl border px-4 py-3 text-sm font-medium shadow-sm transition hover:shadow-md ${hasAvailabilityFilter ? 'border-orange-200 bg-orange-50 text-orange-700' : 'border-transparent bg-white text-slate-600'}">
                <input type="checkbox" name="availability" value="on" class="h-4 w-4 rounded border-slate-300 text-teal focus:ring-teal" data-auto-submit="true" <c:if test="${availabilityOnly}">checked</c:if> />
                <span class="flex items-center gap-2">
                  <svg class="h-4 w-4 text-teal" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18z" />
                  </svg>
                  In Stock Only
                </span>
              </label>

              <div data-select-card data-select-target="ratingSelect" tabindex="0" role="button" aria-haspopup="listbox" aria-label="Filter pharmacies by rating" class="flex cursor-pointer items-center justify-between rounded-xl border px-4 py-3 text-sm font-medium shadow-sm transition hover:shadow-md focus:outline-none focus:ring-2 focus:ring-teal/40 ${hasRatingFilter ? 'border-orange-200 bg-orange-50 text-orange-700' : 'border-transparent bg-white text-slate-600'}">
                <span class="flex items-center gap-2">
                  <svg class="h-4 w-4 text-teal" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M12 17.3l-5.2 3 1.4-5.9L3 9.8l6-.5L12 3.7l3 5.6 6 .5-4.2 4.6 1.4 5.9z" />
                  </svg>
                  Pharmacy Rating
                </span>
                <select id="ratingSelect" name="rating" class="rounded-lg bg-transparent px-2 py-1 text-current focus:outline-none" aria-label="Filter by pharmacy rating" data-auto-submit="true">
                  <option value="">Any Rating</option>
                  <option value="4.0" <c:if test="${selectedRating eq '4.0'}">selected</c:if>>4.0+</option>
                  <option value="4.5" <c:if test="${selectedRating eq '4.5'}">selected</c:if>>4.5+</option>
                </select>
              </div>
            </div>
          </form>
        </div>
      </section>

      <section class="mx-auto w-full max-w-6xl px-4 pb-16 sm:px-6">
    

        <c:if test="${empty medicines}">
          <div id="emptyState" class="flex items-center justify-center rounded-2xl border border-dashed border-slate-300 bg-white/70 py-16 text-center text-slate-500">
            <c:choose>
              <c:when test="${empty searchQuery}">
                <p class="text-lg font-medium">No medicines available yet. Ask a pharmacy partner to add listings.</p>
              </c:when>
              <c:otherwise>
                <p class="text-lg font-medium">No medicines found for "${searchQuery}"</p>
              </c:otherwise>
            </c:choose>
          </div>
        </c:if>

        <c:if test="${not empty medicines}">
          <div id="resultsGrid" class="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
            <c:forEach var="med" items="${medicines}">
              <c:url var="detailUrl" value="/MedicineDetailsServlet">
                <c:param name="id" value="${med.id}" />
                <c:param name="pharmacyEmail" value="${med.pharmacyEmail}" />
              </c:url>

              <article class="result-card flex flex-col gap-4 rounded-xl border border-slate-100 bg-white p-5 shadow-soft transition duration-200 hover:-translate-y-1 hover:shadow-xl">
                <div class="flex items-start justify-between gap-4">
                  <div>
                    <h3 class="text-lg font-semibold text-ink">${med.name}</h3>
                    <p class="text-sm text-slate-500">${med.pharmacyName}</p>
                  </div>
                  <span class="rounded-full bg-mint/20 px-3 py-1 text-xs font-semibold text-mint">Listed</span>
                </div>
                <div class="flex items-center justify-between text-sm text-slate-600">
                  <span class="font-semibold text-ink">&#8377;<c:out value="${empty med.price ? '0' : med.price}" /></span>
                  <span>Stock: <c:out value="${empty med.stock ? '0' : med.stock}" /></span>
                </div>
                <div class="text-sm text-slate-600">
                  Distance:
                  <c:choose>
                    <c:when test="${empty med.distance or med.distance eq 'N/A'}">N/A</c:when>
                    <c:otherwise><c:out value="${med.distance}" /> km</c:otherwise>
                  </c:choose>
                </div>
                <div class="mt-auto">
                  <div class="grid grid-cols-2 gap-3">
                    <a href="${detailUrl}" class="block w-full rounded-lg border border-orange-200 bg-orange-50 px-4 py-2 text-center text-sm font-semibold text-orange-600 transition hover:border-orange-300 hover:bg-orange-100">
                      View Details
                    </a>
                    <form method="post" action="MedicineDetailsServlet" class="w-full">
                      <input type="hidden" name="addToCart" value="true" />
                      <input type="hidden" name="id" value="${med.id}" />
                      <input type="hidden" name="name" value="${med.name}" />
                      <input type="hidden" name="price" value="${empty med.price ? '0' : med.price}" />
                      <input type="hidden" name="pharmacyName" value="${med.pharmacyName}" />
                      <input type="hidden" name="pharmacyEmail" value="${med.pharmacyEmail}" />
                      <input type="hidden" name="stripInfo" value="${empty med.stripInfo ? '1 strip = 10 tablets' : med.stripInfo}" />
                      <input type="hidden" name="tabletsPerStrip" value="${empty med.tabletsPerStrip ? '10' : med.tabletsPerStrip}" />
                      <input type="hidden" name="available" value="${not empty med.stock and med.stock ne '0'}" />
                      <input type="hidden" name="quantity" value="1" />
                      <button type="submit" class="block w-full rounded-lg border border-pink-200 bg-pink-50 px-4 py-2 text-center text-sm font-semibold text-pink-600 transition hover:border-pink-300 hover:bg-pink-100">
                        Add to Cart
                      </button>
                    </form>
                  </div>
                </div>
              </article>
            </c:forEach>
          </div>
        </c:if>
      </section>
    </main>

    <jsp:include page="/includes/footer.jsp" />
  </div>

  <script>
    (function () {
      function submitForm(form) {
        if (!form) {
          return;
        }

        if (typeof form.requestSubmit === "function") {
          form.requestSubmit();
          return;
        }

        form.submit();
      }

      function openSelect(select) {
        if (!select) {
          return;
        }

        select.focus();
        if (typeof select.showPicker === "function") {
          select.showPicker();
          return;
        }

        select.click();
      }

      function initSortControls() {
        document.querySelectorAll("[data-auto-submit='true']").forEach(function (field) {
          field.addEventListener("change", function () {
            submitForm(field.form);
          });
        });

        document.querySelectorAll("[data-select-card]").forEach(function (card) {
          var selectId = card.getAttribute("data-select-target");
          var select = document.getElementById(selectId);
          if (!select) {
            return;
          }

          card.addEventListener("click", function (event) {
            if (event.target === select) {
              return;
            }

            openSelect(select);
          });

          card.addEventListener("keydown", function (event) {
            if (event.key === "Enter" || event.key === " ") {
              event.preventDefault();
              openSelect(select);
            }
          });
        });
      }

      if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", initSortControls);
      } else {
        initSortControls();
      }
    })();
  </script>
  <script src="js/main.js"></script>
</body>

</html>
