/* TSANet Developer Hub — the hub assistant launcher.
   A Copilot Studio agent, published with "No authentication" to the Custom
   website channel, is embedded as an iframe. Nothing renders until embedUrl
   is set, so the site never shows a launcher for an agent that does not exist.
   How the agent is built, and how to wire it here, is documented on
   topics/agentic-usage.html#assistant. */
(function () {
  'use strict';
  var HUB_ASSISTANT = {
    // Paste the iframe src from Copilot Studio › Channels › Custom website.
    // Shape: https://copilotstudio.microsoft.com/environments/<env>/bots/<bot>/webchat?__version__=2
    embedUrl: '',
    title: 'Hub assistant',
    // Where the "how this is built" link points, relative to the site root.
    aboutPath: 'topics/agentic-usage.html#assistant'
  };

  if (!HUB_ASSISTANT.embedUrl) return;
  if (!/^https:\/\/copilotstudio\.microsoft\.com\//.test(HUB_ASSISTANT.embedUrl)) return;

  // Resolve the site root from this script's own URL, so the about-link works
  // from any depth (index.html, connectors/x.html, docs/x.html).
  var me = document.currentScript && document.currentScript.src;
  var root = me ? me.replace(/assets\/assistant\.js.*$/, '') : '';

  var reduced = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  var launcher = document.createElement('button');
  launcher.type = 'button';
  launcher.className = 'hub-asst-launch';
  launcher.setAttribute('aria-label', 'Open the hub assistant');
  launcher.setAttribute('aria-expanded', 'false');
  launcher.innerHTML =
    '<svg viewBox="0 0 24 24" width="22" height="22" aria-hidden="true" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' +
    '<path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>' +
    '<span>Ask the hub</span>';

  var panel = document.createElement('aside');
  panel.className = 'hub-asst-panel';
  panel.setAttribute('role', 'dialog');
  panel.setAttribute('aria-label', HUB_ASSISTANT.title);
  panel.hidden = true;
  panel.innerHTML =
    '<div class="hub-asst-head">' +
      '<b>' + HUB_ASSISTANT.title + '</b>' +
      '<a class="hub-asst-about" href="' + root + HUB_ASSISTANT.aboutPath + '">how this is built</a>' +
      '<button type="button" class="hub-asst-close" aria-label="Close the hub assistant">&#215;</button>' +
    '</div>' +
    '<div class="hub-asst-body"></div>' +
    '<p class="hub-asst-foot">Answers come from the hub, the API reference and the public tsanetgit repositories. Never paste credentials.</p>';

  var body = panel.querySelector('.hub-asst-body');
  var closeBtn = panel.querySelector('.hub-asst-close');
  var frame = null;

  function open() {
    if (!frame) {
      frame = document.createElement('iframe');
      frame.src = HUB_ASSISTANT.embedUrl;
      frame.title = HUB_ASSISTANT.title;
      frame.setAttribute('allow', 'clipboard-write');
      frame.setAttribute('referrerpolicy', 'strict-origin-when-cross-origin');
      body.appendChild(frame);
    }
    panel.hidden = false;
    launcher.setAttribute('aria-expanded', 'true');
    document.body.classList.add('hub-asst-open');
    if (!reduced) panel.classList.add('in');
    closeBtn.focus();
  }
  function close() {
    panel.hidden = true;
    panel.classList.remove('in');
    launcher.setAttribute('aria-expanded', 'false');
    document.body.classList.remove('hub-asst-open');
    launcher.focus();
  }

  launcher.addEventListener('click', function () { panel.hidden ? open() : close(); });
  closeBtn.addEventListener('click', close);
  document.addEventListener('keydown', function (e) { if (e.key === 'Escape' && !panel.hidden) close(); });

  document.body.appendChild(panel);
  document.body.appendChild(launcher);
})();
