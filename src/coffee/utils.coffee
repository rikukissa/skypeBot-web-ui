define (require) ->
  uri    = require('uri')
  moment = require('moment')

  formatBody: (b) ->
    # Escape XSS
    b = b.replace(/&/g, "&amp;")
          .replace(/</g, "&lt;")
          .replace(/>/g, "&gt;")
          .replace(/"/g, "&quot;")
          .replace(/'/g, "&#039;")

    b = uri.withinString b, (url) -> '<a href="' + url + '" target="_blank">' + url + '</a>'

    # Match tags
    tagMatches = b.match /(^|\s)#(\w*[a-zA-ZäÄöÖåÅ_]+\w*)/gi
    if tagMatches?
      b = b.replace(tag, '<a href="/tag/' + tag.trim().replace('#', '') + '" class="tag">' + tag.trim() + '</span>') for tag in tagMatches

    return b

  formatTimestamp: (t) -> moment.unix(t).format('DD.MM.YYYY HH:mm:ss')
