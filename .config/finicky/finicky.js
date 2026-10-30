// Finicky (default browser): open links for installed Brave web apps in the app
// window instead of a Brave tab. Everything else goes to Brave as before.
//
// Notion has no web manifest, so Brave's own link capturing never applies to it.
// App ids: CrAppModeShortcutID in
//   ~/Applications/Brave Browser Apps.localized/<App>.app/Contents/Info.plist

const braveApp = (id) => (url) => ({
  name: "Brave Browser",
  args: [`--app-id=${id}`, `--app-launch-url-for-shortcuts-menu-item=${url.href}`],
});

export default {
  defaultBrowser: "Brave Browser",
  handlers: [
    {
      match: (url) => /(^|\.)notion\.(so|com)$/.test(url.host),
      browser: braveApp("ccbmjgahhfbnipmooloebpilggohhpap"),
    },
  ],
};
