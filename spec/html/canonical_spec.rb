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

    if execution.result.kind_of?(Success)
      root_node = execution.result.value!
      # pp root_node
      # pp render_html(root_node)
    end
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

  it "generates augen landing" do
    config = HtmlConfig.new(theme: 'dark', auto_id_prefix: 'field')
    initial_state = 1
    landing = document(
      doctype(),
      html({ lang: "en" },
        head(
          meta({ "http-equiv"=>"Content-Type", content: "text/html; charset=UTF-8" }),
          meta({ "http-equiv"=>"X-UA-Compatible", content: "IE=edge" }),
          meta({ name: "viewport", content: "width=device-width, initial-scale=1" }),
          meta({ name: "description", content: "The exact same AI-coded page everyone else makes." }),
          meta({ name: "author", content: "Claude, ChatGPT, Cursor, Copilot, et al." }),

          title("Every Fucking AI-Coded Website Ever"),

          link({ rel: "stylesheet", href: "css/bootstrap.min.css", type: "text/css" }),

          link({ href: "https://fonts.googleapis.com/css?family=Open+Sans:300italic,400italic,600italic,700italic,800italic,400,300,600,700,800", rel: "stylesheet", type: "text/css" }),
          link({ href: "https://fonts.googleapis.com/css?family=Merriweather:400,300,300italic,400italic,700,700italic,900,900italic", rel: "stylesheet", type: "text/css" }),

          link({ rel: "stylesheet", href: "css/animate.min.css", type: "text/css" }),

          link({ rel: "stylesheet", href: "css/creative.css", type: "text/css" })
        ),
        body({ id: "page-top" },
          nav({ id: "mainNav", class: "navbar navbar-default navbar-fixed-top" },
            div({ class: "container-fluid" },
              div({ class: "navbar-header" },
                button({ type: "button", class: "navbar-toggle collapsed", "data-toggle": "collapse", "data-target": "#bs-example-navbar-collapse-1" },
                  span({ class: "sr-only" }, "Navigation"),
                  span({ class: "icon-bar" }),
                  span({ class: "icon-bar" }),
                  span({ class: "icon-bar" })
                ),
                a({ class: "navbar-brand page-scroll", href: "#page-top" }, "The Only AI-Coded Page")
              ),

              div({ class: "collapse navbar-collapse", id: "bs-example-navbar-collapse-1" },
                ul({ class: "nav navbar-nav navbar-right" },
                  li(
                    a({ class: "page-scroll", href: "#about" }, "About")
                  ),
                  li(
                    a({ class: "page-scroll", href: "#services" }, "Four Icons")
                  ),
                  li(
                    a({ class: "page-scroll", href: "#portfolio" }, "Stock Photos")
                  ),
                  li(
                    a({ class: "page-scroll", href: "#broken-links" }, "Resources")
                  ),
                  li(
                    a({ class: "page-scroll", href: "#contact" }, "DM Me")
                  )
                )
              )
            )
          ),
          header(
            div({ class: "header-content" },
              div({ class: "header-content-inner" },
                div({ class: "startup-badge" }, "🚀 YC W25 REJECT"),
                h1(
                  text("Hey Look, It's Every "),
                  span({ class: 'gradient-text' }, "AI-Coded"),
                  text("Website Ever")
                ),
                hr(),
                p("Take a look around at the same fucking vibe-coded site you've seen ten million times before! Built entirely by copy-pasting Claude responses without reading them!"),
                div({ class: "value-props" }, "💎 $0 REVENUE • ∞ TECHNICAL DEBT • 🔥 ZERO TESTS"),
                p({ style: "font-size: 18px; font-style: italic; opacity: 0.9; margin-top: 30px;" },
                  text("Lovingly crafted by Claude while "),
                  a({ href: "https://x.com/jimmykoppel", target: "_blank", style: "color: #fff; text-decoration: underline;" },
                    text("Jimmy K "),
                    i({ class: "fa fa-twitter" })
                  ),
                  text(" stood by and took all the credit.")
                ),
                a({ href: "#about", class: "btn btn-primary btn-xl page-scroll" }, "This button was AI-generated too")
              )
            )
          ),
          section({ class: "bg-primary", id: "about" },
            div({ class: "container" },
              div({ class: "row" },
                div({ class: "col-lg-8 col-lg-offset-2 text-center" },
                  h2({ class: "section-heading" }, "About Us"),
                  hr({ class: "light" }),
                  p({ class: "text-faded" }, "At {{COMPANY_NAME}}, we're passionate about startups and absolutely love our customers. We're on a mission to disrupt the industry with our innovative solutions that leverage cutting-edge AI technology. Our team, led by visionary founder {{CEO_NAME}}, is dedicated to providing world-class service and building products that delight users. We believe in moving fast, breaking things, and changing the world one prompt at a time."),
                  p({ class: "text-faded", style: "font-size: 16px;" },
                    a({ href: "https://news.ycombinator.com/item?id=45625158", target: "_blank", style: "color: #fff; text-decoration: underline;" }, "Want to learn more?"),
                    text("Reach out to us at {{CONTACT_EMAIL}} or visit our headquarters at {{OFFICE_ADDRESS}}. Our {{TEAM_SIZE}} dedicated employees are standing by to help you {{CALL_TO_ACTION}}!")
                  )
                )
              )
            )
          ),
          section({ class: "bg-dark", id: "learn", style: "padding: 100px 0;" },
            div({ class: "container" },
              div({ class: "row" },
                div({ class: "col-lg-8 col-lg-offset-2 text-center" },
                  h2({ class: "section-heading", style: "color: #fff;" }, "Want to actually learn to code yourself?"),
                  hr({ class: "light" }),
                  p({ class: "text-faded" }, "Forget that! Who would ever want to put in all of that effort to understand what they're building? Just open up your browser and type 'make me a website' into Claude or ChatGPT, and you're on your way! There are hundreds of identical prompts to choose from, but go ahead and use the same exact one everyone else uses, paste the output without reading it, and you're done! No one will notice that every AI-coded site looks identical! Plus you get to argue on Twitter about whether 'prompt engineering' counts as real programming!"),
                  a({ href: "https://claude.ai", target: "_blank", class: "btn btn-default btn-xl" }, "Just Ask Claude Bro")
                )
              )
            )
          ),
          section({ id: "services" },
            div({ class: "container" },
              div({ class: "row" },
                div({ class: "col-lg-12 text-center" },
                  h2({ class: "section-heading" }, "✨ So Fucking Revolutionary"),
                  hr({ class: "primary" })
                )
              )
            ),
            div({ class: "container" },
              div({ class: "row" },
                div({ class: "col-lg-3 col-md-6 text-center" },
                  div({ class: "service-box" },
                    i({ class: "fa fa-4x fa-magic wow bounceIn text-primary" }),
                    h3("AI Did Everything"),
                    p({ class: "text-muted" }, "Why understand your own code when Claude can hallucinate it for you? Just keep hitting 'regenerate' until something works!")
                  )
                ),
                div({ class: "col-lg-3 col-md-6 text-center" },
                  div({ class: "service-box" },
                    i({ class: "fa fa-4x fa-copy wow bounceIn text-primary" }),
                    h3("Copy-Paste Excellence"),
                    p({ class: "text-muted" }, "We use the revolutionary technique of copying code we don't understand and hoping it works. Shipped in record time!")
                  )
                ),
                div({ class: "col-lg-3 col-md-6 text-center" },
                  div({ class: "service-box" },
                    i({ class: "fa fa-4x fa-laptop wow bounceIn text-primary" }),
                    h3("Works On My Machine"),
                    p({ class: "text-muted" }, "Tested extensively on localhost once. Users reporting bugs? Just ask the AI to fix it without understanding the root cause!")
                  )
                ),
                div({ class: "col-lg-3 col-md-6 text-center" },
                  div({ class: "service-box" },
                    i({ class: "fa fa-4x fa-bolt wow bounceIn text-primary" }),
                    h3("Zero Planning"),
                    p({ class: "text-muted" }, "Architecture? Tests? Documentation? Nah bro, we just vibe with it. The AI knows best, probably.")
                  )
                )
              )
            )
          ),
          section({ id: "tailwind", style: "padding: 80px 0; background: linear-gradient(135deg, #38bdf8 0%, #0ea5e9 100%);" },
            div({ class: "container" },
              div({ class: "row" },
                div({ class: "col-lg-8 col-lg-offset-2 text-center" },
                  h2({ style: "color: #fff; font-size: 36px; font-weight: 700; margin-bottom: 20px;" }, "Wait, Not Enough Tailwind?"),
                  p({ style: "color: #fff; font-size: 18px; margin-bottom: 30px; opacity: 0.95;" },
                    a({ href: "https://news.ycombinator.com/item?id=45623749", target: "_blank", style: "color: #fff; text-decoration: underline;" }, "Someone said"),
                    text("Not enough tailwind. 6/10. So here's a literal tail in the wind.")
                  ),
                  div({ style: "max-width: 600px; margin: 0 auto;" },
                    img({ src: "https://images.unsplash.com/photo-1548681528-6a5c45b66b42?w=800&q=80", alt: "Dog with tail blowing in wind", style: "width: 100%; border-radius: 12px; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.3); border: 3px solid #fff;" }),
                    p({ style: "color: #fff; margin-top: 20px; font-style: italic; font-size: 14px; opacity: 0.9;" },
                      text("This is as close to Tailwind CSS as we're getting on a pure HTML site."),
                      br("But hey, we added rounded corners and shadows, so basically the same thing.")
                    )
                  )
                )
              )
            )
          ),
          section({ id: "security", style: "padding: 80px 0; background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);" },
            div({ class: "container" },
              div({ class: "row" },
                div({ class: "col-lg-8 col-lg-offset-2 text-center" },
                  h2({ style: "color: #fff; font-size: 36px; font-weight: 700; margin-bottom: 20px;" }, "⚠️ Security Notice ⚠️"),
                  p({ style: "color: #fff; font-size: 18px; margin-bottom: 20px; opacity: 0.95;" },
                    a({ href: "https://news.ycombinator.com/item?id=45623603", target: "_blank", style: "color: #fff; text-decoration: underline;" }, "A security researcher"),
                    text(" pointed out that even though this is a static website, we accidentally leaked your password.")
                  ),
                  div({ style: "background: rgba(0,0,0,0.3); padding: 30px; border-radius: 12px; margin: 20px auto; max-width: 600px; border: 2px solid rgba(255,255,255,0.3);" },
                    p({ style: "color: #fff; font-size: 16px; margin-bottom: 15px;" }, "Your password is:"),
                    p({ style: "color: #fff; font-size: 32px; font-weight: 700; font-family: monospace; letter-spacing: 2px; margin: 0;" }, "hunter2"),
                    p({ style: "color: #fff; font-size: 14px; margin-top: 15px; opacity: 0.8; font-style: italic;" }, "Don't worry, we can only see ******* on our end.")
                  ),
                  p({ style: "color: #fff; font-size: 14px; opacity: 0.9; font-style: italic;" },
                    text("This is what happens when you let Claude handle authentication without understanding OAuth."),
                    br("But hey, we used HTTPS! That counts for something, right?")
                  )
                )
              )
            )
          ),
          section({ id: "project-structure", style: "padding: 80px 0; background: linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%);" },
            div({ class: "container" },
              div({ class: "row" },
                div({ class: "col-lg-8 col-lg-offset-2 text-center" },
                  h2({ style: "color: #fff; font-size: 36px; font-weight: 700; margin-bottom: 20px;" }, "📁 Professional Project Structure"),
                  p({ style: "color: #fff; font-size: 18px; margin-bottom: 30px; opacity: 0.95;" },
                    a({ href: "https://news.ycombinator.com/item?id=45623895", target: "_blank", style: "color: #fff; text-decoration: underline;" }, "Someone assumed"),
                    text(" our project directory looks messy because we used Claude. They were absolutely right.")
                  ),
                  div({ style: "background: rgba(0,0,0,0.4); padding: 30px; border-radius: 12px; margin: 20px auto; max-width: 600px; border: 2px solid rgba(255,255,255,0.3); text-align: left;" },
                    p({ style: "color: #22c55e; font-family: monospace; font-size: 14px; margin: 5px 0;" }, "index.html"),
                    p({ style: "color: #22c55e; font-family: monospace; font-size: 14px; margin: 5px 0;" }, "index-working.html"),
                    p({ style: "color: #22c55e; font-family: monospace; font-size: 14px; margin: 5px 0;" }, "index-revised.html"),
                    p({ style: "color: #22c55e; font-family: monospace; font-size: 14px; margin: 5px 0;" }, "index-revised-2.html"),
                    p({ style: "color: #22c55e; font-family: monospace; font-size: 14px; margin: 5px 0;" }, "debug-site-on-mobile-issue.sh"),
                    p({ style: "color: #22c55e; font-family: monospace; font-size: 14px; margin: 5px 0;" }, "index-backup-2.html"),
                    p({ style: "color: #22c55e; font-family: monospace; font-size: 14px; margin: 5px 0;" }, "DEBUGGING-RESULTS.md"),
                    p({ style: "color: #22c55e; font-family: monospace; font-size: 14px; margin: 5px 0;" }, "CLAUDE.md"),
                    p({ style: "color: #22c55e; font-family: monospace; font-size: 14px; margin: 5px 0;" }, "INSTALLATION-INSTRUCTIONS.md"),
                    p({ style: "color: #64748b; font-family: monospace; font-size: 14px; margin: 5px 0;" }, "css/")
                  ),
                  p({ style: "color: #fff; font-size: 14px; opacity: 0.9; font-style: italic; margin-top: 20px;" },
                    text("Don't believe us? "),
                    a({ href: "https://github.com/up-to-speed/vibe-coded-lol", target: "_blank", style: "color: #fff; text-decoration: underline;" }, "Check the repo yourself"),
                    text("."),
                    br("We commit our sins to version control.")
                  )
                )
              )
            )
          ),
          section({ id: "broken-links", style: "padding: 80px 0; background: linear-gradient(135deg, #10b981 0%, #059669 100%);" },
            div({ class: "container" },
              div({ class: "row" },
                div({ class: "col-lg-8 col-lg-offset-2 text-center" },
                  h2({ style: "color: #fff; font-size: 36px; font-weight: 700; margin-bottom: 20px;" }, "🔗 Important Resources"),
                  p({ style: "color: #fff; font-size: 18px; margin-bottom: 30px; opacity: 0.95;" },
                    a({ href: "https://news.ycombinator.com/item?id=45624853", target: "_blank", style: "color: #fff; text-decoration: underline;" }, "Someone said"),
                    text(" no LLM-autocompleted website is complete without broken links. So here you go!")
                  ),
                  div({ style: "display: flex; flex-direction: column; gap: 15px; max-width: 400px; margin: 0 auto;" },
                    a({ href: "/docs", class: "btn btn-default btn-xl", style: "background: rgba(255,255,255,0.9); color: #059669;" }, "📚 Documentation"),
                    a({ href: "/api/v1/swagger", class: "btn btn-default btn-xl", style: "background: rgba(255,255,255,0.9); color: #059669;" }, "🔧 API Reference"),
                    a({ href: "/login", class: "btn btn-default btn-xl", style: "background: rgba(255,255,255,0.9); color: #059669;" }, "🔐 Customer Portal"),
                    a({ href: "/pricing", class: "btn btn-default btn-xl", style: "background: rgba(255,255,255,0.9); color: #059669;" }, "💰 Pricing Plans"),
                    a({ href: "/blog", class: "btn btn-default btn-xl", style: "background: rgba(255,255,255,0.9); color: #059669;" }, "📝 Our Blog"),
                    a({ href: "/careers", class: "btn btn-default btn-xl", style: "background: rgba(255,255,255,0.9); color: #059669;" }, "🚀 Join Our Team")
                  ),
                  p({ style: "color: #fff; font-size: 14px; opacity: 0.9; font-style: italic; margin-top: 30px;" },
                    text("None of these links work. That's what happens when Claude generates your navbar."),
                    br("But hey, they look professional! That's what matters, right?")
                  )
                )
              )
            )
          ),
          section({ id: "testimonials", style: "padding: 80px 0; background: linear-gradient(135deg, #fbbf24 0%, #f59e0b 100%);" },
            div({ class: "container" },
              div({ class: "row" },
                div({ class: "col-lg-12 text-center" },
                  h2({ style: "color: #fff; font-size: 36px; font-weight: 700; margin-bottom: 50px;" }, "🌟 What Our Customers Are Saying")
                )
              ),
              div({ class: "row" },
                div({ class: "col-lg-4 col-md-6" },
                  div({ style: "background: rgba(255,255,255,0.95); padding: 30px; border-radius: 12px; margin-bottom: 30px; min-height: 250px;" },
                    p({ style: "font-style: italic; font-size: 16px; line-height: 1.6; margin-bottom: 20px;" }, "This product changed my life! I can't say exactly how, but the landing page looked so professional that I had to buy it. 10/10 would purchase again without reading the documentation."),
                    p({ style: "font-weight: 700; margin: 0;" }, "— Sarah M."),
                    p({ style: "color: #666; font-size: 14px;" }, "CEO at {{CUSTOMER_COMPANY_1}}")
                  )
                ),
                div({ class: "col-lg-4 col-md-6" },
                  div({ style: "background: rgba(255,255,255,0.95); padding: 30px; border-radius: 12px; margin-bottom: 30px; min-height: 250px;" },
                    p({ style: "font-style: italic; font-size: 16px; line-height: 1.6; margin-bottom: 20px;" }, "Absolutely revolutionary! I have no idea what it does, but the gradient buttons convinced me this was the future. We immediately deployed it to production."),
                    p({ style: "font-weight: 700; margin: 0;" }, "— Michael R."),
                    p({ style: "color: #666; font-size: 14px;" }, "CTO at [Object Object]")
                  )
                ),
                div({ class: "col-lg-4 col-md-6" },
                  div({ style: "background: rgba(255,255,255,0.95); padding: 30px; border-radius: 12px; margin-bottom: 30px; min-height: 250px;" },
                    p({ style: "font-style: italic; font-size: 16px; line-height: 1.6; margin-bottom: 20px;" }, "The best undefined solution I've ever NaN! Our ROI increased by null% in just undefined weeks. Highly recommend to anyone looking for something!"),
                    p({ style: "font-weight: 700; margin: 0;" }, "— Jennifer K."),
                    p({ style: "color: #666; font-size: 14px;" }, "Founder at TechCorp Solutions Inc.")
                  )
                )
              ),
              p({ style: "color: #fff; text-align: center; font-size: 14px; opacity: 0.9; font-style: italic; margin-top: 20px;" }, "* According to Claude, all testimonials were generated by GPT-3.5. Any resemblance to real persons is purely coincidental. Any damages resulting from testimonials are GPT's fault.")
            )
          ),
          section({ id: "metrics", style: "padding: 80px 0; background: #fff;" },
            div({ class: "container" },
              div({ class: "row" },
                div({ class: "col-lg-12 text-center" },
                  h2({ style: "font-size: 36px; font-weight: 700; margin-bottom: 50px;" }, "📊 Our Incredible Metrics")
                )
              ),
              div({ class: "row text-center" },
                div({ class: "col-lg-3 col-md-6" },
                  div({ style: "padding: 30px;" },
                    h3({ style: "font-size: 48px; font-weight: 900; color: #667eea; margin: 0;" }, "99.9%"),
                    p({ style: "font-size: 18px; font-weight: 600; margin-top: 10px;" }, "Uptime*"),
                    p({ style: "color: #666; font-size: 12px;" }, "*When localhost is running")
                  )
                ),
                div({ class: "col-lg-3 col-md-6" },
                  div({ style: "padding: 30px;" },
                    h3({ style: "font-size: 48px; font-weight: 900; color: #764ba2; margin: 0;" }, tex: "10x"),
                    p({ style: "font-size: 18px; font-weight: 600; margin-top: 10px;" }, "Faster Development"),
                    p({ style: "color: #666; font-size: 12px;" }, "Than actually learning to code")
                  )
                ),
                div({ class: "col-lg-3 col-md-6" },
                  div({ style: "padding: 30px;" },
                    h3({ style: "font-size: 48px; font-weight: 900; color: #F05F40; margin: 0;" }, tex: "∞"),
                    p({ style: "font-size: 18px; font-weight: 600; margin-top: 10px;" }, "Potential Bugs"),
                    p({ style: "color: #666; font-size: 12px;" }, "We don't test, we iterate")
                  )
                ),
                div({ class: "col-lg-3 col-md-6" },
                  div({ style: "padding: 30px;" },
                    h3({ style: "font-size: 48px; font-weight: 900; color: #10b981; margin: 0;" }, "420%"),
                    p({ style: "font-size: 18px; font-weight: 600; margin-top: 10px;" }, "AI-Powered"),
                    p({ style: "color: #666; font-size: 12px;" }, "Whatever that means")
                  )
                )
              ),
              div({ class: "row text-center", style: "margin-top: 30px;" },
                div({ class: "col-lg-3 col-md-6" },
                  div({ style: "padding: 30px;" },
                    h3({ style: "font-size: 48px; font-weight: 900; color: #8b5cf6; margin: 0;" }, "$0"),
                    p({ style: "font-size: 18px; font-weight: 600; margin-top: 10px;" }, "Revenue"),
                    p({ style: "color: #666; font-size: 12px;" }, "But we're pre-revenue by choice")
                  )
                ),
                div({ class: "col-lg-3 col-md-6" },
                  div({ style: "padding: 30px;" },
                    h3({ style: "font-size: 48px; font-weight: 900; color: #ef4444; margin: 0;" }, "NaN"),
                    p({ style: "font-size: 18px; font-weight: 600; margin-top: 10px;" }, "Customer Satisfaction"),
                    p({ style: "color: #666; font-size: 12px;" }, "Cannot divide by zero customers")
                  )
                ),
                div({ class: "col-lg-3 col-md-6" },
                  div({ style: "padding: 30px;" },
                    h3({ style: "font-size: 48px; font-weight: 900; color: #06b6d4; margin: 0;" }, "1"),
                    p({ style: "font-size: 18px; font-weight: 600; margin-top: 10px;" }, "Developer"),
                    p({ style: "color: #666; font-size: 12px;" }, "Claude doesn't count as an employee")
                  )
                ),
                div({ class: "col-lg-3 col-md-6" },
                  div({ style: "padding: 30px;" },
                    h3({ style: "font-size: 48px; font-weight: 900; color: #f59e0b; margin: 0;" }, "69"),
                    p({ style: "font-size: 18px; font-weight: 600; margin-top: 10px;" }, "Prompts to Build This"),
                    p({ style: "color: #666; font-size: 12px;" }, "Nice")
                  )
                )
              )
            )
          ),
          section({ class: "no-padding", id: "portfolio" },
            div({ class: "container-fluid" },
              div({ class: "row no-gutter" },
                div({ class: "col-lg-4 col-sm-6" },
                  div({ class: "portfolio-box" },
                    img({ src: "https://picsum.photos/650/350?random=1", class: "img-responsive", alt: "" }),
                    div({ class: "portfolio-box-caption" },
                      div({ class: "portfolio-box-caption-content" },
                        div({ class: "project-category text-faded" },
                          text("Generic Thing")
                        ),
                        div({ class: "project-name" },
                          text("AI Generated")
                        )
                      )
                    )
                  )
                ),
                div({ class: "col-lg-4 col-sm-6" },
                  div({ class: "portfolio-box" },
                    img({ src: "https://picsum.photos/650/350?random=2", class: "img-responsive", alt: "" }),
                    div({ class: "portfolio-box-caption" },
                      div({ class: "portfolio-box-caption-content" },
                        div({ class: "project-category text-faded" },
                          text("Stock Photo")
                        ),
                        div({ class: "project-name" },
                          text("Looks Professional")
                        )
                      )
                    )
                  )
                ),
                div({ class: "col-lg-4 col-sm-6" },
                  div({ class: "portfolio-box" },
                    img({ src: "https://picsum.photos/650/350?random=3", class: "img-responsive", alt: "" }),
                    div({ class: "portfolio-box-caption" },
                      div({ class: "portfolio-box-caption-content" },
                        div({ class: "project-category text-faded" },
                          text("Random Image")
                        ),
                        div({ class: "project-name" },
                          text("From Unsplash")
                        )
                      )
                    )
                  )
                ),
                div({ class: "col-lg-4 col-sm-6" },
                  div({ class: "portfolio-box" },
                    img({ src: "https://picsum.photos/650/350?random=4", class: "img-responsive", alt: "" }),
                    div({ class: "portfolio-box-caption" },
                      div({ class: "portfolio-box-caption-content" },
                        div({ class: "project-category text-faded" },
                          text("Another One")
                        ),
                        div({ class: "project-name" },
                          text("Same Vibes")
                        )
                      )
                    )
                  )
                ),
                div({ class: "col-lg-4 col-sm-6" },
                  div({ class: "portfolio-box" },
                    img({ src: "https://picsum.photos/650/350?random=5", class: "img-responsive", alt: "" }),
                    div({ class: "portfolio-box-caption" },
                      div({ class: "portfolio-box-caption-content" },
                        div({ class: "project-category text-faded" },
                          text("Fifth Thing")
                        ),
                        div({ class: "project-name" },
                          text("Still Going")
                        )
                      )
                    )
                  )
                ),
                div({ class: "col-lg-4 col-sm-6" },
                  div({ class: "portfolio-box" },
                    img({ src: "https://picsum.photos/650/350?random=6", class: "img-responsive", alt: "" }),
                    div({ class: "portfolio-box-caption" },
                      div({ class: "portfolio-box-caption-content" },
                        div({ class: "project-category text-faded" },
                          text("Last One")
                        ),
                        div({ class: "project-name" },
                          text("Placeholder")
                        )
                      )
                    )
                  )
                )
              )
            )
          ),
          aside({ class: "bg-dark" },
            div({ class: "container text-center" },
              div({ class: "call-to-action" },
                h2("Seriously, Just Prompt It And Ship It!"),
                a({ href: "#", class: "btn btn-default btn-xl wow tada" }, "That's The Hustle!")
              )
            )
          ),
          section({ id: "contact" },
            div({ class: "container" },
              div({ class: "row" },
                div({ class: "col-lg-8 col-lg-offset-2 text-center" },
                  h2({ class: "section-heading" }, "📱 Hit Me Up"),
                  hr({ class: "primary" }),
                  p("Here's my contact info because that's what Claude suggested when I prompted 'make me a website'. Can't wait for all the recruiters asking if I 'really know how to code' or if I just prompt stuff. Of course I know how to code! I can write a mean ChatGPT prompt!"),
                  p("This site was built in 5 minutes by asking Claude 'make me a website' and I'm very proud of myself."),
                  p("No, I did not read any of the code. Yes, it works. No, I cannot explain how. Yes, I will put 'Full Stack Developer' on my resume.")
                ),
                div({ class: "col-lg-4 col-lg-offset-2 text-center" },
                  i({ class: "fa fa-phone fa-3x wow bounceIn" }),
                  p("+1-555-PROMPT-ME")
                ),
                div({ class: "col-lg-4 text-center" },
                  i({ class: "fa fa-envelope-o fa-3x wow bounceIn" }),
                  p(
                    a({ href: "mailto:vibes@only.dev" }, "vibes@only.dev")
                  )
                )
              ),
              div({ class: "row" },
                div({ class: "col-lg-12 text-center", style: "margin-top: 30px;" },
                  p({ style: "font-size: 14px; opacity: 0.7; font-style: italic;" },
                    text("(You can also DM "),
                    a({ href: "https://x.com/jimmykoppel", target: "_blank", style: "text-decoration: underline;" },
                      text("Jimmy K "),
                      i({ class: "fa fa-twitter" })
                    ),
                    text(" and he'll forward your message to Claude)")
                  )
                )
              )
            )
          ),
          link({ rel: "stylesheet", href: "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" }),
          div({ id: "cookieBanner", style: "position: fixed; bottom: 0; left: 0; right: 0; background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%); color: #fff; padding: 30px 20px; box-shadow: 0 -4px 6px -1px rgba(0, 0, 0, 0.3); z-index: 9999; border-top: 3px solid #8b5cf6; display: none;" },
            div({ style: "max-width: 1200px; margin: 0 auto;" },
              h3({ style: "margin: 0 0 15px 0; font-size: 20px; font-weight: 700;" }, "🍪 We Value Your Privacy (Not Really)"),
              p({ style: "margin: 0 0 20px 0; font-size: 14px; line-height: 1.6; opacity: 0.9;" },
                text("This website uses cookies, localStorage, sessionStorage, IndexedDB, WebSQL, browser fingerprinting, canvas fingerprinting, and probably your mom's maiden name to track literally everything you do. We share this data with 847 trusted partners including but not limited to: advertisers, data brokers, that sketchy startup in the Caymans, and anyone willing to pay $0.003 per record."),
                br(),
                br(),
                text("By clicking 'Accept All' you agree to let us sell your data. By clicking 'Reject All' you agree to let us sell your data anyway. By clicking 'Customize' you get to pretend you have a choice while we still sell your data."),
                br(),
                br(),
                a({ href: "https://news.ycombinator.com/item?id=45624294", target: "_blank", style: "color: #8b5cf6; text-decoration: underline;" }, "Someone asked"),
                text(" where the cookie banner was. Here you go.")
              ),
              div({ style: "display: flex; gap: 10px; flex-wrap: wrap;" },
                button({ onclick: "acceptCookies()", style: "background: #8b5cf6; color: #fff; border: none; padding: 12px 24px; border-radius: 6px; font-weight: 600; cursor: pointer; font-size: 14px;" }, "Accept All (Sell My Soul)"),
                button({ onclick: "acceptCookies()", style: "background: #64748b; color: #fff; border: none; padding: 12px 24px; border-radius: 6px; font-weight: 600; cursor: pointer; font-size: 14px;" }, "Reject All (Sell My Soul Anyway)"),
                button({ onclick: "acceptCookies()", style: "background: transparent; color: #fff; border: 2px solid #fff; padding: 12px 24px; border-radius: 6px; font-weight: 600; cursor: pointer; font-size: 14px;" }, "Customize (Waste Time)")
              )
            )
          ),
          script()
        )
      )
    )
    landing_result = landing.run(config: config, state: initial_state)

    expect(landing_result.result).to be_a(Success)
  end
end
