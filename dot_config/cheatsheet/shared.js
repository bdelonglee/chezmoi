// Generic search/filter for cheat sheet pages.
// Expects a <input id="search"> and one or more .card blocks containing
// optional <h3> category headers followed by <table> blocks of <tr> rows.
(function () {
  var input = document.getElementById('search');
  if (!input) return;

  // Group each table's rows under the nearest preceding <h3> (or null if none).
  var groups = [];
  document.querySelectorAll('.card table').forEach(function (table) {
    var header = null;
    var el = table.previousElementSibling;
    while (el) {
      if (el.tagName === 'H3') { header = el; break; }
      if (el.tagName === 'H2') break;
      el = el.previousElementSibling;
    }
    groups.push({ header: header, rows: Array.prototype.slice.call(table.querySelectorAll('tr')) });
  });

  input.addEventListener('input', function () {
    var q = input.value.trim().toLowerCase();
    groups.forEach(function (group) {
      var anyVisible = false;
      group.rows.forEach(function (row) {
        var match = !q || row.textContent.toLowerCase().indexOf(q) !== -1;
        row.classList.toggle('hidden', !match);
        if (match) anyVisible = true;
      });
      if (group.header) group.header.classList.toggle('hidden', !anyVisible);
    });
  });
})();
