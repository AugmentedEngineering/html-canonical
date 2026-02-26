require 'spec_helper'
require 'dry-monads'

include Dry::Monads[:result]
include Html::Canonical

RSpec.describe ".process_params" do
  context "when no params are given" do
    it "attributes and content are nil" do
      result = process_params()
      expect(result).to eq([ nil, [] ])
    end
  end
  context "when no attributes hash is given" do
    context "when an number is given" do
      it "uses the given number as content, attributes are nil" do
        result = process_params(1)
        expect(result).to eq([ nil, [ 1 ] ])
      end
    end
    context "when a string is given" do
      it "uses the given string as content, attributes are nil" do
        result = process_params("hello")
        expect(result).to eq([ nil, [ "hello" ] ])
      end
    end
    context "when an array is given" do
      it "uses the array as the list of elements in the content, attributes are nil" do
        result = process_params([ 1 ])
        expect(result).to eq([ nil, [ 1 ] ])
      end
    end
    context "when only scalars are given" do
      it "uses the given argument as the list of elements in the content" do
        result = process_params(1, "hello")
        expect(result).to eq([ nil, [ 1, "hello" ] ])
      end
    end
  end

  context "when a hash is given as the first argument" do
    context "and only a hash is given" do
      it "uses the given hash as the attributes, content is nil" do
        result = process_params({})
        expect(result).to eq([ {}, [] ])
      end
    end
    context "and the second argument is a scalar" do
      it "use the hash as attributes and the scalar as content" do
        result = process_params({}, 1)
        expect(result).to eq([ {}, [ 1 ] ])
      end
    end
    context "and the second argument is a hash" do
      it "uses the first hash as attributes and the second as content" do
        result = process_params({}, {})
        expect(result).to eq([ {}, [ {} ] ])
      end
    end
    context "and the argument is an array" do
      it "uses the hash as attributes and the array as the list of elements for content" do
        result = process_params({}, [ 1 ])
        expect(result).to eq([ {}, [ 1 ] ])
      end
    end
    context "and several scalars are given" do
      it "uses the hash as attributes and the rest of argument as the list of elements for content" do
        result = process_params({}, 1, "hello")
        expect(result).to eq([ {}, [ 1, "hello" ] ])
      end
    end
  end
end

RSpec.describe "mk_element" do
  context "when children is an Object" do
    it "returns the element with its content as a #text children" do
      config = HtmlConfig.new(theme: 'dark', auto_id_prefix: '')
      build_result = mk_element(
        tag_name: "a",
        attrs: {},
        categories: ALL_ELEMENTS["a"][:categories],
        allowed_child_categories: ALL_ELEMENTS["a"][:children_categories],
        children: "Hello world").run(config: config, state: 0)

      expect(build_result.result).to be_a(Success)
      html_node = build_result.result.value!
      expect(html_node).to eq(HtmlNode.new(
        tag_name: 'a',
        attrs: {},
        categories: [ "flow", "phrasing", "interactive", "palpable", "a" ],
        is_text: false,
        children: [ HtmlNode.new(
          tag_name: '#text',
          attrs: {},
          categories: [ "phrasing", "text" ],
          is_text: true,
          children: [ "Hello world" ]
        ) ]
      ))
    end
  end
end

RSpec.describe "doctype" do
  it "genarates a doctype tag" do
    config = HtmlConfig.new(theme: 'dark', auto_id_prefix: '')
    build_result = doctype().run(config: config, state: 0)
    expect(build_result.result).to be_a(Success)
    expect(build_result.next_state).to be_zero
    html_node = build_result.result.value!
    expect(html_node).to eq(HtmlNode.new(
    tag_name: '!DOCTYPE html', categories: [ 'root' ],
    children: [], attrs: {}, is_text: false
  ))
  end
end

RSpec.describe "text" do
  it "generates a text element" do
    config = HtmlConfig.new(theme: 'dark', auto_id_prefix: '')
    build_result = text("hello").run(config: config, state: 0)
    expect(build_result.result).to be_a(Success)
    expect(build_result.next_state).to be_zero
    html_node = build_result.result.value!
    expect(html_node).to eq(HtmlNode.new(
      tag_name: '#text',
      categories: [ 'phrasing', 'text' ],
      children: [ "hello" ],
      attrs: {},
      is_text: true
    ))
  end
end

RSpec.describe "input" do
  it "generates an input element" do
    config = HtmlConfig.new(theme: 'dark', auto_id_prefix: 'field')
    build_result = input({ type: :hidden, value: "hello" }).run(config: config, state: 0)
    expect(build_result.result).to be_a(Success)
    expect(build_result.next_state).to eq(1)
    html_node = build_result.result.value!
    expect(html_node).to eq(HtmlNode.new(
      tag_name: 'input',
      categories: [ "flow", "phrasing", "interactive", "listed", "labelable", "submittable", "resettable", "form-associated", "palpable", "input" ],
      children: [],
      attrs: { "type" => :hidden, "value" => "hello", "id" => "field-0" },
      is_text: false
    ))
  end
  context "when attributes do not include a type" do
    it "fails to generate the input element" do
      config = HtmlConfig.new(theme: 'dark', auto_id_prefix: '')
      build_result = input({ value: "hello" }).run(config: config, state: 0)
      expect(build_result.result).to be_a(Failure)
      expect(build_result.next_state).to be_zero
      expect(build_result.result.failure).to eq([ "<input> must have type attribute." ])
    end
  end
end

RSpec.describe "a" do
  it "generates anchor element" do
    config = HtmlConfig.new(theme: 'dark', auto_id_prefix: 'field')
    build_result = a({ class: "page-scroll", href: "#about" }, "About").run(config: config, state: 0)
    expect(build_result.result).to be_a(Success)
    expect(build_result.next_state).to be_zero
    html_node = build_result.result.value!
    expect(html_node).to eq(HtmlNode.new(
      tag_name: 'a',
      attrs: { "class" => 'page-scroll', "href" => "#about" },
      categories: [ "flow", "phrasing", "interactive", "palpable", "a" ],
      is_text: false,
      children: [ HtmlNode.new(
        tag_name: '#text',
        attrs: {},
        categories: [ "phrasing", "text" ],
        is_text: true,
        children: [ "About" ]
      ) ]
    ))
  end
  context "when iside a paragraph" do
    it "can contain <i> elements based on the content model hierarchy" do
      config = HtmlConfig.new(theme: 'dark', auto_id_prefix: 'field')
      build_result = p(a(i())).run(config: config, state: 0)
      expect(build_result.result).to be_a(Success)
    end
  end
  context "when inside an html" do
    it "cannot contain <i> elements based on the content model hierarchy" do
      config = HtmlConfig.new(theme: 'dark', auto_id_prefix: 'field')
      build_result = html(a(i())).run(config: config, state: 0)
      expect(build_result.result).to be_a(Failure)
    end
  end
end

RSpec.describe "label" do
  context "when the label has a nested input" do
    it "generates a label element" do
      config = HtmlConfig.new(theme: 'dark', auto_id_prefix: 'field')
      build_result = label([ input({ type: :hidden, value: "hello" }) ]).run(config: config, state: 0)
      expect(build_result.result).to be_a(Success)
      expect(build_result.next_state).to eq(1)
      html_node = build_result.result.value!
      expect(html_node).to eq(HtmlNode.new(
        tag_name: 'label',
        attrs: {},
        categories: [ 'flow', 'phrasing', 'interactive', 'palpable', 'label' ],
        is_text: false,
        children: [ HtmlNode.new(
          tag_name: 'input',
          categories: [ "flow", "phrasing", "interactive", "listed", "labelable", "submittable", "resettable", "form-associated", "palpable", "input" ],
          children: [],
          attrs: { "type" => :hidden, "value" => "hello", "id" => "field-0" },
          is_text: false
        ) ]
      ))
    end
  end

  context "when the label has a 'for' attribute" do
    it "generates a label element" do
      config = HtmlConfig.new(theme: 'dark', auto_id_prefix: '')
      build_result = label({ for: :name }, []).run(config: config, state: 0)
      expect(build_result.result).to be_a(Success)
      expect(build_result.next_state).to be_zero
      html_node = build_result.result.value!
      expect(html_node).to eq(HtmlNode.new(
        tag_name: 'label',
        attrs: { "for" => :name },
        categories: [ 'flow', 'phrasing', 'interactive', 'palpable', 'label' ],
        is_text: false,
        children: []
      ))
    end
  end

  context "when does not have a target input element" do
    it "fails to generate the label" do
      config = HtmlConfig.new(theme: 'dark', auto_id_prefix: '')
      build_result = label([]).run(config: config, state: 0)
      expect(build_result.result).to be_a(Failure)
      expect(build_result.next_state).to be_zero
      expect(build_result.result.failure).to eq([ "Label needs 'for' attr or nested input" ])
    end
  end
end

RSpec.describe "td" do
  it "genarates a td tag" do
    config = HtmlConfig.new(theme: 'dark', auto_id_prefix: '')
    build_result = td().run(config: config, state: 0)
    expect(build_result.result).to be_a(Success)
    expect(build_result.next_state).to be_zero
    html_node = build_result.result.value!
    expect(html_node).to eq(HtmlNode.new(
      tag_name: 'td',
      attrs: {},
      categories: [ "td" ],
      is_text: false,
      children: nil
    ))
  end
end

RSpec.describe "tr" do
  it "genarates a tr tag" do
    config = HtmlConfig.new(theme: 'dark', auto_id_prefix: '')
    build_result = tr().run(config: config, state: 0)
    expect(build_result.result).to be_a(Success)
    expect(build_result.next_state).to be_zero
    html_node = build_result.result.value!
    expect(html_node).to eq(HtmlNode.new(
      tag_name: 'tr',
      attrs: {},
      categories: [ "tr" ],
      is_text: false,
      children: nil
    ))
  end
end

RSpec.describe "table" do
  context "when the table as a child tr" do
    it "genarates a table tag" do
      config = HtmlConfig.new(theme: 'dark', auto_id_prefix: '')
      build_result = table([ tbody() ]).run(config: config, state: 0)
      expect(build_result.result).to be_a(Success)
      expect(build_result.next_state).to be_zero
      html_node = build_result.result.value!
      expect(html_node).to eq(HtmlNode.new(
        tag_name: 'table',
        attrs: {},
        categories: [ 'flow', 'palpable', 'table' ],
        is_text: false,
        children: [ HtmlNode.new(
          tag_name: 'tbody',
          attrs: {},
          categories: [ 'tbody' ],
          is_text: false,
          children: nil
        ) ]
      ))
    end
  end
  context "when the table is empty" do
    it "does not generate the table node and returns an error" do
      config = HtmlConfig.new(theme: 'dark', auto_id_prefix: '')
      build_result = table().run(config: config, state: 0)
      expect(build_result.result).to be_a(Failure)
      expect(build_result.next_state).to be_zero
      expect(build_result.result.failure).to eq([ "Table empty" ])
    end
  end
end

RSpec.describe "body" do
  it "genarates a body tag" do
    config = HtmlConfig.new(theme: 'dark', auto_id_prefix: '')
    build_result = body().run(config: config, state: 0)
    expect(build_result.result).to be_a(Success)
    expect(build_result.next_state).to be_zero
    html_node = build_result.result.value!
    expect(html_node).to eq(HtmlNode.new(
      tag_name: 'body',
      attrs: { "class" => "theme-dark" },
      categories: [ 'sectioning', 'body' ],
      is_text: false,
      children: nil
    ))
  end
end

RSpec.describe "document" do
  context "when it has a valid doctype" do
    it "genarates a html tag" do
      config = HtmlConfig.new(theme: 'dark', auto_id_prefix: '')
      dt = doctype()
      build_result = document(dt, html()).run(config: config, state: 0)
      expect(build_result.result).to be_a(Success)
      expect(build_result.next_state).to be_zero
      html_node = build_result.result.value!
      expect(html_node).to eq(HtmlNode.new(
        tag_name: nil,
        categories: [],
        children: [
          HtmlNode.new(
            categories: [ "root" ],
            attrs: {},
            children: [],
            is_text: false,
            tag_name: "!DOCTYPE html"),
          HtmlNode.new(
            categories: [ "html" ],
            attrs: {},
            children: [],
            is_text: false,
            tag_name: "html")
        ],
        attrs: {},
        is_text: false
      ))
    end
  end
  context "when it does not have a doctype" do
    it "fails to generate the element and returns an error" do
      config = HtmlConfig.new(theme: 'dark', auto_id_prefix: '')
      build_result = document(text("Hello"), text("hello")).run(config: config, state: 0)
      expect(build_result.result).to be_a(Failure)
      expect(build_result.next_state).to be_zero
      expect(build_result.result.failure).to eq([ "Must start with Doctype" ])
    end
  end
end

RSpec.describe "Dom generator" do
  it "renders the dom" do
    config = HtmlConfig.new(theme: 'dark', auto_id_prefix: 'field')

    expect(doctype().run(config: config, state: 1).result).to be_a(Success)
    expect(text("Hello").run(config: config, state: 1).result).to be_a(Success)
    expect(input({ type: 'text', name: 'user' }).run(config: config, state: 1).result).to be_a(Success)
    expect(label([]).run(config: config, state: 1).result).to be_a(Failure)
    expect(label([ text("Username: "), input({ type: 'text', name: 'user' }) ]).run(config: config, state: 1).result).to be_a(Success)
    expect(td([]).run(config: config, state: 1).result).to be_a(Success)
    expect(td([ text("Data") ]).run(config: config, state: 1).result).to be_a(Success)
    expect(tr([]).run(config: config, state: 1).result).to be_a(Success)
    expect(tr([ td([ text("Data") ]) ]).run(config: config, state: 1).result).to be_a(Success)
    expect(table([]).run(config: config, state: 1).result).to be_a(Failure)
    expect(table([ tr([]) ]).run(config: config, state: 1).result).to be_a(Success)
    expect(table([ tr([ td([ text("Data") ]) ]) ]).run(config: config, state: 1).result).to be_a(Success)
    expect(body([]).run(config: config, state: 1).result).to be_a(Success)
    expect(body([ text("hello") ]).run(config: config, state: 1).result).to be_a(Success)
    expect(body("hello").run(config: config, state: 1).result).to be_a(Success)
    expect(html(head(), body("hello")).run(config: config, state: 1).result).to be_a(Success)

    initial_state = 1

    doc_builder = document(
      doctype(),
      body(
        label(
          text("Username: "), input({ type: 'text', name: 'user' })
        ),

        input({ type: 'password', placeholder: 'Password' }),

        table(
          tr(td(text("Data")))
        )
      )
    )

    execution = doc_builder.run(config: config, state: initial_state)
    raise RuntimeError, "`execution` must be an instance of BuilderResult" unless execution.kind_of?(BuilderResult)

    expect(execution.result).to be_a(Success)

    expect(execution.next_state).to eq(3)
  end

  it "generate errors for table inside title" do
    config = HtmlConfig.new(theme: 'dark', auto_id_prefix: 'field')
    initial_state = 1
    bad_doc = document(
      doctype(),
      html({ lang: "de" },
        head(
          title("Augmented Engineering UG", footer())
        )
      )
    )

    bad_exec = bad_doc.run(config: config, state: initial_state)

    expect(bad_exec.result).to be_a(Failure)
    expect(bad_exec.result.failure).to match_array([ "<title> cannot contain <footer>." ])
  end

  it "generate errors" do
    config = HtmlConfig.new(theme: 'dark', auto_id_prefix: 'field')
    initial_state = 1
    bad_doc = document(
      # Error 1: Wrong element for Doctype position
      text("Not a doctype"),
      body(
        # Error 2: Label missing 'for' and input
        label(text("Lonely Label")),

        # Error 3: Input missing type
        input({ id: 'manual-override' })
      )
    )

    bad_exec = bad_doc.run(config: config, state: initial_state)

    expect(bad_exec.result).to be_a(Failure)
    expect(bad_exec.result.failure).to match_array([ "<input> must have type attribute.", "Label needs 'for' attr or nested input" ])
  end

  it "generate errors" do
    config = HtmlConfig.new(theme: 'dark', auto_id_prefix: 'field')
    initial_state = 1
    expect(label().run(config: config, state: initial_state).result.failure).to eq([ "Label needs 'for' attr or nested input" ])
  end

  it "generate doctype error" do
    config = HtmlConfig.new(theme: 'dark', auto_id_prefix: 'field')
    initial_state = 1
    bad_doc = document(text(nil), text(nil))

    bad_exec = bad_doc.run(config: config, state: initial_state)

    expect(bad_exec.result).to be_a(Failure)
    expect(bad_exec.result.failure).to eq([ "Must start with Doctype" ])
  end
end
