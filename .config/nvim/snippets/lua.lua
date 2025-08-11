---@diagnostic disable: undefined-global

return {
  s("foo", {
    t("local "), i(1, "foo"), t(" = "), i(2, "bar"),
    t({ "", "return " }), i(3, "baz")
  }),
}
