<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<section class="bg-slate-50 px-4 py-12 sm:px-6 sm:py-16">
  <div class="container mx-auto max-w-7xl">
    <div class="mb-8 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
      <div>
        <p class="text-sm uppercase tracking-[0.2em] text-slate-500">Most searched</p>
        <h3 class="text-3xl font-bold">Popular medicines this week</h3>
      </div>
      <a href="search.jsp" class="w-full rounded-full bg-white px-4 py-2 text-center text-sm font-semibold text-ink shadow-soft transition hover:bg-slate-100 sm:w-auto">
        Browse categories
      </a>
    </div>

    <div class="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
      <a href="<c:url value='/search.jsp'><c:param name='query' value='Crocin' /></c:url>" class="block rounded-2xl bg-white p-6 shadow-soft transition hover:-translate-y-1 hover:shadow-xl">
        <p class="text-xs text-slate-500">Pain relief</p>
        <p class="mt-2 text-xl font-semibold">Crocin</p>
        <p class="mt-4 text-sm text-slate-500">From &#8377;28 &middot; 120 stores</p>
      </a>

      <a href="<c:url value='/search.jsp'><c:param name='query' value='Dolo 650' /></c:url>" class="block rounded-2xl bg-white p-6 shadow-soft transition hover:-translate-y-1 hover:shadow-xl">
        <p class="text-xs text-slate-500">Fever &amp; cold</p>
        <p class="mt-2 text-xl font-semibold">Dolo 650</p>
        <p class="mt-4 text-sm text-slate-500">From &#8377;32 &middot; 140 stores</p>
      </a>

      <a href="<c:url value='/search.jsp'><c:param name='query' value='Paracetamol' /></c:url>" class="block rounded-2xl bg-white p-6 shadow-soft transition hover:-translate-y-1 hover:shadow-xl">
        <p class="text-xs text-slate-500">General health</p>
        <p class="mt-2 text-xl font-semibold">Paracetamol</p>
        <p class="mt-4 text-sm text-slate-500">From &#8377;22 &middot; 98 stores</p>
      </a>

      <a href="<c:url value='/search.jsp'><c:param name='query' value='Azithral' /></c:url>" class="block rounded-2xl bg-white p-6 shadow-soft transition hover:-translate-y-1 hover:shadow-xl">
        <p class="text-xs text-slate-500">Antibiotic</p>
        <p class="mt-2 text-xl font-semibold">Azithral</p>
        <p class="mt-4 text-sm text-slate-500">From &#8377;86 &middot; 65 stores</p>
      </a>
    </div>
  </div>
</section>
