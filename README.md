# bgms Documentation

Documentation site for the [bgms](https://github.com/Bayesian-Graphical-Modelling-Lab/bgms) R package.

## Structure

- `guide/` — User's Guide (tutorials, statistical concepts)
- `reference/` — Function reference (API documentation)
- `manual/` — Reference Manual (C++ backend, algorithms)

## Building Locally

Requires [Quarto](https://quarto.org/docs/get-started/).

```bash
# Preview with live reload
quarto preview

# Build static site
quarto render
```

Output goes to `docs/`.

## Contributing

1. Edit `.qmd` files in the appropriate directory
2. Preview locally with `quarto preview`
3. Commit and push — GitHub Actions will deploy automatically

## License

CC BY 4.0
