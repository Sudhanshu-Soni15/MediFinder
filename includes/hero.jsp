<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:url var="searchPageUrl" value="/search.jsp" />
<section class="section relative z-0 overflow-hidden px-4 py-12 sm:px-6 sm:py-16 lg:py-24" style="background: var(--bg-gradient)">
  <div class="absolute right-20 top-20 h-72 w-72 rounded-full bg-teal/30 blur-3xl"></div>

  <div class="container mx-auto max-w-7xl">
    <div class="grid items-center gap-12 lg:grid-cols-2">
      <div class="stagger">
        <p class="inline-flex items-center gap-2 rounded-full bg-white/70 px-4 py-2 text-xs font-semibold uppercase tracking-[0.2em] text-teal">
          Smart pharmacy search
        </p>
        <h2 class="mt-6 text-3xl font-bold leading-tight sm:text-4xl lg:text-6xl">
          Find the right
          <span class="serif italic text-teal">medicine</span> in minutes,
          not hours.
        </h2>
        <p class="mt-5 text-base text-slate-600 sm:mt-6 sm:text-lg">
          Check availability across trusted pharmacies, compare prices, and
          reserve instantly. MediFinder keeps your search clean, fast, and
          local.
        </p>

        <div class="mt-6 flex justify-center lg:justify-start">
          <a href="${searchPageUrl}" class="inline-flex w-full items-center justify-center rounded-full bg-gradient-to-r from-orange-500 to-pink-500 px-6 py-3 text-sm font-semibold text-white shadow-md transition hover:scale-105 sm:w-auto">
            Search Medicines
          </a>
        </div>

        <div class="mt-10 flex flex-col gap-4 sm:flex-row sm:items-center sm:gap-6">
          <div>
            <p class="text-2xl font-bold">1.6k+</p>
            <p class="text-xs uppercase tracking-widest text-slate-500">Pharmacies</p>
          </div>
          <div class="hidden h-10 w-px bg-slate-300 sm:block"></div>
          <div>
            <p class="text-2xl font-bold">92%</p>
            <p class="text-xs uppercase tracking-widest text-slate-500">Match rate</p>
          </div>
          <div class="hidden h-10 w-px bg-slate-300 sm:block"></div>
          <div>
            <p class="text-2xl font-bold">15 min</p>
            <p class="text-xs uppercase tracking-widest text-slate-500">Avg pickup</p>
          </div>
        </div>
      </div>

      <div class="relative mt-8 lg:mt-0">
        <div class="absolute -left-10 -top-10 -z-10 h-44 w-44 rounded-full bg-teal/20 blur-3xl"></div>
        <div class="absolute -bottom-10 -right-10 -z-10 h-52 w-52 rounded-full bg-coral/20 blur-3xl"></div>

        <div class="glass rounded-3xl p-6 shadow-soft sm:p-8">
          <p class="text-sm uppercase tracking-[0.2em] text-slate-500">Search medicines nearby</p>
          <h3 class="mt-3 text-2xl font-semibold text-ink">Find stock in one quick search</h3>
          <p class="mt-3 text-sm text-slate-600">
            Enter the medicine name and your city or pincode to jump straight into live search results.
          </p>

          <form action="search.jsp" method="get" class="mt-6 space-y-4">
            <div>
              <label for="heroQuery" class="mb-2 block text-sm font-semibold text-ink">Medicine name</label>
              <input id="heroQuery" name="query" type="text" placeholder="Search medicine e.g. Crocin" class="w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-700 outline-none transition focus:border-orange-300 focus:ring-4 focus:ring-orange-100" />
            </div>

            <div>
              <label for="heroLocation" class="mb-2 block text-sm font-semibold text-ink">Location</label>
              <input id="heroLocation" name="location" type="text" placeholder="Enter city or pincode" class="w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-700 outline-none transition focus:border-orange-300 focus:ring-4 focus:ring-orange-100" />
            </div>

            <button type="submit" class="w-full rounded-2xl bg-gradient-to-r from-orange-500 to-pink-500 px-6 py-3 text-sm font-semibold text-white shadow-lg transition hover:scale-[1.01] hover:shadow-xl">
              Search now
            </button>
          </form>

          <div class="mt-6 flex flex-wrap gap-2 text-xs text-slate-500">
            <span class="rounded-full bg-white/80 px-3 py-1">Working search form</span>
            <span class="rounded-full bg-white/80 px-3 py-1">Search by medicine name</span>
            <span class="rounded-full bg-white/80 px-3 py-1">Location ready</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</section>
