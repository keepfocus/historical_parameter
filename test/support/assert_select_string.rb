def assert_select_string(string, *selectors, &block)
  #doc_root = HTML::Document.new(string).root
  #assert_select(doc_root, *selectors, &block)
  assert_select(*selectors, &block)
end
