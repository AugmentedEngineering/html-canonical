# HTML Canonical

A Ruby DSL for developing **semantic, standards-compliant HTML** where **invalid states are impossible to represent**.

Semantic html is a crucial aspect of any content website. Normally this aspect is left as an afterthougt and relies on linters and evaluators that run **after** the documents are created.

TypeScript is to Javascript what HtmlCanonical is to Html, by enforcing the content models defined in the Html Specs, invalid states are impossible to represent and the generated documents are always valid.

---

## Why This Project?

Writing HTML directly is flexible—but that flexibility makes it easy to create:

- Accessibility issues
- Invalid nesting
- Missing required elements
- Incorrect attribute usage
- Poor semantic structure

**HTMLCanonical** solves this by:

- Enforcing valid element content models
- Making invalid HTML structurally impossible
- Encouraging accessibility and best practices

---

## Goals

- Generate **valid HTML by construction**
- Follow the **HTML Living Standard**
- Promote **semantic and accessible markup**
- Catch errors **at build time**, not in the browser

---

## Influences

- [Understanding Progresive Enhancement](https://alistapart.com/article/understandingprogressiveenhancement/)
- [motherfuckingwebsite.com](https://motherfuckingwebsite.com/)

---

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

----
To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/html-canonical. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/html-canonical/blob/main/CODE_OF_CONDUCT.md).

----
## Code of Conduct

Everyone interacting in the Html::Canonical project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/html-canonical/blob/main/CODE_OF_CONDUCT.md).
