# copier-go-cobra-app

Copier template for a golang cobra app with CI/CD.

## Usage

Install copier: https://copier.readthedocs.io/en/stable/#installation

Execute the copy command and reference this Github repository:
```sh
copier copy https://github.com/catalystsquad/copier-go-cobra-app ./
```

# Release methods

## semver-tags

The semver-tags release method manages the application helm chart inside the
same Git repository utilizing the [semver-tags](https://github.com/catalystsquad/semver-tags)
project from Catalystsquad

## semantic-release [deprecated]

The semantic-release release pattern by Catalyst Squad bumps the version of a
helm chart that existed in a different repository, named `chart-{app-name}`.

To make use of this release pattern, create a repository named accordingly with
your helm chart using an alpha branching pattern. The 
[copier-helm-chart-go-app](https://github.com/catalystsquad/copier-helm-chart-go-app)
copier template can be used to do so.
