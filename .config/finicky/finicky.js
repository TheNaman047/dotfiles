// Finicky (default browser): open links for installed Brave web apps in the app
// window instead of a Brave tab. Everything else goes to Brave as before.
//
// Notion has no web manifest, so Brave's own link capturing never applies to it.
// NotionRouter (build-notion-router.sh) loads the link into the open Notion app
// window rather than opening another one.

export default {
  defaultBrowser: "Brave Browser",
  handlers: [
    {
      match: (url) => /(^|\.)notion\.(so|com)$/.test(url.host),
      browser: { name: "/Users/thenaman047/.local/share/finicky/NotionRouter.app", appType: "path" },
    },
  ],
};
