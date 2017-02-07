$(() => {

function App() {
  let self = {};

  self.suggest = ko.observableArray();
  self.suggestQuery = ko.observable();

  self.suggestQuery.subscribe((query) => {
    if (!query) {
      self.suggest.removeAll();
      return;
    }
  });

  self._suggestQuery = ko.pureComputed({
    read: () => { return self.suggestQuery() },
    write: (q) => { self.suggestQuery(q) }
  }).extend({ rateLimit: { timeout: 500, method: "notifyWhenChangesStop" } });

  self._suggestQuery.subscribe((query) => {
    if (!query) {
      return;
    }
    $.getJSON('/suggest.json', { q: query })
      .done((suggest) => {
        self.suggest(suggest);
      })
      .fail(() => {
        alert('Error occured during suggest loading');
      });
  });

  self.details = ko.observable();
  self.selectSuggest = function(s) {
    $.getJSON('/details.json', { ext_id: s.ext_id })
      .done((details) => {
        self.details(details);
      })
      .fail(() => {
        alert('Error occured during details loading');
      });
  }
  self.isCleanable = ko.pureComputed(() => {
    return self.details() || self.suggest().length;
  });
  self.clean = function() {
    self.details(null);
    self.suggestQuery('');
  }
  return self;
};

app = App();
ko.applyBindings(app);

});
