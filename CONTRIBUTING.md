# Contributing to Reek

We welcome any and all contributions to Reek!

If what you’re proposing requires significant work discuss it beforehand
as an issue – it’s much easier for us to guide you towards a good
solution and less frustrating for you than doing a lot of work
only to find us suggesting large parts should be rewritten.

Don’t hesitate to offer trivial fixes (spelling, better naming
ideas, etc.) – we’ll let you know if you’re overdoing it. :)



## Reporting Issues

Search [all existing (open _and_ closed)
issues](https://github.com/troessner/reek/issues?q=is%3Aissue)
for a possible previous report; comment there if the issue is not
actually resolved properly or you have any additional information.

Include the steps to reproduce the issue,
the expected outcome and the actual outcome.

Include as much information as possible: the exact Reek
invocation that you use, Reek’s config and version, Ruby
version, Ruby platform (MRI, JRuby, etc.), operating system.

Try to provide a minimal example that reproduces the issue.
Extra kudos if you can write it as a failing test. :)



## Setup and Pull Request Basics

Fork Reek, then clone it, make sure you have
[Bundler](http://bundler.io) installed, install dependencies
and make sure all of the existing tests pass:

```
git clone git@github.com:…username…/reek.git
cd reek
gem install bundler
bundle
bundle exec rake
```

Once you’re sure your copy of Reek works create your own feature branch from our "master" branch:

```
git checkout -b your_feature_or_fix_name
```

Make sure you have read our [style guide](docs/style-guide.md) before you
start contributing.

Then start hacking and add new tests which make sure that your new feature works or
demonstrate that your fix was needed; please also [write good commit
messages](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html).

Once you’re happy with your feature / fix – or want to
share it as a work-in-progress and request comments – once
again make sure all of the tests pass. This will also run
[RuboCop](https://github.com/bbatsov/rubocop) – fix any
offences RuboCop finds (or discuss them in the pull request):

```
bundle exec rake
```

Once your code is ready for review push it to your repository:

```
git push -u origin
```

Then go to your GitHub fork and [make a pull
request](https://help.github.com/articles/creating-a-pull-request/)
to the original repository.

## Review and Fixes

Try to gauge and let us know in the pull request whether what
you propose is a backward-compatible bugfix and should go into the
next patch release, is a backward-compatible feature and should go
into the next minor release, or has to break backward-compatibility
and so needs to wait for the next major release of Reek.

Once your PR is open someone will review it, discuss the details (if
needed) and either merge right away or ask for some further fixes.

GitHub doesn’t have a good way to amend pull requests from external
repositories. In cases where it’s easier to make a direct fix
to your pull request (rather than describing it in the comments)
we’ll either open a separate pull request to the branch in your
repository or ask you to give us commit access to your repository.

If there were any fixes to your pull request we’ll ask you to
[squash](http://git-scm.com/book/en/v2/Git-Tools-Rewriting-History#Squashing-Commits)
all of the commits into one:

```
git rebase -i master
# squash squash squash
git push -f origin
```

## Versioning policy

We are following [semantic versioning](http://semver.org/).

## Breaking changes

If you're working on a change that is breaking backwards-compatibility according to our versioning policy from above just go ahead with your pull request like normal. We'll discuss this then in the pull request and help you to point your pull request to the right branch.
