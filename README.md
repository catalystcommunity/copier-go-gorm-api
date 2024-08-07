# copier-go-gorm-api

Copier template for a protobuf based golang/gorm api with CI/CD.

## Usage

Install copier: https://copier.readthedocs.io/en/stable/#installation

Execute the copy command and reference this Github repository:
```sh
copier copy https://github.com/catalystcommunity/copier-go-gorm-api ./
```

# Release methods

## semver-tags

The semver-tags release method manages the application helm chart inside the
same Git repository utilizing the [semver-tags](https://github.com/catalystcommunity/semver-tags)
project from Catalystsquad

## semantic-release [deprecated]

The semantic-release release pattern by Catalyst Squad bumps the version of a
helm chart that existed in a different repository, named `chart-{app-name}`.

To make use of this release pattern, create a repository named accordingly with
your helm chart using an alpha branching pattern. The 
[copier-helm-chart-go-app](https://github.com/catalystcommunity/copier-helm-chart-go-app)
copier template can be used to do so.
