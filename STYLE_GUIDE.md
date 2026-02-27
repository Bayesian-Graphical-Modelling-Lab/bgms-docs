# bgms Documentation Style Guide

## Heading Hierarchy

### Title (H1)
- **Never use `# Heading` in `.qmd` files**
- The page title comes from the YAML front matter `title:` field
- This automatically renders as H1 and appears in the browser tab

```yaml
---
title: "Getting Started"
---
```

### Main Sections (H2)
- Use `## Heading` for top-level content sections
- These appear in the right-side Table of Contents (TOC)
- Keep concise: 1-3 words when possible

```markdown
## Installation
## Basic Example
## Understanding the Output
```

### Subsections (H3)
- Use `### Heading` for subsections within H2 sections
- Also appear in TOC (nested under parent H2)
- Use when a section needs logical subdivisions

```markdown
## Installation

### From CRAN

### Development Version
```

### Lower Levels (H4+)
- Use sparingly - consider restructuring if you need H4
- Do not appear in TOC
- Good for: parameter groups, minor distinctions

---

## Page Types

### Index Pages (guide/index.qmd, reference/index.qmd, manual/index.qmd)

**Goal:** Overview/navigation page with minimal TOC

**Structure:**
```yaml
---
title: "User's Guide"
subtitle: "Short description of this section"
---
```

- Use descriptive prose instead of heading-heavy structure
- Link to content pages inline or via bullet lists
- If headings are needed, add `toc: false` to front matter

### Content Pages (tutorials, explanations)

**Structure:**
```markdown
---
title: "Getting Started"
---

Brief introduction paragraph.

## Installation

Explanation...

### From CRAN

```r
install.packages("bgms")
```

### Development Version

```r
remotes::install_github(...)
```

## Basic Example

...
```

### Reference Pages (function documentation)

**Standard sections (in order):**
```markdown
---
title: "bgm"
---

Brief one-line description.

## Description

Detailed explanation of what the function does.

## Usage

```r
bgm(data, ...)
```

## Arguments

| Argument | Description |
|----------|-------------|
| `data`   | A data frame... |

## Value

Description of return value.

## Examples

```r
# Load data
data(Wenchuan)
fit <- bgm(Wenchuan)
```

## See Also

Links to related functions.

## References

Citations if applicable.
```

---

## TOC Behavior

| Scenario | TOC Visible? | Solution |
|----------|--------------|----------|
| Page has H2/H3 headings | Yes | Expected behavior |
| Index page, want no TOC | Add `toc: false` | Clean navigation page |
| Long page with many sections | Yes | Good for navigation |
| Short page (< 3 headings) | Minimal | Consider removing headings |

---

## General Rules

1. **One H2 minimum** for content pages (generates useful TOC)
2. **Consistent naming** across similar pages (all reference pages use same sections)
3. **No orphan headings** - every heading should have content below it
4. **Code comments are not headings** - `# comment` inside code blocks is fine
5. **Cross-reference with IDs** when needed: `## Overview {#overview}`
