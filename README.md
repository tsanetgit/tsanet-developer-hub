# TSANet Connect Developer Hub

Static developer portal for TSANet Connect members: connectors, the REST API, a numbered design-document library, and cross-cutting topics.

No build step, no framework, no dependencies. Plain HTML and CSS, deployable as-is to GitHub Pages.

---

## Where this lives

Public at `tsanetgit/tsanet-developer-hub`, with the site served by GitHub Pages at <https://developer.tsanet.org/> (the `tsanetgit.github.io/tsanet-developer-hub/` URL redirects there). The repo was transferred there from `shawn-tsanet` on 2026-08-21 as a whole-repo ownership transfer, which carried history, Discussions (all seven categories and the threads in them), and settings across intact. GitHub Discussions is enabled and linked throughout the site's Community section.

Two consequences of the transfer worth knowing:

- GitHub redirects the old web and git URLs (`github.com/shawn-tsanet/tsanet-developer-hub`) to the new ones, but **does not redirect the old Pages URL** — `shawn-tsanet.github.io/tsanet-developer-hub/` is dead. Anything outside this repo that linked there needs updating.
- **Never create a repo named `tsanet-developer-hub` under `shawn-tsanet`.** Doing so permanently deletes the redirects.

## Structure

```
index.html              Landing page — previews each section, links to its landing page
assets/
  hub.css               The design system: brand tokens, nav, cards, tables,
                        pills, SVG diagram primitives, footer
  doc.css               Design-document layer only; loads on top of hub.css
  *.png                 Brand assets, generated from the TSANet Logo Suite
                        (2026 identity; the suite itself stays untracked)
connectors/index.html   Section landing: routing table + comparison matrix
connectors/*.html       One page per platform, plus the SDK and the Connect Gateway
api/index.html          Behaviour and pitfalls; deliberately NOT an endpoint reference
docs/index.html         Design-document library index + authoring conventions
docs/tsanet-2026-*.html Numbered design documents
docs/tsanet-design-doc-template.html   Copy this to start a new document
topics/index.html       Section landing
topics/*.html           Cross-connector write-ups
community/index.html    Where to take what: issue trackers, membership, discussions
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

Live: Pages deploys from `main` / root on every push — no action needed beyond pushing.

**Custom domain.** `developer.tsanet.org` is set by the `CNAME` file in the repo root — Pages reads it on every branch build, so keep that file and do not add a second line to it. DNS is a Cloudflare record in the `tsanet.org` zone: `developer` → `CNAME tsanetgit.github.io`, **DNS-only (grey cloud, not proxied)** so GitHub can verify the domain and issue its certificate. That record overrides the zone's `*.tsanet.org` wildcard, which points every unclaimed subdomain at the Connect web app. *Enforce HTTPS* is a Pages setting that needs repo admin (in the `tsanetgit` org, an org owner or an explicit admin grant).

## Open items

- **Enforce HTTPS on the custom domain** — tick it in Pages settings once GitHub has issued the certificate for `developer.tsanet.org` (repo admin).
- **v1 → v2 migration** is now published: the API page's *Deprecation clocks* section carries the per-connector table, and the SDK page notes its own split posture (reads on `/v2/collaboration-requests/list`, webhook management on deprecated `/v1/webhooks` — verified against SDK source and its generated client). Dynamics has since been probed against `MS_Power_App` release v2.13.0.1: it registers on v2 with prefixed types (creation and note events only; responses and closures ride the poll), and its endpoint never matches type strings, so it cannot hit the no-op trap. Still open: the Zendesk CloudEvents migration has not shipped yet.
- **Dynamics user guide** describes the Case form integration as a "Lightning Web Component". That is Salesforce terminology; the solution ships an HTML web resource. The hub notes the discrepancy; the source doc is still wrong.
- **API reference drift** — the GitBook reference shows `description` as a query parameter on the attachment forward call; the spec has it as a required multipart form field (re-verified against `openapi.yaml`). The hub now flags it in the API page's attachments section; the GitBook reference itself is still wrong.
