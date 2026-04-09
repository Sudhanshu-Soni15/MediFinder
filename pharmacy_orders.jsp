<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!doctype html>
<html lang="en">

<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>MediFinder | Pharmacy Orders</title>

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
      <jsp:param name="active" value="orders" />
    </jsp:include>

    <main class="flex-1">
      <section class="relative overflow-hidden px-4 py-12 sm:px-6 sm:py-16 lg:py-20" style="background: var(--bg-gradient)">
        <div class="pointer-events-none absolute right-20 top-16 h-72 w-72 rounded-full bg-teal/20 blur-3xl"></div>
        <div class="pointer-events-none absolute -bottom-8 left-0 h-72 w-72 rounded-full bg-coral/20 blur-3xl"></div>

        <div class="relative z-10 mx-auto max-w-6xl">
          <div class="max-w-3xl">
            <p class="text-xs font-semibold uppercase tracking-[0.25em] text-teal">Pharmacy portal</p>
            <h1 class="mt-4 text-4xl font-bold text-ink sm:text-5xl">Incoming Orders</h1>
            <p class="mt-4 text-base text-slate-600 sm:text-lg">Manage and process customer orders</p>
          </div>

          <section class="glass mt-10 rounded-3xl p-6 shadow-soft sm:p-8">
            <div class="grid gap-6 xl:grid-cols-2">
              <article class="rounded-3xl border border-white/80 bg-white/90 p-5 shadow-sm transition duration-200 hover:-translate-y-1 hover:shadow-xl">
                <div class="flex items-start justify-between gap-4">
                  <div>
                    <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Order ID</p>
                    <h3 class="mt-2 text-xl font-bold text-ink">ORD-1234</h3>
                    <p class="mt-2 text-sm text-slate-600">Customer: Riya Sharma</p>
                  </div>
                  <span class="rounded-full bg-amber-100 px-3 py-1 text-xs font-semibold text-amber-700">PLACED</span>
                </div>

                <div class="mt-5 grid gap-3 sm:grid-cols-2">
                  <div class="rounded-2xl bg-slate-50 p-4">
                    <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Delivery Type</p>
                    <p class="mt-2 text-sm font-semibold text-ink">Home Delivery</p>
                  </div>
                  <div class="rounded-2xl bg-slate-50 p-4">
                    <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Total</p>
                    <p class="mt-2 text-sm font-semibold text-ink">&#8377;420.00</p>
                  </div>
                </div>

                <div class="mt-4 rounded-2xl bg-slate-50 p-4">
                  <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Delivery Address</p>
                  <p class="mt-2 text-sm font-semibold text-ink">12 MG Road, Bengaluru</p>
                </div>

                <div class="mt-4 space-y-3">
                  <div class="rounded-2xl bg-slate-50 p-4">
                    <div class="flex items-center justify-between gap-4">
                      <div>
                        <p class="font-semibold text-ink">Paracetamol 500mg</p>
                        <p class="mt-1 text-sm text-slate-600">1 strip - 10 tablets</p>
                      </div>
                      <div class="text-right text-sm text-slate-600">
                        <p>Qty: 2</p>
                        <p>Tablets: 20</p>
                      </div>
                    </div>
                  </div>
                </div>

                <div class="mt-5">
                  <button type="button" class="inline-flex w-full items-center justify-center rounded-2xl bg-gradient-to-r from-orange-500 to-pink-500 px-4 py-3 text-sm font-semibold text-white shadow-md transition hover:scale-[1.01] hover:shadow-lg">
                    Accept
                  </button>
                </div>
              </article>

              <article class="rounded-3xl border border-white/80 bg-white/90 p-5 shadow-sm transition duration-200 hover:-translate-y-1 hover:shadow-xl">
                <div class="flex items-start justify-between gap-4">
                  <div>
                    <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Order ID</p>
                    <h3 class="mt-2 text-xl font-bold text-ink">ORD-1291</h3>
                    <p class="mt-2 text-sm text-slate-600">Customer: Aman Verma</p>
                  </div>
                  <span class="rounded-full bg-blue-100 px-3 py-1 text-xs font-semibold text-blue-700">PREPARING</span>
                </div>

                <div class="mt-5 grid gap-3 sm:grid-cols-2">
                  <div class="rounded-2xl bg-slate-50 p-4">
                    <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Delivery Type</p>
                    <p class="mt-2 text-sm font-semibold text-ink">Pickup</p>
                  </div>
                  <div class="rounded-2xl bg-slate-50 p-4">
                    <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Total</p>
                    <p class="mt-2 text-sm font-semibold text-ink">&#8377;275.00</p>
                  </div>
                </div>

                <div class="mt-4 rounded-2xl bg-slate-50 p-4">
                  <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Pickup Time</p>
                  <p class="mt-2 text-sm font-semibold text-ink">Today, 6:30 PM</p>
                </div>

                <div class="mt-4 space-y-3">
                  <div class="rounded-2xl bg-slate-50 p-4">
                    <div class="flex items-center justify-between gap-4">
                      <div>
                        <p class="font-semibold text-ink">Azithromycin 250mg</p>
                        <p class="mt-1 text-sm text-slate-600">1 strip - 6 tablets</p>
                      </div>
                      <div class="text-right text-sm text-slate-600">
                        <p>Qty: 3</p>
                        <p>Tablets: 18</p>
                      </div>
                    </div>
                  </div>
                </div>

                <div class="mt-5">
                  <button type="button" class="inline-flex w-full items-center justify-center rounded-2xl border border-orange-200 bg-orange-50 px-4 py-3 text-sm font-semibold text-orange-600 transition hover:border-orange-300 hover:bg-orange-100">
                    Mark Ready
                  </button>
                </div>
              </article>

              <article class="rounded-3xl border border-white/80 bg-white/90 p-5 shadow-sm transition duration-200 hover:-translate-y-1 hover:shadow-xl">
                <div class="flex items-start justify-between gap-4">
                  <div>
                    <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Order ID</p>
                    <h3 class="mt-2 text-xl font-bold text-ink">ORD-1307</h3>
                    <p class="mt-2 text-sm text-slate-600">Customer: Neha Gupta</p>
                  </div>
                  <span class="rounded-full bg-emerald-100 px-3 py-1 text-xs font-semibold text-emerald-700">READY</span>
                </div>

                <div class="mt-5 grid gap-3 sm:grid-cols-2">
                  <div class="rounded-2xl bg-slate-50 p-4">
                    <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Delivery Type</p>
                    <p class="mt-2 text-sm font-semibold text-ink">Home Delivery</p>
                  </div>
                  <div class="rounded-2xl bg-slate-50 p-4">
                    <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Total</p>
                    <p class="mt-2 text-sm font-semibold text-ink">&#8377;510.00</p>
                  </div>
                </div>

                <div class="mt-4 rounded-2xl bg-slate-50 p-4">
                  <p class="text-xs uppercase tracking-[0.2em] text-slate-500">Delivery Address</p>
                  <p class="mt-2 text-sm font-semibold text-ink">45 Park Street, Kolkata</p>
                </div>

                <div class="mt-4 space-y-3">
                  <div class="rounded-2xl bg-slate-50 p-4">
                    <div class="flex items-center justify-between gap-4">
                      <div>
                        <p class="font-semibold text-ink">Cetirizine 10mg</p>
                        <p class="mt-1 text-sm text-slate-600">1 strip - 10 tablets</p>
                      </div>
                      <div class="text-right text-sm text-slate-600">
                        <p>Qty: 1</p>
                        <p>Tablets: 10</p>
                      </div>
                    </div>
                  </div>
                </div>

                <div class="mt-5">
                  <button type="button" class="inline-flex w-full items-center justify-center rounded-2xl border border-orange-200 bg-orange-50 px-4 py-3 text-sm font-semibold text-orange-600 transition hover:border-orange-300 hover:bg-orange-100">
                    Dispatch
                  </button>
                </div>
              </article>
            </div>
          </section>
        </div>
      </section>
    </main>

    <jsp:include page="/includes/footer.jsp" />
  </div>
</body>

</html>
