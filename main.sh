#!/bin/bash

# set -x
set -e

repo_dir=$GITHUB_WORKSPACE/$INPUT_REPOSITORY_PATH
doc_dir=$repo_dir/$INPUT_DOCUMENTATION_PATH

echo ::group:: Initialize various paths
echo Workspace: $GITHUB_WORKSPACE
echo Repository: $repo_dir
echo Documentation: $doc_dir
echo ::endgroup::

# The actions doesn't depends on any images,
# so we have to try various package manager.
echo ::group:: Installing Sphinx

echo Installing sphinx via pip
if [ -z "$INPUT_SPHINX_VERSION" ] ; then
    pip3 install -U sphinx
else
    pip3 install -U sphinx==$INPUT_SPHINX_VERSION
fi

echo Adding user bin to system path
PATH=$HOME/.local/bin:$PATH
if ! command -v sphinx-build &>/dev/null; then
    echo Sphinx is not successfully installed
    exit 1
else
    echo Everything goes well
fi

echo ::endgroup::

if [ ! -z "$INPUT_REQUIREMENTS_PATH" ] ; then
    echo ::group:: Installing requirements
    if [ -f "$repo_dir/$INPUT_REQUIREMENTS_PATH" ]; then
        echo Installing python requirements
        pip3 install -r "$repo_dir/$INPUT_REQUIREMENTS_PATH"
    else
        echo No requirements.txt found, skipped
    fi
    echo ::endgroup::
fi

# Sphinx HTML builder will rebuild the whole project when modification time
 # (mtime) of templates of theme newer than built result. [1]
#
# These theme templates vendored in pip packages are newly installed,
# so their mtime always newr than the built result.
# Set mtime to 1990 to make sure the project won't rebuilt.
#
# .. [1] https://github.com/sphinx-doc/sphinx/blob/5.x/sphinx/builders/html/__init__.py#L417
echo ::group:: Fixing timestamp of HTML theme 
site_packages_dir=$(python -c 'import site; print(site.getsitepackages()[0])')
echo Python site-packages directory: $site_packages_dir
for i in $(find $site_packages_dir -name '*.html'); do
    touch -m -t 190001010000 $i
    echo Fixing timestamp of $i
done
echo ::endgroup::

echo ::group:: Creating build directory
build_dir=/tmp/sphinxnotes-pages
mkdir -p $build_dir || true
echo Temp directory \"$build_dir\" is created

echo ::group:: Running Sphinx builder
if ! sphinx-build -b html "$doc_dir" "$build_dir"; then
    echo ::endgroup::
    echo ::group:: Dumping Sphinx error log 
    for l in $(ls /tmp/sphinx-err*); do
        cat $l
    done
    exit 1
fi
echo ::endgroup::

echo ::group:: Setting up git repository
echo Setting up git configure
cd $repo_dir
git config --local user.email "action@github.com"
git config --local user.name "GitHub Action"
git stash
echo Setting up branch $INPUT_TARGET_BRANCH
branch_exist=$(git ls-remote --heads origin refs/heads/$INPUT_TARGET_BRANCH)
if [ -z "$branch_exist" ]; then
    echo Branch doesn\'t exist, create an empty branch
    git checkout --force --orphan $INPUT_TARGET_BRANCH
else
    echo Branch exists, checkout to it
    git checkout --force $INPUT_TARGET_BRANCH
fi
git clean -fd
echo ::endgroup::

echo ::group:: Committing HTML documentation
cd $repo_dir
echo Deleting all file in repository
rm -vrf * # TODO: Keep CNAME
echo Copying HTML documentation to repository
cp -vr $build_dir/. $INPUT_TARGET_PATH
# Remove unused doctree
rm -rf $INPUT_TARGET_PATH/.doctrees
if [ ! -f "$INPUT_TARGET_PATH/.nojekyll" ]; then
    # See also sphinxnotes/pages#7
    echo Creating .nojekyll file
    touch "$INPUT_TARGET_PATH/.nojekyll"
fi
echo Adding HTML documentation to repository index
git add $INPUT_TARGET_PATH
echo Recording changes to repository
git commit --allow-empty -m "Add changes for $GITHUB_SHA"
echo ::endgroup::
