## INTRODUCTION

Git-project is just a wrapper to basic git commands to simplify ever day
tasks working with a source code based component model.

At its heart, git-project is just git submodules. That's it.

Git-project wraps complex or multiple commands into easy to use and well
documented single commands that can be used for every day tasks and supports
a robust work flow of short lived topic branches for contributing in small
manageable code changes.

### Components

  Git-project's main purpose is to make it easy to work with a
  `source code based component model`, a.k.a. submodules.

  A component is simply a git submodule. The terminology _component_ comes
  from `component based architecture` principles, where a component is an
  isolated module that is built for reuse.

  Git-project is constructed with the assumption that the same components are
  reused across multiple projects, probably with different configurations, perhaps
  even of different versions, and that the components are distributed using
  source code instead of compiled libraries.

### Git Submodule References

  [Git Docs](http://git-scm.com/docs/git-submodule)
  [Git Book](https://git-scm.com/book/en/v2/Git-Tools-Submodules)

## INSTALLATION

### First Time Installation

  Run:

  $ sudo `make install`

  To learn about the default installation path or how to change the installation
  path, run:

  $ `make help`

### Update

  Once installed, to get the latest version run:

  $ `git project sw-update`

### Check Version

  To check which version is installed, run:

  $ `git project --version`

### License

  `git-project` is released under the [MIT License](http://opensource.org/licenses/mit-license.html).

## DOCUMENTATION

After installation, the documentation is available as man-pages to
_gitproject-userguide_ (this guide) and _git-project_, the top command.

A short usage description is also available by passing the -h flag to the command.

$ `git project -h`

The man pages can in addition to _man git-project(1)_ also be shown using:

$ `git project --help`

All commands has its own usage description and man pages.

$ `git project` &lt;command&gt; -h|--help

## BASIC USE

### List Available Commands

  To list the available commands, run:

  $ `git project --commands`

### Create a Project Repository

  To create a new project repository, create a folder just as you would for
  a standard git repository, but instead of _git init_, run:

  $ `git project init`

  If you want to use a different template than the standard template,
  pass the path to the template repository using:

  $ `git project init --template "PATH-TO-REPO"`

  If the project already has an empty central repository that should be considered its
  origin, it can be assigned directly using

  $ `git project init --origin "PATH-TO-REPO"`

### Clone a Project Repository

  To clone a project repository and have it automatically do all needed configuration
  and download of sub-components, run:

  $ `git project clone "PATH-TO-REPO"`

  git project clone supports the same clone arguments as `git clone`.

### Check Project Status
  To check the status of the entire project repository, run:

  $ `git project status`

### Create a Branch

  To create a branch in the project repository and all its components, run:

  $ `git project branch`

## WORKFLOW

TODO

## THE GITS OF IT ALL

TODO

## CONTRIBUTERS
Git project uses code and components of other Open Source Projects.

  [Git Extras](https://github.com/tj/git-extras)

  [Git Hooks](https://github.com/icefox/git-hooks)

  [Ronn](https://github.com/rtomayko/ronn)

  [Sharness](https://github.com/mlafeldt/sharness)
