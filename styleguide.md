## Markdown and writing style

Generic markdown introduction (if needed):

- https://commonmark.org/help/tutorial/
- https://www.markdownguide.org

Don't add hard line breaks at a certain line-length, enable line-wrapping in your editor instead. Otherwise, searching for sentences in the code becomes a pain.

### Markdown filenames

Place every page into its own subdirectory under `/content/docs/`, and name it `_index.md` (for example, `content/docs/getting-started/deploy-on-whatever/_index.md`).

(Technically, `content/docs/getting-started/deploy-on-whatever.md`, `content/docs/getting-started/deploy-on-whatever/_index.md`, and `content/docs/getting-started/deploy-on-whatever/index.md` are ~90% equivalent, but `_index.md` is the most flexible.)

### Frontmatter

Main frontmatter parameters:

- `title` (cannot include shortcodes)
- `linktitle` (shows up in the left-hand toc)
- `weight` (for page ordering)
    - If a page doesn't have a weight, or multiple pages have the same weight, they are sorted alphabetically
    - If a directory includes subpages/directories and some of which have weights, some don't, then the weighted ones come first, then the ones without weight, alphabetically
- `aliases`: Useful to redirect moved pages. Refers to the relative URL of the old page, not the file path, for example:

    ```yaml
    aliases:
    - /docs/old-page-url/
    ```

- `draft: true` Page is excluded from the production build: you can build it locally, but it doesn't get deployed to the site.

### Headings

- Start with level 2 heading (`##`), (becomes h2, the title in the frontmatter becomes h1)
- Use hashmarks for headings
- Use sentence case (`## Only the first word starts with uppercase`)
- Don't use gerund (`## Install, not installing`)
- Keep titles reasonably short (they show up in the right-hand toc)
- If you use shortcode in the title, for example a parameter, add a custom id as well:

    `## Silly title for version {{< param "latest_operator_version" >}} {#my-custom-id}`

- Do not skip heading levels: the subsection of level 2 heading is level 3, not 4 or 5

### Lists

- Use dash (`-`) for bulleted lists
- Use only `1.` for ordered lists, they are automatically numbered in the output
- Indent additional stuff that belongs to a list element by 4 spaces, for example:

    ```md
    1. Step one

        More text for the same item

        ![Screenshot alt text](screenshot.png)

    1. Next step

        - Nested list

            More text for the nested element
    ```

### Links

- When linking to an external URL, or to a static HTML file within the project, use normal markdown linking: `[text](url)`
- When linking to a file within the docs, use either:
    - `[link text]({{< relref "/docs/path/to/file.md" >}})`, or
    - `{{% xref "/docs/path/to/md/file.md" %}}` (This automatically uses the title for the link text)
    - With both relref/xref you can link to anchors/section titles (like `[link text]({{< relref "/docs/path/to/file.md#anchor" >}})`), but if two pages use xref with anchor to point to each other, the build fails with a timeout (hugo issue)
    - Technically, normal markdown links work within the project, but use xref/relref instead, because those fail if the link is broken.
    - Use project-absolute paths in the links/refs: start with a /, then the path relative to the `content` directory, for example: `/docs/getting-started/_index.md` (easier to update when a file is moved, and easier to recognize where it is pointing, especially if you are linking from a submodule that is used in multiple different projects (and mounted to different locations))
    - When using module mounts, the path must be the mounted path, not the path of the actual file. (We aren't using module mounts in this project, so that's just FYI.)

- html comments and links/xrefs: code (for example, relref shortcode) must be correct and valid even in html comments, otherwise the build fails. For example:
    ```<!-- - [commented link text]({{< relref "this-file-does-not-exist-so-your-build-fails.md" >}}) -->```

    Alternatively, use go template comments to comment the shortcode: `{{/* < relref "this-file-does-not-exist-so-your-build-fails.md" > */}}`

### Images

For full-screen screenshots, use plain markdown syntax, so the labels remain legible: `![alt-text](image.png)`

You can use HTML if needed, but that's usually needed only if you want to adjust the size of the image (typically only needed for not-fullscreen screenshots, like modal dialogue windows that look too big full-size).

Usually, place the image files next to the `_index.md` file where you are using it.

> Note: Hugo doesn't check whether the image path is valid or not.

### Reusable snippets

To reuse a documentation or code snippet:

1. Place it into a separate file under `content/headless`

    You can use subdirectories to organize the snippets.

1. Add an empty frontmatter to the file:

    ```
    ---
    ---
    My text that I want to reuse
    ```

1. Include the snippet with the `{{< include-headless "path/to/file/relative-to-headless" >}}` shortcode.

> Note: Included snippets and numbered steps don't mix well, and usually work only if you are including individual steps, like `1. {{< include-headless "path/to/file/relative-to-headless" >}}`.
> 
> To include multiple steps from a snippet, include them as a nested list:
> 
> ```
> 1. Do this
> 
>     1. {{< include-headless "path/to/file/with-steps.md" >}}
> ```

### Code samples

You can include code samples using the following methods:

- Code within the markdown file: enclose the code between three backticks. Highlighting is automatic if you specify the type of the code, and it's included in the list of highlighters in `static/js/prism.js`
    - For more complicated things like highlighting specific lines, you can also use the [`highlight` shortcode of Hugo](https://gohugo.io/content-management/shortcodes/#highlight).

- Include code from a local file with the `{{< include-code "path/to/code.yaml" "yaml" >}}` shortcode.
- You can include remote files as code using `{{< include-code "https://..." "yaml" >}}`.

> Note: The include-code shortcode doesn't resolve nested shortcodes, so for example `{{< param "latest_version" >}}` doesn't work in external files.

### Notes and warnings

Notes: use markdown blockquotes, start every line with `>`, first line with `> Note:` for example:

```md
> Note: X needs Y to work, because:
>
> - point one
> - point two
```

If the user can do something potentially dangerous (for example, the action can result in data loss), use the warning shortcode:

```go-html-template
{{< warning >}}
Make sure you know what you are doing.
{{< /warning >}}
```

### Other style guides

If needed, you can reference the [Kubernetes](https://kubernetes.io/docs/contribute/style/style-guide/) and [Istio](https://istio.io/latest/docs/releases/contribute/style-guide/) style guides for other generic best practices.

## Hugo basics and project layout

https://acanalis.github.io/post/concepts-of-hugo/

Important directories in a hugo project

- config, content, themes, static, assets, ..., see https://gohugo.io/getting-started/directory-structure/

### Shortcodes

Shortcodes come from three sources:

- [Built-in hugo shortcodes](https://gohugo.io/content-management/shortcodes/#use-hugos-built-in-shortcodes)
- [Shortcodes of the Docsy theme](https://www.docsy.dev/docs/adding-content/shortcodes/)
- Custom shortcodes defined in the layouts/shortcodes directory of this repo

## Customizations

Customizations in Hugo work like this:

- Hugo provides the basic functionality
- The theme (Docsy) provides the first layer of customizations. Some of these can be influenced using config parameters in the `config/_default/config.toml` file.

    For the production deployment, you can override the config parameters of the `config/_default/config.toml` file in the `config/production/config.toml` file. For example, the base url is set here.

- Project-level customizations have the highest priority, and can override both the default hugo and Docsy templates. These are located in the `layout/` directory.

This project has the following main customizations:

- Replaces the default right-hand page level table of contents with a js-based version (using tocbot) to mark the screen location on the page.
- Some custom shortcodes in `layouts/shortcodes/`
- Custom css classes and variables are in `assets/scss/_styles_project.scss` and `assets/scss/_variables_project.scss`
- Customized package for the prism.js code highlighter package to include download button for code snippet files included with the `include-code` shortcode.

## Getting help

With questions about styling, theme customizations, and the Docsy theme in general, [open a discussion on the Docsy GitHub](https://github.com/google/docsy/discussions/).

With Hugo-specific questions, use the [Hugo forum](https://discourse.gohugo.io/).
