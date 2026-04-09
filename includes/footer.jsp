<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:url var="searchPageUrl" value="/search.jsp" />
<footer class="bg-gradient-to-b from-[#1f0f0c] to-black py-14 text-gray-300 sm:py-16">
  <div class="mx-auto max-w-7xl px-4 sm:px-6">
    <div class="grid gap-10 lg:grid-cols-4">
      <div>
        <div class="flex items-center gap-3">
          <div class="grid h-10 w-10 place-items-center rounded-xl bg-gradient-to-r from-orange-500 to-pink-500 text-sm font-bold text-white shadow-md">
            MF
          </div>
          <p class="text-xl font-semibold text-white">MediFinder</p>
        </div>
        <p class="mt-4 text-sm text-gray-400">
          MediFinder helps you locate medicines from nearby pharmacies,
          compare prices, and find availability instantly.
        </p>
        <ul class="mt-5 space-y-2 text-sm text-gray-400">
          <li class="flex items-center gap-2">
            <span class="inline-flex h-5 w-5 items-center justify-center rounded-full border border-white/20 text-[10px]">&#10003;</span>
            Compare medicine prices
          </li>
          <li class="flex items-center gap-2">
            <span class="inline-flex h-5 w-5 items-center justify-center rounded-full border border-white/20 text-[10px]">&#10003;</span>
            Find nearby pharmacies
          </li>
          <li class="flex items-center gap-2">
            <span class="inline-flex h-5 w-5 items-center justify-center rounded-full border border-white/20 text-[10px]">&#10003;</span>
            Save time searching medicines
          </li>
        </ul>

        <div class="mt-6 flex items-center gap-3">
          <a href="#" class="rounded-full border border-white/20 p-2 text-gray-300 transition hover:border-white/60 hover:text-white" aria-label="Twitter">
            <svg class="h-4 w-4" viewBox="0 0 24 24" fill="currentColor">
              <path d="M18.3 3H21l-6.5 7.4L22 21h-6.2l-4.8-6.1L5.6 21H3l7-8L2 3h6.3l4.4 5.6L18.3 3z" />
            </svg>
          </a>
          <a href="#" class="rounded-full border border-white/20 p-2 text-gray-300 transition hover:border-white/60 hover:text-white" aria-label="LinkedIn">
            <svg class="h-4 w-4" viewBox="0 0 24 24" fill="currentColor">
              <path d="M20.45 20.45h-3.55v-5.6c0-1.3-.03-3-1.85-3-1.86 0-2.14 1.44-2.14 2.9v5.7H9.36V9h3.4v1.55h.05c.47-.9 1.6-1.85 3.3-1.85 3.53 0 4.18 2.32 4.18 5.33v6.42zM5.34 7.44a2.06 2.06 0 1 1 0-4.12 2.06 2.06 0 0 1 0 4.12zM7.12 20.45H3.56V9h3.56v11.45z" />
            </svg>
          </a>
          <a href="#" class="rounded-full border border-white/20 p-2 text-gray-300 transition hover:border-white/60 hover:text-white" aria-label="Instagram">
            <svg class="h-4 w-4" viewBox="0 0 24 24" fill="currentColor">
              <path d="M7 3h10a4 4 0 0 1 4 4v10a4 4 0 0 1-4 4H7a4 4 0 0 1-4-4V7a4 4 0 0 1 4-4zm5 4a5 5 0 1 0 0 10 5 5 0 0 0 0-10zm6.2-.6a1.2 1.2 0 1 0 0 2.4 1.2 1.2 0 0 0 0-2.4zM12 9a3 3 0 1 1 0 6 3 3 0 0 1 0-6z" />
            </svg>
          </a>
          <a href="#" class="rounded-full border border-white/20 p-2 text-gray-300 transition hover:border-white/60 hover:text-white" aria-label="Facebook">
            <svg class="h-4 w-4" viewBox="0 0 24 24" fill="currentColor">
              <path d="M13.5 9H16V6h-2.5C11.6 6 10 7.6 10 9.5V12H8v3h2v6h3v-6h2.3l.7-3H13V9.5c0-.3.2-.5.5-.5z" />
            </svg>
          </a>
        </div>

        <div class="mt-8">
          <p class="text-sm font-semibold uppercase tracking-widest text-white/60">Stay Updated</p>
          <p class="mt-3 text-sm text-gray-400">Get pharmacy updates and price drops in your inbox.</p>
          <div class="mt-4 flex flex-col gap-3 sm:flex-row">
            <input type="email" placeholder="Enter your email" class="w-full rounded-full border border-white/20 bg-white/10 px-4 py-2 text-sm text-white placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-white/30" />
            <button class="rounded-full bg-white px-5 py-2 text-sm font-semibold text-[#1f0f0c] transition hover:opacity-90">
              Subscribe
            </button>
          </div>
        </div>
      </div>

      <div>
        <p class="text-sm font-semibold uppercase tracking-widest text-white/60">Quick Links</p>
        <div class="mt-4 flex flex-col gap-3 text-sm text-gray-400">
          <a href="home.jsp" class="hover:text-white">Home</a>
          <a href="${searchPageUrl}" class="hover:text-white">Search Medicines</a>
          <a href="#" class="hover:text-white">How It Works</a>
          <a href="#" class="hover:text-white">Pricing</a>
          <a href="login.jsp" class="hover:text-white">Login</a>
          <a href="register.jsp" class="hover:text-white">Create Account</a>
        </div>
      </div>

      <div>
        <p class="text-sm font-semibold uppercase tracking-widest text-white/60">Resources</p>
        <div class="mt-4 flex flex-col gap-3 text-sm text-gray-400">
          <a href="#" class="hover:text-white">Find Pharmacies</a>
          <a href="#" class="hover:text-white">Medicine Price Comparison</a>
          <a href="#" class="hover:text-white">Health Tips</a>
          <a href="#" class="hover:text-white">FAQs</a>
          <a href="#" class="hover:text-white">Support Center</a>
        </div>
      </div>

      <div>
        <p class="text-sm font-semibold uppercase tracking-widest text-white/60">Contact</p>
        <div class="mt-4 space-y-3 text-sm text-gray-400">
          <p>support@medifinder.com</p>
          <p>+91 98765 43210</p>
          <p>Indore, India</p>
          <p class="pt-2 text-white/60">Mon-Sat: 9:00 AM - 9:00 PM</p>
        </div>
      </div>
    </div>

    <div class="mt-12 flex flex-col gap-3 border-t border-white/10 pt-6 text-sm text-gray-400 sm:flex-row sm:items-center sm:justify-between">
      <span>&copy; 2026 MediFinder. All rights reserved.</span>
      <div class="flex flex-wrap gap-4">
        <a href="#" class="hover:text-white">Privacy Policy</a>
        <a href="#" class="hover:text-white">Terms of Service</a>
        <a href="#" class="hover:text-white">Cookies</a>
      </div>
    </div>
  </div>
</footer>
