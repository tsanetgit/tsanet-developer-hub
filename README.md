# TSANet Connect Developer Hub

Static developer portal for TSANet Connect members: connectors, the REST API, a numbered design-document library, and cross-cutting topics.

No build step, no framework, no dependencies. Plain HTML and CSS, deployable as-is to GitHub Pages.

---

## Where this lives

Public at `tsanetgit/tsanet-developer-hub`, with the site served by GitHub Pages at <https://tsanetgit.github.io/tsanet-developer-hub/>. The repo was transferred there from `shawn-tsanet` on 2026-08-21 as a whole-repo ownership transfer, which carried history, Discussions, and settings across intact.

Community discussion lives in the **organisation-level Discussions** at <https://github.com/orgs/tsanetgit/discussions> (hosted by the `Connect_SDK` repo); this repo's own Discussions feature is disabled. On 2026-09-13 the hub's extra categories (Membership, Show and tell, Troubleshooting, Wish List) were added there alongside the existing Announcements, Q&A and Technology Committee, the hub's Ideas category was merged into Technology Committee, and the welcome announcement was transferred across. Every discussion link on the site points at the org-level area; keep it that way.

Two consequences of the transfer worth knowing:

- GitHub redirects the old web and git URLs (`github.com/shawn-tsanet/tsanet-developer-hub`) to the new ones, but **does not redirect the old Pages URL** — `shawn-tsanet.github.io/tsanet-developer-hub/` is dead. Anything outside this repo that linked there needs updating.
- **Never create a repo named `tsanet-developer-hub` under `shawn-tsanet`.** Doing so permanently deletes the redirects.

## Structure

```
index.html              Landing page — previews each section, links to its landing page
build/index.html        Build a New Integration — the deciding question, four routes in
                        order of effort, the first week, tools, worked examples
assets/
  hub.css               The design system: brand tokens, nav, cards, tables,
                        pills, SVG diagram primitives, footer
  doc.css               Design-document layer only; loads on top of hub.css
  *.png                 Brand assets, generated from the TSANet Logo Suite
                        (2026 identity; the suite itself stays untracked)
connectors/index.html   Section landing ("Existing Solutions" in the navigation): routing table + comparison matrix
connectors/*.html       One page per platform, plus the SDK and the Connect Gateway
api/index.html          Behaviour and pitfalls; deliberately NOT an endpoint reference
docs/index.html         Design-document library index + authoring conventions
docs/tsanet-2026-*.html Numbered design documents
docs/tsanet-design-doc-template.html   Copy this to start a new document
topics/index.html       Section landing
topics/*.html           Cross-connector write-ups, including agentic-usage.html
                        (skills, the hub assistant, provider comparison, Copilot Studio)
assets/assistant.js     The hub assistant launcher — inert until embedUrl is set
community/index.html    Where to take what: issue trackers, membership, discussions
tools/index.html        Tools for building an integration: environments, reference,
                        SDK and demo, test suites, agent skills — with public /
                        at-onboarding / not-yet-public markers
scripts/check.sh        Static checks — run before every commit
```

Every section has a landing page, and navigation points at those rather than at anchors on the home page.

## Conventions

### Styling

**All colours live in `assets/hub.css`.** No page defines its own brand hex — `./scripts/check.sh tokens` enforces this. Pages may add page-local layout rules in a `<style>` block, but not colours. The palette is verified against *TSANet Logo Guide 2026v3* (in the untracked `TSANet Logo Suite/` folder): six brand hues exactly as specified, derived neutrals, and green/red as functional status colours outside the brand palette. The wordmark is DIN 2014 and exists only as logo artwork — never set "tsanet" in a substitute font.

Diagrams are inline SVG using the shared primitives — `.bx` `.bx-ext` `.bx-acc` `.bx-grn` for boxes, `.ln` `.lnA` for edges, `.tt` `.ts` `.tl` for text. Using literal colours in an SVG breaks the single-source-of-truth and will be caught by the token check.

> `doc.css` scopes its link colour to `main a`. A global `a` rule there loads after `hub.css` and repaints the nav petrol-on-petrol — invisible. This has happened once already.

**Stylesheet links carry a `?v=` date query.** GitHub Pages caches assets for 10 minutes, so an unversioned stylesheet change pairs stale CSS with new HTML — the rebrand shipped with nav logos squashed by the cached old rule until caches expired. Bump the query on every stylesheet edit; the links check strips queries before resolving.

### Editorial standard

The hub's value is that it is accurate about things that are easy to get wrong. That imposes a few rules:

- **Verify against the source; say what you verified against.** Design documents have a *Verified against* cell for this. "Read the OpenAPI spec" and "probed live on Beta" are useful; memory is not.
- **Where two sources disagree, say so on the page** rather than quietly picking one. The webhook retry policy is the live example: `openapi.yaml` and `webhook-asyncapi.yaml` state different policies, and the API page reports the contradiction instead of resolving it.
- **Tag evidence level where nothing has been probed.** The ServiceNow assessment marks every claim `documented` (somebody read it) or `needs probe` (known unknown).
- **Don't publish what isn't built.** ServiceNow is an assessment, not a connector page. Placeholder content that looks real — invented document numbers, invented discussion threads — was removed from this repo once already; don't reintroduce it.
- **Check status claims against reality.** Several cards originally overstated: a "beta connector" that did not exist, a "GA" SDK that is v0.1.0.

### Redaction

Some source material is marked internal. Before publishing anything derived from it, check for: member and partner company names, internal issue references, non-public hosts, credential and auth mechanics, and unreleased security findings. `./scripts/check.sh identifiers` catches the common cases but is not a substitute for reading. The pattern list it greps for is itself internal and lives untracked in `scripts/identifiers.local` — the check fails loudly if that file is missing.

## Adding a page

**A connector or topic page** — copy the closest existing page, keep the nav and footer blocks identical, add it to its section landing page *and* the relevant index card.

**A design document** — copy `docs/tsanet-design-doc-template.html`, rename to `tsanet-2026-NNN-short-slug.html`, allocate the next number in sequence. Statuses are `DRAFT`, `APPROVED`, `SUPERSEDED`; the number never changes. Add it to `docs/index.html`. Full conventions are on that page.

**Cross-link it.** Pages written earlier will not know your page exists — the API and connectors landing pages both had to be revisited to link the topics added after them. Search for related pages and add links both ways.

## Checks

```bash
./scripts/check.sh            # all
./scripts/check.sh links      # one check by name
```

Covers local links and assets, cross-page anchors, placeholder `href="#"`, page contents matching sections, internal identifiers, and colour-token drift. Every one of these has caught a real defect.

**Diagram geometry cannot be checked from the shell** — it needs a browser to measure text. Serve the site and paste this into the console on any page with a figure:

```js
[...document.querySelectorAll('figure svg')].forEach((s,i)=>{
  const [vx,vy,vw,vh]=s.getAttribute('viewBox').split(/\s+/).map(Number);
  const boxes=[...s.querySelectorAll('rect')].filter(r=>+r.getAttribute('width')<520)
    .map(r=>({x:+r.getAttribute('x'),y:+r.getAttribute('y'),w:+r.getAttribute('width'),h:+r.getAttribute('height')}));
  const out=[];
  [...s.querySelectorAll('text')].forEach(t=>{const b=t.getBBox();
    if(b.x<vx-1||b.x+b.width>vx+vw+1||b.y+b.height>vy+vh+1) out.push('clipped: '+t.textContent);
    const h=boxes.find(o=>b.x>=o.x&&b.x<o.x+o.w&&b.y>=o.y&&b.y<=o.y+o.h);
    if(h&&b.x+b.width>h.x+h.w-2) out.push('spills its box: '+t.textContent);});
  [...s.querySelectorAll('path')].forEach(p=>{const L=p.getTotalLength&&p.getTotalLength(); if(!L)return;
    for(let d=0;d<=L;d+=2){const pt=p.getPointAtLength(d);
      boxes.forEach(o=>{if(pt.x>o.x+2&&pt.x<o.x+o.w-2&&pt.y>o.y+2&&pt.y<o.y+o.h-2)
        out.push('edge crosses a box: '+p.getAttribute('d').slice(0,30));});}});
  const rows={};
  [...s.querySelectorAll('text')].forEach(t=>{const b=t.getBBox(); const y=Math.round(b.y);
    (rows[y]=rows[y]||[]).push({x:b.x,r:b.x+b.width,t:t.textContent});});
  Object.values(rows).forEach(items=>{items.sort((a,b)=>a.x-b.x);
    for(let j=1;j<items.length;j++) if(items[j].x<items[j-1].r-0.5)
      out.push('text overlaps: '+items[j-1].t+' | '+items[j].t);});
  console.log('svg '+i+':', [...new Set(out)].length?[...new Set(out)]:'clean');
});
```

Visual inspection is not sufficient — this check found four defects on pages that looked correct, including an edge striking through a label and two colliding table columns.

## Deploying

Live: Pages deploys from `main` / root on every push — no action needed beyond pushing. The repo location is now settled, so the custom domain is the next step: point `developer.tsanet.org` at `tsanetgit.github.io` in DNS and set it as the custom domain in Pages settings. Changing Pages settings needs repo admin, which in the `tsanetgit` org means an org owner (or an explicit admin grant on this repo).

## Open items

- **Custom domain** — `developer.tsanet.org` is not yet set on Pages (see *Deploying*). Until it is, the canonical URL is `tsanetgit.github.io/tsanet-developer-hub`.
- **v1 → v2 migration** is published: the API page's *Deprecation clocks* section carries the per-connector table. Re-checked 2026-10-20: the SDK (v3.0.0) still reads on `/v2/collaboration-requests/list` and manages webhooks on deprecated `/v1/webhooks`; Dynamics (re-verified at `MS_Power_App` v2.14.0.0) registers on v2 with prefixed types and `payloadVersion V2`; Salesforce 2.14 (released 2026-10-21, re-verified 2026-10-24 at `TSANetConnect-2.14-Release`) is fully on v2. Still open: the Zendesk CloudEvents migration has not shipped (`Zendesk_App#101`).
- **Salesforce 2.14 on Production** — the package always registers its webhook with `OAUTH2_CLIENT_CREDENTIALS` `callbackAuth`, which Production's spec still lacks (re-read 2026-10-24), so Production orgs cannot register push yet and rely on the 15-minute sweep. Spec-read, not probed. The Salesforce page also publishes two source disagreements: the installation guide says the Asset flow rejects on no match (the shipped flow requests information), and the guide and the integration permission set disagree on whether a Salesforce Integration licence is enough. Re-check all three when Production picks up v3.2.5 or the guide changes.
- **Dynamics user guide** still says "LWC located on the Case Form" (unchanged at v2.14.0.0). LWC is Salesforce terminology; the solution ships an HTML web resource. The hub notes the discrepancy; the source doc is still wrong.
- **Hub assistant** — the launcher (`assets/assistant.js`, styles at the end of `hub.css`) is shipped but inert: it renders nothing until `embedUrl` holds the Copilot Studio custom-website iframe URL. The agent has to be created in TSANet's Microsoft tenant; the recipe is on `topics/agentic-usage.html#assistant`. Bump the script's `?v=` when you set the URL.
- **Copilot Studio assessment** (in `topics/agentic-usage.html`) is documented-only, against Microsoft Learn pages dated in the page's *Verified against* table. Microsoft's model tables change monthly; re-read them before citing the page. Claude Haiku is not offered in Copilot Studio — the page is written around Claude Sonnet 4.6 / Sonnet 5.
- **API reference drift** — the old attachment-forward `description` drift is fixed in GitBook (re-checked 2026-10-20). GitBook now runs *ahead* of Production instead: its webhooks-v2 page shows Beta-only fields, and it documents `POST /v1/webhooks/{id}/secret`, which answers 501 on Beta. The API page flags both.
- **Beta vs Production** — since 2026-10-20 Beta serves the v3.2.5 spec (note types, note direction and company, webhook filters, OAuth2 client-credentials `callbackAuth`, alpha Attachment V2) and Production is still on the 2026-07-30 spec. Every API claim on the hub names its environment; re-check when v3.2.5 reaches Production.
