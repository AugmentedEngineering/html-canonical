# frozen_string_literal: true

require_relative "canonical/builder"
require_relative "canonical/html_config"
require_relative "canonical/html_node"
require_relative "canonical/version"

module Html
  module Canonical
    class Error < StandardError; end
    ALL_ELEMENTS = {
      "a" => {
        description: "Hyperlink",
        categories: [ "flow", "phrasing", "interactive", "palpable", "a" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "transparent" ],
        attributes: [ "globals", "href", "target", "download", "ping", "rel", "hreflang", "type", "referrerpolicy" ]
      },
      "abbr" => {
        description: "Abbreviation",
        categories: [ "flow", "phrasing", "palpable", "abbr" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals" ]
      },
      "address" => {
        description: "Contact information for a page or article element",
        categories: [ "flow", "palpable", "address" ],
        parent_categories: [ "flow" ],
        children_categories: [ "flow" ],
        attributes: [ "globals" ]
      },
      "area" => {
        description: "Hyperlink or dead area on an image map",
        categories: [ "flow", "phrasing", "area" ],
        parent_categories: [ "phrasing" ],
        children_categories: [],
        attributes: [ "globals", "alt", "coords", "shape", "href", "target", "download", "ping", "rel", "referrerpolicy" ]
      },
      "article" => {
        description: "Self-contained syndicatable or reusable composition",
        categories: [ "flow", "sectioning", "palpable", "article" ],
        parent_categories: [ "flow" ],
        children_categories: [ "flow" ],
        attributes: [ "globals" ]
      },
      "aside" => {
        description: "Sidebar for tangentially related content",
        categories: [ "flow", "sectioning", "palpable", "aside" ],
        parent_categories: [ "flow" ],
        children_categories: [ "flow" ],
        attributes: [ "globals" ]
      },
      "audio" => {
        description: "Audio player",
        categories: [ "flow", "phrasing", "embedded", "interactive", "palpable", "audio" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "source", "track", "transparent" ],
        attributes: [ "globals", "src", "crossorigin", "preload", "autoplay", "loop", "muted", "controls" ]
      },
      "b" => {
        description: "Keywords",
        categories: [ "flow", "phrasing", "palpable", "b" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals" ]
      },
      "base" => {
        description: "Base URL and default target navigable for hyperlinks and forms",
        categories: [ "metadata", "base" ],
        parent_categories: [ "head" ],
        children_categories: [],
        attributes: [ "globals", "href", "target" ]
      },
      "bdi" => {
        description: "Text directionality isolation",
        categories: [ "flow", "phrasing", "palpable", "bdi" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals" ]
      },
      "bdo" => {
        description: "Text directionality formatting",
        categories: [ "flow", "phrasing", "palpable", "bdo" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals" ]
      },
      "blockquote" => {
        description: "A section quoted from another source",
        categories: [ "flow", "palpable", "blockquote" ],
        parent_categories: [ "flow" ],
        children_categories: [ "flow" ],
        attributes: [ "globals", "cite" ]
      },
      "body" => {
        description: "Document body",
        categories: [ "sectioning", "body" ],
        parent_categories: [ "html" ],
        children_categories: [ "flow" ],
        attributes: [ "globals", "onafterprint", "onbeforeprint", "onbeforeunload", "onhashchange", "onlanguagechange", "onmessage", "onmessageerror", "onoffline", "ononline", "onpageswap", "onpagehide", "onpagereveal", "onpageshow", "onpopstate", "onrejectionhandled", "onstorage", "onunhandledrejection", "onunload" ]
      },
      "br" => {
        description: "Line break, e.g. in poem or postal address",
        categories: [ "flow", "phrasing", "br" ],
        parent_categories: [ "phrasing" ],
        children_categories: [],
        attributes: [ "globals" ]
      },
      "button" => {
        description: "Button control",
        categories: [ "flow", "phrasing", "interactive", "listed", "labelable", "submittable", "form-associated", "palpable", "button" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals", "command", "commandfor", "disabled", "form", "formaction", "formenctype", "formmethod", "formnovalidate", "formtarget", "name", "popovertarget", "popovertargetaction", "type", "value" ]
      },
      "canvas" => {
        description: "Scriptable bitmap canvas",
        categories: [ "flow", "phrasing", "embedded", "palpable", "canvas" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "transparent" ],
        attributes: [ "globals", "width", "height" ]
      },
      "caption" => {
        description: "Table caption",
        categories: [ "caption" ],
        parent_categories: [ "table" ],
        children_categories: [ "flow" ],
        attributes: [ "globals" ]
      },
      "cite" => {
        description: "Title of a work",
        categories: [ "flow", "phrasing", "palpable", "cite" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals" ]
      },
      "code" => {
        description: "Computer code",
        categories: [ "flow", "phrasing", "palpable", "code" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals" ]
      },
      "col" => {
        description: "Table column",
        categories: [ "col" ],
        parent_categories: [ "colgroup" ],
        children_categories: [],
        attributes: [ "globals", "span" ]
      },
      "colgroup" => {
        description: "Group of columns in a table",
        categories: [ "colgroup" ],
        parent_categories: [ "table" ],
        children_categories: [ "col", "template" ],
        attributes: [ "globals", "span" ]
      },
      "data" => {
        description: "Machine-readable equivalent",
        categories: [ "flow", "phrasing", "palpable", "data" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals", "value" ]
      },
      "datalist" => {
        description: "Container for options for combo box control",
        categories: [ "flow", "phrasing", "datalist" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "phrasing", "option", "script-supporting elements" ],
        attributes: [ "globals" ]
      },
      "dd" => {
        description: "Content for corresponding dt element(s)",
        categories: [ "dd" ],
        parent_categories: [ "dl", "div" ],
        children_categories: [ "flow" ],
        attributes: [ "globals" ]
      },
      "del" => {
        description: "A removal from the document",
        categories: [ "flow", "phrasing", "palpable", "del" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "transparent" ],
        attributes: [ "globals", "cite", "datetime" ]
      },
      "details" => {
        description: "Disclosure control for hiding details",
        categories: [ "flow", "interactive", "palpable", "details" ],
        parent_categories: [ "flow" ],
        children_categories: [ "summary", "flow" ],
        attributes: [ "globals", "name", "open" ]
      },
      "dfn" => {
        description: "Defining instance",
        categories: [ "flow", "phrasing", "palpable", "dfn" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals" ]
      },
      "dialog" => {
        description: "Dialog box or window",
        categories: [ "flow", "dialog" ],
        parent_categories: [ "flow" ],
        children_categories: [ "flow" ],
        attributes: [ "globals", "open" ]
      },
      "div" => {
        description: "Generic flow container, or container for name-value groups in dl elements",
        categories: [ "flow", "palpable", "select element inner content elements", "optgroup element inner content elements", "option element inner content elements", "div" ],
        parent_categories: [ "flow", "dl", "select element inner content elements", "optgroup element inner content elements", "option element inner content elements" ],
        children_categories: [ "flow", "select element inner content elements", "optgroup element inner content elements", "option element inner content elements" ],
        attributes: [ "globals" ]
      },
      "dl" => {
        description: "Association list consisting of zero or more name-value groups",
        categories: [ "flow", "palpable", "dl" ],
        parent_categories: [ "flow" ],
        children_categories: [ "dt", "dd", "div", "script-supporting elements" ],
        attributes: [ "globals" ]
      },
      "dt" => {
        description: "Legend for corresponding dd element(s)",
        categories: [ "dt" ],
        parent_categories: [ "dl", "div" ],
        children_categories: [ "flow" ],
        attributes: [ "globals" ]
      },
      "em" => {
        description: "Stress emphasis",
        categories: [ "flow", "phrasing", "palpable", "em" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals" ]
      },
      "embed" => {
        description: "Plugin",
        categories: [ "flow", "phrasing", "embedded", "interactive", "palpable", "embed" ],
        parent_categories: [ "phrasing" ],
        children_categories: [],
        attributes: [ "globals", "src", "type", "width", "height" ]
      },
      "fieldset" => {
        description: "Group of form controls",
        categories: [ "flow", "listed", "form-associated", "palpable", "fieldset" ],
        parent_categories: [ "flow" ],
        children_categories: [ "legend", "flow" ],
        attributes: [ "globals", "disabled", "form", "name" ]
      },
      "figcaption" => {
        description: "Caption for figure",
        categories: [ "figcaption" ],
        parent_categories: [ "figure" ],
        children_categories: [ "flow" ],
        attributes: [ "globals" ]
      },
      "figure" => {
        description: "Figure with optional caption",
        categories: [ "flow", "palpable", "figure" ],
        parent_categories: [ "flow" ],
        children_categories: [ "figcaption", "flow" ],
        attributes: [ "globals" ]
      },
      "footer" => {
        description: "Footer for a page or section",
        categories: [ "flow", "palpable", "footer" ],
        parent_categories: [ "flow" ],
        children_categories: [ "flow" ],
        attributes: [ "globals" ]
      },
      "form" => {
        description: "User-submittable form",
        categories: [ "flow", "palpable", "form" ],
        parent_categories: [ "flow" ],
        children_categories: [ "flow" ],
        attributes: [ "globals", "accept-charset", "action", "autocomplete", "enctype", "method", "name", "novalidate", "rel", "target" ]
      },
      "h1" => {
        description: "Heading",
        categories: [ "flow", "heading", "palpable", "h1" ],
        parent_categories: [ "legend", "summary", "flow" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals" ]
      },
      "h2" => {
        description: "Heading",
        categories: [ "flow", "heading", "palpable", "h2" ],
        parent_categories: [ "legend", "summary", "flow" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals" ]
      },
      "h3" => {
        description: "Heading",
        categories: [ "flow", "heading", "palpable", "h3" ],
        parent_categories: [ "legend", "summary", "flow" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals" ]
      },
      "h4" => {
        description: "Heading",
        categories: [ "flow", "heading", "palpable", "h4" ],
        parent_categories: [ "legend", "summary", "flow" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals" ]
      },
      "h5" => {
        description: "Heading",
        categories: [ "flow", "heading", "palpable", "h5" ],
        parent_categories: [ "legend", "summary", "flow" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals" ]
      },
      "h6" => {
        description: "Heading",
        categories: [ "flow", "heading", "palpable", "h6" ],
        parent_categories: [ "legend", "summary", "flow" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals" ]
      },
      "head" => {
        description: "Container for document metadata",
        categories: [ "head" ],
        parent_categories: [ "html" ],
        children_categories: [ "metadata" ],
        attributes: [ "globals" ]
      },
      "header" => {
        description: "Introductory or navigational aids for a page or section",
        categories: [ "flow", "palpable", "header" ],
        parent_categories: [ "flow" ],
        children_categories: [ "flow" ],
        attributes: [ "globals" ]
      },
      "hgroup" => {
        description: "Heading container",
        categories: [ "flow", "palpable", "hgroup" ],
        parent_categories: [ "legend", "summary", "flow" ],
        children_categories: [ "h1", "h2", "h3", "h4", "h5", "h6", "p", "script-supporting elements" ],
        attributes: [ "globals" ]
      },
      "hr" => {
        description: "Thematic break",
        categories: [ "flow", "select element inner content elements", "hr" ],
        parent_categories: [ "flow", "select element inner content elements" ],
        children_categories: [],
        attributes: [ "globals" ]
      },
      "html" => {
        description: "Root element",
        categories: [ "html" ],
        parent_categories: [],
        children_categories: [ "head", "body", "footer" ],
        attributes: [ "globals" ]
      },
      "i" => {
        description: "Alternate voice",
        categories: [ "flow", "phrasing", "palpable", "i" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals" ]
      },
      "iframe" => {
        description: "Child navigable",
        categories: [ "flow", "phrasing", "embedded", "interactive", "palpable", "iframe" ],
        parent_categories: [ "phrasing" ],
        children_categories: [],
        attributes: [ "globals", "src", "srcdoc", "name", "sandbox", "allow", "allowfullscreen", "width", "height", "referrerpolicy", "loading" ]
      },
      "img" => {
        description: "Image",
        categories: [ "flow", "phrasing", "embedded", "interactive", "form-associated", "palpable", "img" ],
        parent_categories: [ "phrasing", "picture" ],
        children_categories: [],
        attributes: [ "globals", "alt", "src", "srcset", "sizes", "crossorigin", "usemap", "ismap", "width", "height", "referrerpolicy", "decoding", "loading", "fetchpriority" ]
      },
      "input" => {
        description: "Form control",
        categories: [ "flow", "phrasing", "interactive", "listed", "labelable", "submittable", "resettable", "form-associated", "palpable", "input" ],
        parent_categories: [ "phrasing" ],
        children_categories: [],
        attributes: [ "globals", "accept", "alpha", "alt", "autocomplete", "checked", "colorspace", "dirname", "disabled", "form", "formaction", "formenctype", "formmethod", "formnovalidate", "formtarget", "height", "list", "max", "maxlength", "min", "minlength", "multiple", "name", "pattern", "placeholder", "popovertarget", "popovertargetaction", "readonly", "required", "size", "src", "step", "type", "value", "width" ]
      },
      "ins" => {
        description: "An addition to the document",
        categories: [ "flow", "phrasing", "palpable", "ins" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "transparent" ],
        attributes: [ "globals", "cite", "datetime" ]
      },
      "kbd" => {
        description: "User input",
        categories: [ "flow", "phrasing", "palpable", "kbd" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals" ]
      },
      "label" => {
        description: "Caption for a form control",
        categories: [ "flow", "phrasing", "interactive", "palpable", "label" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals", "for" ],
        validation: ->(kids, atts) {
          has_for = !!atts["for"]
          has_input = kids.any? { it.tag_name == "input" }
          !has_for && !has_input ? "Label needs 'for' attr or nested input" : nil
        }
      },
      "legend" => {
        description: "Caption for fieldset",
        categories: [ "legend" ],
        parent_categories: [ "fieldset", "optgroup" ],
        children_categories: [ "phrasing", "heading content" ],
        attributes: [ "globals" ]
      },
      "li" => {
        description: "List item",
        categories: [ "li" ],
        parent_categories: [ "ol", "ul", "menu" ],
        children_categories: [ "flow" ],
        attributes: [ "globals", "value" ]
      },
      "link" => {
        description: "Link metadata",
        categories: [ "metadata", "flow", "phrasing", "link" ],
        parent_categories: [ "head", "noscript", "phrasing" ],
        children_categories: [],
        attributes: [ "globals", "href", "crossorigin", "rel", "as", "media", "hreflang", "type", "sizes", "imagesrcset", "imagesizes", "referrerpolicy", "integrity", "blocking", "color", "disabled", "fetchpriority" ]
      },
      "main" => {
        description: "Container for the dominant contents of the document",
        categories: [ "flow", "palpable", "main" ],
        parent_categories: [ "flow" ],
        children_categories: [ "flow" ],
        attributes: [ "globals" ]
      },
      "map" => {
        description: "Image map",
        categories: [ "flow", "phrasing", "palpable", "map" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "transparent", "area" ],
        attributes: [ "globals", "name" ]
      },
      "mark" => {
        description: "Highlight",
        categories: [ "flow", "phrasing", "palpable", "mark" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals" ]
      },
      "MathML math" => {
        description: "MathML root",
        categories: [ "flow", "phrasing", "embedded", "palpable", "MathML math" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "[MATHML]" ],
        attributes: [ "[MATHML]" ]
      },
      "menu" => {
        description: "Menu of commands",
        categories: [ "flow", "palpable", "menu" ],
        parent_categories: [ "flow" ],
        children_categories: [ "li", "script-supporting elements" ],
        attributes: [ "globals" ]
      },
      "meta" => {
        description: "Text metadata",
        categories: [ "metadata", "flow", "phrasing", "meta" ],
        parent_categories: [ "head", "noscript", "phrasing" ],
        children_categories: [],
        attributes: [ "globals", "name", "http-equiv", "content", "charset", "media" ]
      },
      "meter" => {
        description: "Gauge",
        categories: [ "flow", "phrasing", "labelable", "palpable", "meter" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals", "value", "min", "max", "low", "high", "optimum" ]
      },
      "nav" => {
        description: "Section with navigational links",
        categories: [ "flow", "sectioning", "palpable", "nav" ],
        parent_categories: [ "flow" ],
        children_categories: [ "flow" ],
        attributes: [ "globals" ]
      },
      "noscript" => {
        description: "Fallback content for script",
        categories: [ "metadata", "flow", "phrasing", "select element inner content elements", "optgroup element inner content elements", "noscript" ],
        parent_categories: [ "head", "phrasing" ],
        children_categories: [],
        attributes: [ "globals" ]
      },
      "object" => {
        description: "Image, child navigable, or plugin",
        categories: [ "flow", "phrasing", "embedded", "interactive", "listed", "form-associated", "palpable", "object" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "transparent" ],
        attributes: [ "globals", "data", "type", "name", "form", "width", "height" ]
      },
      "ol" => {
        description: "Ordered list",
        categories: [ "flow", "palpable", "ol" ],
        parent_categories: [ "flow" ],
        children_categories: [ "li", "script-supporting elements" ],
        attributes: [ "globals", "reversed", "start", "type" ]
      },
      "optgroup" => {
        description: "Group of options in a list box",
        categories: [ "select element inner content elements", "optgroup" ],
        parent_categories: [ "select", "div" ],
        children_categories: [ "optgroup element inner content elements", "legend" ],
        attributes: [ "globals", "disabled", "label" ]
      },
      "option" => {
        description: "Option in a list box or combo box control",
        categories: [ "select element inner content elements", "optgroup element inner content elements", "option" ],
        parent_categories: [ "select", "datalist", "optgroup", "div" ],
        children_categories: [ "text", "option element inner content elements" ],
        attributes: [ "globals", "disabled", "label", "selected", "value" ]
      },
      "output" => {
        description: "Calculated output value",
        categories: [ "flow", "phrasing", "listed", "labelable", "resettable", "form-associated", "palpable", "output" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals", "for", "form", "name" ]
      },
      "p" => {
        description: "Paragraph",
        categories: [ "flow", "palpable", "p" ],
        parent_categories: [ "flow" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals" ]
      },
      "picture" => {
        description: "Image",
        categories: [ "flow", "phrasing", "embedded", "palpable", "picture" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "source", "img", "script-supporting elements" ],
        attributes: [ "globals" ]
      },
      "pre" => {
        description: "Block of preformatted text",
        categories: [ "flow", "palpable", "pre" ],
        parent_categories: [ "flow" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals" ]
      },
      "progress" => {
        description: "Progress bar",
        categories: [ "flow", "phrasing", "labelable", "palpable", "progress" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals", "value", "max" ]
      },
      "q" => {
        description: "Quotation",
        categories: [ "flow", "phrasing", "palpable", "q" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals", "cite" ]
      },
      "rp" => {
        description: "Parenthesis for ruby annotation text",
        categories: [ "rp" ],
        parent_categories: [ "ruby" ],
        children_categories: [ "text" ],
        attributes: [ "globals" ]
      },
      "rt" => {
        description: "Ruby annotation text",
        categories: [ "rt" ],
        parent_categories: [ "ruby" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals" ]
      },
      "ruby" => {
        description: "Ruby annotation(s)",
        categories: [ "flow", "phrasing", "palpable", "ruby" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "phrasing", "rt", "rp" ],
        attributes: [ "globals" ]
      },
      "s" => {
        description: "Inaccurate text",
        categories: [ "flow", "phrasing", "palpable", "s" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals" ]
      },
      "samp" => {
        description: "Computer output",
        categories: [ "flow", "phrasing", "palpable", "samp" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals" ]
      },
      "script" => {
        description: "Embedded script",
        categories: [ "metadata", "flow", "phrasing", "script-supporting", "script" ],
        parent_categories: [ "head", "phrasing", "script-supporting" ],
        children_categories: [],
        attributes: [ "globals", "src", "type", "nomodule", "async", "defer", "crossorigin", "integrity", "referrerpolicy", "blocking", "fetchpriority" ]
      },
      "search" => {
        description: "Container for search controls",
        categories: [ "flow", "palpable", "search" ],
        parent_categories: [ "flow" ],
        children_categories: [ "flow" ],
        attributes: [ "globals" ]
      },
      "section" => {
        description: "Generic document or application section",
        categories: [ "flow", "sectioning", "palpable", "section" ],
        parent_categories: [ "flow" ],
        children_categories: [ "flow" ],
        attributes: [ "globals" ]
      },
      "select" => {
        description: "List box control",
        categories: [ "flow", "phrasing", "interactive", "listed", "labelable", "submittable", "resettable", "form-associated", "palpable", "select" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "select element inner content elements", "button" ],
        attributes: [ "globals", "autocomplete", "disabled", "form", "multiple", "name", "required", "size" ]
      },
      "selectedcontent" => {
        description: "Mirrors content from an option",
        categories: [ "selectedcontent" ],
        parent_categories: [ "button" ],
        children_categories: [],
        attributes: [ "globals" ]
      },
      "slot" => {
        description: "Shadow tree slot",
        categories: [ "flow", "phrasing", "slot" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "transparent" ],
        attributes: [ "globals", "name" ]
      },
      "small" => {
        description: "Side comment",
        categories: [ "flow", "phrasing", "palpable", "small" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals" ]
      },
      "source" => {
        description: "Image source for img or media source for video or audio",
        categories: [ "source" ],
        parent_categories: [ "picture", "video", "audio" ],
        children_categories: [],
        attributes: [ "globals", "type", "media", "src", "srcset", "sizes", "width", "height" ]
      },
      "span" => {
        description: "Generic phrasing container",
        categories: [ "flow", "phrasing", "palpable", "span" ],
        parent_categories: [ "phrasing", "option element inner content elements" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals" ]
      },
      "strong" => {
        description: "Importance",
        categories: [ "flow", "phrasing", "palpable", "strong" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals" ]
      },
      "style" => {
        description: "Embedded styling information",
        categories: [ "metadata", "style" ],
        parent_categories: [ "head", "noscript" ],
        children_categories: [],
        attributes: [ "globals", "media", "blocking" ]
      },
      "sub" => {
        description: "Subscript",
        categories: [ "flow", "phrasing", "palpable", "sub" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals" ]
      },
      "summary" => {
        description: "Caption for details",
        categories: [ "summary" ],
        parent_categories: [ "details" ],
        children_categories: [ "phrasing", "heading content" ],
        attributes: [ "globals" ]
      },
      "sup" => {
        description: "Superscript",
        categories: [ "flow", "phrasing", "palpable", "sup" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals" ]
      },
      "SVG svg" => {
        description: "SVG root",
        categories: [ "flow", "phrasing", "embedded", "palpable", "SVG svg" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "[SVG]" ],
        attributes: [ "[SVG]" ]
      },
      "table" => {
        description: "Table",
        categories: [ "flow", "palpable", "table" ],
        parent_categories: [ "flow" ],
        children_categories: [ "caption", "colgroup", "thead", "tbody", "tfoot", "tr", "script-supporting elements" ],
        attributes: [ "globals" ],
        validation: ->(kids, atts) {
          kids.length.zero? ? "Table empty" : nil
        }
      },
      "tbody" => {
        description: "Group of rows in a table",
        categories: [ "tbody" ],
        parent_categories: [ "table" ],
        children_categories: [ "tr", "script-supporting elements" ],
        attributes: [ "globals" ]
      },
      "td" => {
        description: "Table cell",
        categories: [ "td" ],
        parent_categories: [ "tr" ],
        children_categories: [ "flow" ],
        attributes: [ "globals", "colspan", "rowspan", "headers" ]
      },
      "template" => {
        description: "Template",
        categories: [ "metadata", "flow", "phrasing", "script-supporting", "template" ],
        parent_categories: [ "metadata", "phrasing", "script-supporting", "colgroup" ],
        children_categories: [],
        attributes: [ "globals", "shadowrootmode", "shadowrootdelegatesfocus", "shadowrootclonable", "shadowrootserializable", "shadowrootcustomelementregistry" ]
      },
      "textarea" => {
        description: "Multiline text controls",
        categories: [ "flow", "phrasing", "interactive", "listed", "labelable", "submittable", "resettable", "form-associated", "palpable", "textarea" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "text" ],
        attributes: [ "globals", "autocomplete", "cols", "dirname", "disabled", "form", "maxlength", "minlength", "name", "placeholder", "readonly", "required", "rows", "wrap" ]
      },
      "tfoot" => {
        description: "Group of footer rows in a table",
        categories: [ "tfoot" ],
        parent_categories: [ "table" ],
        children_categories: [ "tr", "script-supporting elements" ],
        attributes: [ "globals" ]
      },
      "th" => {
        description: "Table header cell",
        categories: [ "interactive", "th" ],
        parent_categories: [ "tr" ],
        children_categories: [ "flow" ],
        attributes: [ "globals", "colspan", "rowspan", "headers", "scope", "abbr" ]
      },
      "thead" => {
        description: "Group of heading rows in a table",
        categories: [ "thead" ],
        parent_categories: [ "table" ],
        children_categories: [ "tr", "script-supporting elements" ],
        attributes: [ "globals" ]
      },
      "time" => {
        description: "Machine-readable equivalent of date- or time-related data",
        categories: [ "flow", "phrasing", "palpable", "time" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals", "datetime" ]
      },
      "title" => {
        description: "Document title",
        categories: [ "metadata", "title" ],
        parent_categories: [ "head" ],
        children_categories: [ "text" ],
        attributes: [ "globals" ]
      },
      "tr" => {
        description: "Table row",
        categories: [ "tr" ],
        parent_categories: [ "table", "thead", "tbody", "tfoot" ],
        children_categories: [ "th", "td", "script-supporting elements" ],
        attributes: [ "globals" ]
      },
      "track" => {
        description: "Timed text track",
        categories: [ "track" ],
        parent_categories: [ "audio", "video" ],
        children_categories: [],
        attributes: [ "globals", "default", "kind", "label", "src", "srclang" ]
      },
      "u" => {
        description: "Unarticulated annotation",
        categories: [ "flow", "phrasing", "palpable", "u" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals" ]
      },
      "ul" => {
        description: "List",
        categories: [ "flow", "palpable", "ul" ],
        parent_categories: [ "flow" ],
        children_categories: [ "li", "script-supporting elements" ],
        attributes: [ "globals" ]
      },
      "var" => {
        description: "Variable",
        categories: [ "flow", "phrasing", "palpable", "var" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "phrasing" ],
        attributes: [ "globals" ]
      },
      "video" => {
        description: "Video player",
        categories: [ "flow", "phrasing", "embedded", "interactive", "palpable", "video" ],
        parent_categories: [ "phrasing" ],
        children_categories: [ "source", "track", "transparent" ],
        attributes: [ "globals", "src", "crossorigin", "poster", "preload", "autoplay", "playsinline", "loop", "muted", "controls", "width", "height" ]
      },
      "wbr" => {
        description: "Line breaking opportunity",
        categories: [ "flow", "phrasing", "wbr" ],
        parent_categories: [ "phrasing" ],
        children_categories: [],
        attributes: [ "globals" ]
      },
      "autonomous custom elements" => {
        description: "Author-defined elements",
        categories: [ "flow", "phrasing", "palpable", "autonomous custom elements" ],
        parent_categories: [ "flow", "phrasing" ],
        children_categories: [ "transparent" ],
        attributes: [ "globals" ]
      }
    }
    # READER Operation: Get the global config
    def ask_config
      Builder.new { |cfg, s| BuilderResult.new(result: Success(cfg), next_state: s) }
    end

    # STATE Operation: Get a unique ID and increment counter
    def generate_id
      Builder.new { |cfg, s| BuilderResult.new(result: Success("#{cfg.auto_id_prefix}-#{s}"), next_state: s + 1) }
    end

    def render_html(node, indent = 0)
      spaces = "  " * indent

      if node.is_text
        return "#{spaces}#{node.children.map(&:to_s).join("\n")}"
      end

      # Render Attributes
      attrs = node.attrs
        .map { |k, v| "#{k}=\"#{v}\"" }
        .join(" ").strip
      attr_str = attrs.present? ? " #{attrs}" : ""

      # Void elements (no closing tag)
      void_elements = [ "input", "img", "!DOCTYPE html", "meta" ]
      if void_elements.include?(node.tag_name)
        return "#{spaces}<#{node.tag_name}#{attr_str}>"
      end

      if node.tag_name.nil? # Container tag
        indent = -1
        new_line = ""
      else
        new_line = "\n" # renders children in a new line
      end

      children_str = if node.children.count.positive?
        if node.children.count.eql?(1) && node.children[0].try(:is_text)
          # <footer>
          #  <span>2026 Augmented Engineering UG, Geschäftsführer Julian Vargas</span>
          # </footer>
          render_html(node.children[0], 0) # renders the only child with zero indent
        else
          # <section id="research" class=" theme-dark">
          #  <h2>Research focus</h2>
          # </section>
          new_line + node.children.map { |c| render_html(c, indent + 1) }.join("\n") + "\n" + spaces
        end
      else
        ""
      end

      if node.tag_name.nil?
        "#{children_str}"
      else
        "#{spaces}<#{node.tag_name}#{attr_str}>#{children_str}</#{node.tag_name}>"
      end
    end

    # // Generic Element Creator
    # // 1. Runs children builders
    # // 2. Validates Category rules
    # // 3. Applies 'Reader' theme logic
    def mk_element(tag_name:, attrs:, categories:, allowed_child_categories:, children:, &custom_validation)
      attrs = attrs&.transform_keys(&:to_s) || {}
      children = children || []

      if not children.is_a?(Array)
        children = [ text(children) ]
      end

      children = children.map do |child|
        if child.is_a?(Builder)
          child
        else
          text(child)
        end
      end

      Builder.sequence(builders: children).chain do |children|
        errors = []
        # Validates nesting elements by categories
        if not allowed_child_categories.include?("transparent")
          children.each do |child|
            if !child.is_text && !allowed_child_categories.any? { child.has?(category: it) }
              errors.push("<#{tag_name}> cannot contain <#{child.tag_name}>.")
            end
          end
        end

        # Validates that grand children have compatible categories according to the content model
        children.each do |child|
          child.children do |grand_child|
            if !grand_child.is_text && !allowed_child_categories.any? { grand_child.has?(category: it) }
              errors.push("<#{tag_name}> cannot contain <#{grand_child.tag_name}>.")
            end
          end
        end

        if custom_validation
          custom_error = custom_validation.call(children, attrs)
          if custom_error
            errors.push(custom_error)
          end
        end

        if errors.length > 0
          Builder.fail(errors)
        else
          # C. Reader Logic (Apply Theme)
          ask_config.map do |config|
            if config.theme == "dark" && categories.include?("sectioning")
              attrs["class"] = (attrs["class"] || "") + " theme-dark"
              attrs["class"].strip!
            end
            HtmlNode.new(
              tag_name: tag_name,
              categories: categories,
              children: children,
              attrs: attrs,
              is_text: false
            )
          end
        end
      end
    end

    def process_params(attrs_or_children_or_content_or_nil = nil, *children_or_content_or_nil)
      # process_params( Hash|NilClass, Array) -> [Hash|nil,  Array]

      # When the first param is given, it is the attributes.
      case attrs_or_children_or_content_or_nil
      when Hash
        [ attrs_or_children_or_content_or_nil, children_or_content_or_nil.flatten.compact ] # [{a: 1}, [Foo]]

      # When the first parameter is nil, attrs_or_children_or_content_or_nil
      # contain the children or content.
      when Array # process_params([Foo])
        [ nil, attrs_or_children_or_content_or_nil.flatten.compact ] # [nil, [Foo]]
      when Object # process_params("Hello")
        [ nil, [ attrs_or_children_or_content_or_nil, children_or_content_or_nil ].flatten.compact ] # [nil, ["Hello"]]
      when NilClass # process_params()
        [ nil, [] ] # [nil, []]
      end
    end

    ALL_ELEMENTS.each do |element_name, properties|
      define_method element_name.to_sym do |attrs_or_children_or_content_or_nil = nil, *children_or_content_or_nil|
        attrs, children = process_params(attrs_or_children_or_content_or_nil, children_or_content_or_nil)

        mk_element(
          tag_name: element_name.to_s,
          attrs: attrs,
          categories: properties[:categories],
          allowed_child_categories: properties[:children_categories],
          children: children, &properties[:validation])
      end
    end

    # Text Node
    def text(attrs_or_children_or_content_or_nil = nil, *children_or_content_or_nil)
      attrs, children = process_params(attrs_or_children_or_content_or_nil, children_or_content_or_nil)
      Builder.of(HtmlNode.new(
        tag_name: "#text", categories: [ "phrasing", "text" ],
        children: children, attrs: attrs, is_text: true)
      )
    end

    # INPUT: Uses STATE Monad to generate ID if missing
    def input(attrs_or_children_or_content_or_nil = nil, *children_or_content_or_nil)
      attrs, children = process_params(attrs_or_children_or_content_or_nil, children_or_content_or_nil)

      if !attrs[:type]
        return Builder.fail([ "<input> must have type attribute." ])
      end

      generate_id.chain do |autoId|
        # Logic: If user didn't provide ID, use the auto-generated one from State
        if !attrs[:id]
          attrs[:id] = autoId
        end

        mk_element(
          tag_name: "input",
          attrs: attrs,
          categories: ALL_ELEMENTS["input"][:categories],
          allowed_child_categories: ALL_ELEMENTS["input"][:children_categories],
          children: children,
          &ALL_ELEMENTS["input"][:validation]
        )
      end
    end

    # ROOT Structure
    def doctype
      Builder.of(HtmlNode.new(
        tag_name: "!DOCTYPE html", categories: [ "root" ],
        children: [], attrs: {}, is_text: false
      ))
    end

    def document(doc_type, body)
      Builder.apply(doc_type, body) do |dt, b| # dt:HtmlNode, body:HtmlNode
        if dt.tag_name != "!DOCTYPE html"
          Failure([ "Must start with Doctype" ])
        else
          Success(HtmlNode.new(tag_name: nil, categories: [], children: [ dt, b ], attrs: {}, is_text: false))
        end
      end
    end
  end
end
