git-project-clone(1) -- Clone a project repository
==================================================

## SYNOPSIS

`git-project-clone` [-h,--help] [&lt;OPTIONS&gt;]

## DESCRIPTION

Clones the project repository and performs needed initialization.

## OPTIONS

  * -h:
    Print short usage description and exit

  * --help:
    Show this man page and exit

  git-project-clone supports the same options as _git clone_.

## DETAILS

git-project-clone performs:

  * git clone --recursive-submodules REPO [DIR]
