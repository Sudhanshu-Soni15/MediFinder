<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!doctype html>
<html lang="en">

<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>MediFinder | Medicine Details</title>

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

<body class="text-ink">
  <jsp:include page="/includes/navbar.jsp">
    <jsp:param name="active" value="search" />
  </jsp:include>

  <main class="px-4 py-8 sm:px-6 sm:py-10">
    <div class="container mx-auto max-w-7xl">
      <nav class="flex flex-wrap items-center gap-y-2 text-sm text-slate-500">
        <a href="home.jsp" class="hover:text-ink">Home</a>
        <span class="px-2">/</span>
        <a href="search.jsp" class="hover:text-ink">Search Medicines</a>
        <span class="px-2">/</span>
        <span id="breadcrumbName" class="font-medium text-ink">
          <c:choose>
            <c:when test="${not empty medicine}">${medicine.name}</c:when>
            <c:otherwise>Medicine not found</c:otherwise>
          </c:choose>
        </span>
      </nav>

      <c:if test="${not empty param.cartMessage}">
        <div class="mt-6 rounded-2xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm font-medium text-emerald-700 shadow-soft">
          <c:out value="${param.cartMessage}" />
        </div>
      </c:if>

      <c:if test="${not empty param.cartError}">
        <div class="mt-6 rounded-2xl border border-red-200 bg-red-50 px-4 py-3 text-sm font-medium text-red-700 shadow-soft">
          <c:out value="${param.cartError}" />
        </div>
      </c:if>

      <c:choose>
        <c:when test="${empty medicine}">
          <div class="mt-6 rounded-2xl border border-dashed border-slate-300 bg-white/70 p-6 text-sm text-slate-500">
            Medicine not found
          </div>
        </c:when>
        <c:otherwise>
          <div class="mt-6 grid gap-8 lg:grid-cols-2">
            <section class="rounded-3xl bg-white p-6 shadow-soft sm:p-8">
              <div class="grid items-start gap-6 sm:grid-cols-[140px_1fr]">
                <div class="flex items-center justify-center rounded-2xl border border-slate-100 bg-slate-50 p-4">
                  <svg class="h-24 w-24 text-teal" viewBox="0 0 120 120" fill="none" stroke="currentColor" stroke-width="4">
                    <rect x="18" y="30" width="84" height="60" rx="16" fill="rgba(245,158,11,0.15)" stroke="currentColor" />
                    <line x1="40" y1="60" x2="80" y2="60" />
                    <line x1="60" y1="40" x2="60" y2="80" />
                  </svg>
                </div>
                <div>
                  <p class="text-xs uppercase tracking-[0.25em] text-slate-500">Medicine Details</p>
                  <h2 id="medicineName" class="mt-3 text-2xl font-bold text-ink sm:text-3xl">${medicine.name}</h2>
                  <p id="medicineDescription" class="mt-3 text-sm text-slate-600">${medicine.description}</p>
                </div>
              </div>

              <div class="mt-6 grid gap-4 sm:grid-cols-2">
                <div class="rounded-2xl border border-slate-100 bg-slate-50 p-4">
                  <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Manufacturer</p>
                  <p id="medicineManufacturer" class="mt-2 font-semibold text-ink">${medicine.manufacturer}</p>
                </div>
                <div class="rounded-2xl border border-slate-100 bg-slate-50 p-4">
                  <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Category</p>
                  <p id="medicineCategory" class="mt-2 font-semibold text-ink">${medicine.category}</p>
                </div>
                <div class="rounded-2xl border border-slate-100 bg-slate-50 p-4">
                  <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Dosage</p>
                  <p id="medicineDosage" class="mt-2 font-semibold text-ink">${medicine.dosage}</p>
                </div>
                <div class="rounded-2xl border border-slate-100 bg-slate-50 p-4">
                  <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Prescription Required</p>
                  <p id="medicinePrescription" class="mt-2 font-semibold text-ink">${medicine.prescription}</p>
                </div>
                <div class="rounded-2xl border border-slate-100 bg-slate-50 p-4 sm:col-span-2">
                  <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Side Effects</p>
                  <p id="medicineSideEffects" class="mt-2 font-semibold text-ink">${medicine.sideEffects}</p>
                </div>
              </div>

              <div class="mt-6 rounded-2xl border border-slate-100 bg-white p-4">
                <p class="text-sm font-semibold text-ink">Usage Notes</p>
                <p id="medicineUsage" class="mt-2 text-sm text-slate-600">${medicine.usage}</p>
              </div>
            </section>

            <section class="space-y-6">
              <div class="rounded-3xl bg-white p-6 shadow-soft">
                <div class="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
                  <div>
                    <p class="text-sm text-slate-500">Available at</p>
                    <p class="text-2xl font-semibold text-ink">${medicine.availableCount}</p>
                  </div>
                  <span class="rounded-full bg-teal/20 px-3 py-1 text-xs font-semibold text-teal">
                    Live prices &middot; Updated today
                  </span>
                </div>
                <div class="mt-6 grid gap-4 sm:grid-cols-3">
                  <div class="rounded-2xl bg-slate-50 p-4">
                    <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Lowest Price</p>
                    <p class="mt-2 text-lg font-semibold text-ink">&#8377;${medicine.lowestPrice}</p>
                  </div>
                  <div class="rounded-2xl bg-slate-50 p-4">
                    <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Highest Price</p>
                    <p class="mt-2 text-lg font-semibold text-ink">&#8377;${medicine.highestPrice}</p>
                  </div>
                  <div class="rounded-2xl bg-slate-50 p-4">
                    <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Avg Distance</p>
                    <p class="mt-2 text-lg font-semibold text-ink">
                      <c:choose>
                        <c:when test="${empty medicine.avgDistance or medicine.avgDistance eq 'N/A'}">N/A</c:when>
                        <c:otherwise><fmt:formatNumber value="${fn:replace(medicine.avgDistance, ' km', '')}" maxFractionDigits="1" /> km</c:otherwise>
                      </c:choose>
                    </p>
                  </div>
                  <div class="rounded-2xl bg-slate-50 p-4 sm:col-span-3">
                    <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Strip Details</p>
                    <p class="mt-2 text-lg font-semibold text-ink">${medicine.stripInfo}</p>
                    <p class="mt-1 text-sm text-slate-600">Price shown below is per strip.</p>
                  </div>
                </div>
              </div>

              <c:if test="${empty pharmacyResults}">
                <div class="rounded-2xl border border-dashed border-slate-300 bg-white/70 p-6 text-sm text-slate-500">
                  No pharmacy availability found.
                </div>
              </c:if>

              <div class="space-y-4">
                <c:forEach var="pharmacy" items="${pharmacyResults}" varStatus="pharmacyStatus">
                  <form method="post" action="MedicineDetailsServlet" class="flex flex-col gap-4 rounded-2xl bg-white p-5 shadow-soft transition hover:-translate-y-1 hover:shadow-xl">
                    <input type="hidden" name="addToCart" value="true" />
                    <input type="hidden" name="id" value="${medicine.id}" />
                    <input type="hidden" name="name" value="${medicine.name}" />
                    <input type="hidden" name="price" value="${pharmacy.price}" />
                    <input type="hidden" name="pharmacyName" value="${pharmacy.name}" />
                    <input type="hidden" name="pharmacyEmail" value="${pharmacy.email}" />
                    <input type="hidden" name="stripInfo" value="${medicine.stripInfo}" />
                    <input type="hidden" name="tabletsPerStrip" value="${medicine.tabletsPerStrip}" />
                    <input type="hidden" name="available" value="${pharmacy.available}" />
                    <div class="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
                      <div>
                        <h4 class="text-lg font-semibold text-ink">${pharmacy.name}</h4>
                        <p class="inline-flex items-center gap-1 text-sm text-slate-500">
                          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-slate-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a2 2 0 01-2.828 0l-4.243-4.243a8 8 0 1111.314 0z" />
                          </svg>
                          Distance:
                          <c:choose>
                            <c:when test="${empty pharmacy.distance or pharmacy.distance eq 'N/A'}">N/A</c:when>
                            <c:otherwise><fmt:formatNumber value="${fn:replace(pharmacy.distance, ' km', '')}" maxFractionDigits="1" /> km</c:otherwise>
                          </c:choose>
                        </p>
                      </div>
                      <div class="flex flex-wrap items-center gap-2">
                        <c:choose>
                          <c:when test="${pharmacy.available}">
                            <span class="rounded-full bg-mint/20 px-3 py-1 text-xs font-semibold text-mint">Available</span>
                          </c:when>
                          <c:otherwise>
                            <span class="rounded-full bg-red-100 px-3 py-1 text-xs font-semibold text-red-600">Out of stock</span>
                          </c:otherwise>
                        </c:choose>
                        <c:if test="${pharmacy.bestPrice}">
                          <span class="rounded-full bg-green-100 px-2 py-1 text-xs text-green-700">Best Price</span>
                        </c:if>
                      </div>
                    </div>
                    <div class="flex flex-col gap-2 text-sm text-slate-600 sm:flex-row sm:items-center sm:justify-between">
                      <span class="font-semibold text-ink">Price per strip: &#8377;${pharmacy.price}</span>
                      <span>Rating: &#9733; ${pharmacy.rating}</span>
                    </div>
                    <div class="grid gap-4 rounded-2xl border border-slate-100 bg-slate-50 p-4 sm:grid-cols-[1fr_1fr_auto] sm:items-end">
                      <div>
                        <label for="qty-${pharmacyStatus.index}" class="mb-2 block text-xs font-semibold uppercase tracking-[0.2em] text-slate-500">Quantity</label>
                        <input id="qty-${pharmacyStatus.index}" type="number" name="quantity" min="1" value="1" data-quantity-input data-tablets-per-strip="${medicine.tabletsPerStrip}" class="w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-700 outline-none transition focus:border-orange-300 focus:ring-4 focus:ring-orange-100" />
                      </div>
                      <div class="text-sm text-slate-600">
                        <p class="font-semibold text-ink">${medicine.stripInfo}</p>
                        <p class="mt-1">Total tablets: <span data-total-tablets>${medicine.tabletsPerStrip}</span></p>
                      </div>
                      <button type="submit" class="inline-flex w-full items-center justify-center rounded-xl bg-gradient-to-r from-orange-500 to-pink-500 px-4 py-3 text-sm font-semibold text-white shadow-md transition hover:scale-[1.02] hover:shadow-lg disabled:cursor-not-allowed disabled:opacity-60 sm:w-auto" <c:if test="${not pharmacy.available}">disabled</c:if>>
                        <c:choose>
                          <c:when test="${pharmacy.available}">Add to Cart</c:when>
                          <c:otherwise>Out of Stock</c:otherwise>
                        </c:choose>
                      </button>
                    </div>
                  </form>
                </c:forEach>
              </div>
            </section>
          </div>

          <section class="mt-12">
            <div class="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
              <h3 class="text-2xl font-semibold text-ink">Related medicines</h3>
              <a href="<c:url value='/search.jsp' />" class="text-sm font-semibold text-teal">View all</a>
            </div>

            <c:if test="${empty relatedMedicines}">
              <div class="mt-6 rounded-2xl border border-dashed border-slate-300 bg-white/70 p-6 text-sm text-slate-500">
                No related medicines available.
              </div>
            </c:if>

            <div class="mt-6 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
              <c:forEach var="related" items="${relatedMedicines}">
                <c:url var="relatedUrl" value="/MedicineDetailsServlet">
                  <c:param name="id" value="${related.id}" />
                </c:url>

                <article class="rounded-2xl bg-white p-5 shadow-soft transition hover:-translate-y-1 hover:shadow-xl">
                  <h4 class="text-lg font-semibold text-ink">${related.name}</h4>
                  <p class="mt-2 text-sm text-slate-600">${related.description}</p>
                  <a href="${relatedUrl}" class="mt-4 block w-full rounded-lg bg-orange-500 px-4 py-2 text-center text-sm font-semibold text-white transition hover:bg-orange-600">
                    View Details
                  </a>
                </article>
              </c:forEach>
            </div>
          </section>
        </c:otherwise>
      </c:choose>
    </div>
  </main>

  <jsp:include page="/includes/footer.jsp" />

  <script>
    (function () {
      document.querySelectorAll("[data-quantity-input]").forEach(function (input) {
        var wrapper = input.closest("form");
        var totalTarget = wrapper ? wrapper.querySelector("[data-total-tablets]") : null;
        var tabletsPerStrip = parseInt(input.getAttribute("data-tablets-per-strip"), 10);

        if (!totalTarget) {
          return;
        }

        if (isNaN(tabletsPerStrip) || tabletsPerStrip < 1) {
          tabletsPerStrip = 10;
        }

        function updateTotal() {
          var quantity = parseInt(input.value, 10);
          if (isNaN(quantity) || quantity < 1) {
            quantity = 1;
            input.value = "1";
          }

          totalTarget.textContent = String(quantity * tabletsPerStrip);
        }

        input.addEventListener("input", updateTotal);
        input.addEventListener("change", updateTotal);
        updateTotal();
      });
    })();
  </script>
  <script src="js/main.js"></script>
</body>

</html>
