"use strict";

(function () {
  function goToSearch() {
    const input = document.getElementById("searchInput");
    const form = input ? input.form : null;

    if (form) {
      if (typeof form.requestSubmit === "function") {
        form.requestSubmit();
        return;
      }

      form.submit();
      return;
    }

    const query = input ? input.value.trim() : "";
    const searchUrl = document.body.dataset.searchUrl || "/search.jsp";
    const destination = query
      ? `${searchUrl}?query=${encodeURIComponent(query)}`
      : searchUrl;

    window.location.href = destination;
  }

  function initSearchTriggers() {
    const input = document.getElementById("searchInput");

    document.querySelectorAll("[data-search-trigger]").forEach((button) => {
      button.addEventListener("click", goToSearch);
    });

    if (input) {
      input.addEventListener("keydown", (event) => {
        if (event.key === "Enter" && !input.form) {
          event.preventDefault();
          goToSearch();
        }
      });
    }
  }

  function initOrderButtons() {
    const orderUrl = document.body.dataset.orderUrl;
    if (!orderUrl) {
      return;
    }

    document.querySelectorAll(".order-btn").forEach((button) => {
      button.addEventListener("click", () => {
        window.location.href = orderUrl;
      });
    });
  }

  function initApp() {
    window.goToSearch = goToSearch;
    initSearchTriggers();
    initOrderButtons();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", initApp);
  } else {
    initApp();
  }
})();
