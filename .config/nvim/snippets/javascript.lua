---@diagnostic disable: undefined-global

return {
  s("con", {
    t('console.log("'), i(1), t('", '), i(2), t(");"),
    t({ "", "" }), i(0)
  }),
  s("for", {
    t("for (var "), i(1, "i"), t(" = "), i(2), t("; "), i(1), t(" < "), i(3), t("; "), i(1), t("++) {"),
    t({ "", "    " }), i(0),
    t({ "", "}" })
  }),
  s("fun", {
    t("function "), i(1), t("("), i(2), t(") {"),
    t({ "", "    " }), i(0),
    t({ "", "}" })
  }),
  s("pro", {
    t("new Promise((resolve, reject) => {"),
    t({ "", "    " }), i(0),
    t({ "", "})" })
  }),
  s("the", {
    t(".then(response => {"),
    t({ "", "    " }), i(0),
    t({ "", "})" })
  }),
  s("cat", {
    t(".catch(error => {"),
    t({ "", "    " }), i(0),
    t({ "", "})" })
  }),
  s("proa", {
    t("Promise.all(["),
    t({ "", "    " }), i(0),
    t({ "", "])" })
  }),
  s("routeEx", {
    t("const express = require('express'),"),
    t({ "", "    router = express.Router()", "" }),
    t({ "", "router." }), i(1), t("('/"), i(2), t("', "), i(0), t(")"),
    t({ "", "", "module.exports = router;" })
  }),
  s("modEx", {
    t("module.exports = {"),
    t({ "", "    " }), i(0),
    t({ "", "}" })
  }),
  s("modReq", {
    i(1), t(" = require('"), i(0), t("')")
  }),
}
