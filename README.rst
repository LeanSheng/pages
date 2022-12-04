=========================
Sphinx to GitHub Pages V3
=========================

.. image:: https://img.shields.io/github/stars/sphinx-notes/pages.svg?style=social&label=Star&maxAge=2592000
   :target: https://github.com/sphinx-notes/pages

Help you deploying your Sphinx documentation to Github Pages.

Usage
=====

1. `Set the publishing sources to "Github Actions"`__

   .. note:: Publishing your GitHub Pages site with GitHub Actions workflow is **in beta and subject to change**.

   __ https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site#publishing-with-a-custom-github-actions-workflow

2. Create workflow:

   .. code-block:: yaml

      name: Deploy Sphinx documentation to Pages

      # Runs on pushes targeting the default branch
      on:
        push:
          branches: [master]

      jobs:
        pages:
          runs-on: ubuntu-20.04
          environment:
            name: github-pages
            url: ${{ steps.deployment.outputs.page_url }}
          permissions:
            pages: write
            id-token: write
          steps:
          - id: deployment
            uses: sphinx-notes/pages@v3

Inputs
======

======================= ================================ ======== =============================
Input                   Default                          Required Description
----------------------- -------------------------------- -------- -----------------------------
``documentation_path``  ``./docs``                       false    Path to Sphinx source files
``requirements_path``   ``./docs/requirements.txt``      false    Path to to requirements file
``python_version``      ``3.10``                         false    Version of Python
``sphinx_version``      ``5.3``                          false    Version of Sphinx
``cache``               ``false``                        false    Enable cache to speed up
                                                                  documentation building
======================= ================================ ======== =============================

Outputs
=======

======================= ======================================================================
Output                   Description
----------------------- ----------------------------------------------------------------------
``page_url``            URL to deployed GitHub Pages
======================= ======================================================================

Examples
========

The following repository's pages are built by this action:

- https://github.com/SilverRainZ/bullet
- https://github.com/sphinx-notes/pages
- https://github.com/sphinx-notes/any
- https://github.com/sphinx-notes/snippet
- https://github.com/sphinx-notes/lilypond
- https://github.com/sphinx-notes/strike
- ...

You can found the workflow file in their repository.

Tips
====

Copy extra files to site
========================

Use Sphinx confval html_extra_path__.

__ https://www.sphinx-doc.org/en/master/usage/configuration.html#confval-html_extra_path
