# GIT PROJECT
#
# Add DRYRUN=echo to echoing some of the commands instead of performing them.
# It does not always have the intended effect, so use with care and only during
# trouble shooting.
#
# Set KEEP_BUILD_FILES=y to have intermediate bash files not deleted from build
# directory.
#
# Set NO_DELETE_ON_ERROR=y to prevent target files from being deleted on target
# error. 
#
# All known variables can be printed
# $ make debug-print-VARNAME
#
# Or just their values
# $ make debug-print-value-VARNAME
#
# and checked if they are defined
# $ make debug-is-def-VARNAME
# 
# and their origin printed
# $ make debug-origin-VARNAME
#
.PHONY: help
help:
	@echo ""
	@echo "  Usage: make <TARGET> [VERBOSE=v]"
	@echo ""
	@echo "    help         Print this help"
	@echo ""
	@echo "    readme       View the README in console"
	@echo "                 After installation, the readme is also available as"
	@echo "                 the man page for 'gitproject-userguide'."
	@echo ""
	@echo "    readme-html  View the README in browser"
	@echo ""
	@echo "    install      Install git-project on system"
	@echo "                 defaults to $(DESTDIR)$(PREFIX)"
	@echo ""
	@echo "    uninstall    Uninstall git-project from system"
	@echo "                 defaults to $(DESTDIR)$(PREFIX)"
	@echo "                 Uninstall will not delete directories created during"
	@echo "                 installation, even if they are empty."
	@echo ""
	@echo "                 Root destination directory, (default=$(DESTDIR)),"
	@echo "                 can be overridden with DESTDIR=."
	@echo "                 Prefix, (default=$(PREFIX)), can be overriden"
	@echo "                 with PREFIX=."
	@echo "                 Bash completion prefix, (default=$(COMPLETIONPREFIX)),"
	@echo "                 can be overriden with COMPLETIONPREFIX=."
	@echo "                 Path to HTML based documentation, (default=$(HTMLPREFIX)), "
	@echo "                 can be overriden with HTMLPREFIX=."
	@echo ""
	@echo "                 Files that will be installed:"                 
	@echo "                  * scripts from bin directory:"
	@echo "                      to: $(BINDEST)"
	@echo "                  * man pages from man directory:"
	@echo "                      to: $(MANDEST1), $(MANDEST7)"
	@echo "                  * html-man pages from man directory:"
	@echo "                      to: $(HTMLDEST)"
	@echo "                  * bash-completion script"
	@echo "                      to: $(COMPLETIONDEST)"
	@echo ""
	@echo "                 Depending on destination directory, install/uninstall"
	@echo "                 may require sudo."
	@echo "                 By default, the installation affects git system configuration."
	@echo "                 This can be overriden by GITCONFIG=--global."
	@echo ""
	@echo "                 The installation parameters is saved with other git-project"
	@echo "                 parameters in git-config. To reuse the existing config for"
	@echo "                 install/uninstall add the argument FROM_CONFIG=y."
	@echo "                 The value of GITCONFIG will decide witch config to read from."
	@echo ""
	@echo "                 To check the effects of setting different path options,"
	@echo "                 run make help with the options active and the list"
	@echo "                 of paths above will take that into account."
	@echo "                 Only use alternative paths if you know what you are doing."
	@echo ""
	@echo "    dev-help     Print extended developer help"
	@echo ""   

.PHONY: dev-help
dev-help:
	@echo "  !! Only for tool developers, not needed for regular use !!"
	@echo ""
	@echo "  Usage: make <TARGET> "
	@echo "              [VERBOSE=v] [KEEP_BUILD_FILES=y]"
	@echo "              [NO_DELETE_ON_ERROR=y] [DRYRUN=echo]"
	@echo ""
	@echo "    dev-help     Print this help"
	@echo ""
	@echo "    clean        Delete all artifacts"
	@echo ""
	@echo "    docs         Generate documentation"
	@echo "                 man pages and HTML files end up in the man-director"
	@echo ""
	@echo "    docclean     Delete documentation artifacts"
	@echo "                 deletes man pages and HTML files from man-directory"
	@echo ""
	@echo "    dev-install  Installs the tools needed for development."
	@echo ""
	@echo "    dev-uninstall"
	@echo "                 Uninstalls the tools needed for development."
	@echo ""
	@echo "    dev-readme   View the developer guide in console"
	@echo "                 After installation, the guide is also available as"
	@echo "                 the man page for 'gitproject-devguide'."
	@echo ""
	@echo "    dev-readme-html"
	@echo "                 View the developer guide in browser"
	@echo ""
	@echo "    check        Run tests. TEST_OPTS=<OPTIONS>, SYSTEM_TEST=y, TEST_FILTER=<pattern>"
	@echo ""
	@echo "    prove        Run tests using prove."
	@echo "                 PROVE_OPTS=<OPTIONS>, TEST_OPTS=<OPTIONS>, SYSTEM_TEST=y, TEST_FILTER=<pattern>"
	@echo ""
	@echo "                 If SYSTEM_TEST is defined, it will run the tests using"
	@echo "                 the system installation of git-project."
	@echo ""
	@echo "    before-commit"
	@echo "                 Run before committing. Runs check and prove with reasonable settings."
	@echo ""
	@echo "    debug-print-VARIABLE"
	@echo "                 Print variable: name=value"
	@echo ""
	@echo "    debug-print-value-VARIABLE"
	@echo "                 Print variable: value"
	@echo ""
	@echo "    debug-is-def-VARIABLE"
	@echo "                 Returns with error if not defined"
	@echo ""      
	@echo "    debug-origin-VARIABLE"
	@echo "                 Print the variable's origin"
	@echo ""
	
ifndef NO_DELETE_ON_ERROR
.DELETE_ON_ERROR:
endif

# Constants
MANDIR := man
BINDIR := bin
TOOLSDIR := tools
LIBDIR := lib
ETCDIR := etc
BUILDDIR := build
TESTDIR := test

# Optionals saved in config
ifdef FROM_CONFIG
	DESTDIR ?= $(shell git config $(GITCONFIG) project.install.destdir)
	PREFIX ?= $(shell git config $(GITCONFIG) project.install.prefix)
	HTMLPREFIX ?= $(shell git config $(GITCONFIG) project.install.htmlprefix)
	COMPLETIONPREFIX ?= $(shell git config $(GITCONFIG) project.install.completionprefix)
else
	DESTDIR ?=
	PREFIX ?= /usr
	HTMLPREFIX ?= $(shell git --html-path)
	COMPLETIONPREFIX ?= /etc/bash_completion.d
endif


# Unoffical Optionals
MANTOOL ?= man
DRYRUN ?=
GITCONFIG ?=--system

# Destination directories
BINDEST := $(DESTDIR)$(PREFIX)/bin
MANDEST := $(DESTDIR)$(PREFIX)/share/man
MANDEST1 := $(MANDEST)/man1
MANDEST7 := $(MANDEST)/man7
HTMLDEST := $(DESTDIR)$(HTMLPREFIX)
COMPLETIONDEST := $(DESTDIR)$(COMPLETIONPREFIX)

# Variables
BINS := $(wildcard $(BINDIR)/git-*)
COMMANDS := $(subst $(BINDIR)/,,$(BINS))
GUIDES := $(wildcard $(MANDIR)/gitproject*.md)
#Note, gitproject-userguide.md is never created, it is just added here for greating other variables
GUIDES += $(MANDIR)/gitproject-userguide.md
INSTALLS := $(addprefix install.,$(COMMANDS))
INSTALLS += $(addprefix install.,$(notdir $(basename $(GUIDES))))
INSTALLS += install.bash_completion install.config
UNINSTALLS := $(addprefix uninstall.,$(COMMANDS))
UNINSTALLS += $(addprefix uninstall.,$(notdir $(basename $(GUIDES))))
UNINSTALLS += uninstall.bash_completion uninstall.config
MANS := $(wildcard $(MANDIR)/git-*.md)
MAN_PAGES := $(MANS:.md=.1)
MAN_HTMLS := $(MANS:.md=.html)
GUIDE_PAGES := $(GUIDES:.md=.7)
GUIDE_HTMLS :=$(GUIDES:.md=.html)
TOOLS := $(notdir $(filter-out %.install,$(wildcard $(TOOLSDIR)/*)))
TOOL_INSTALLS := $(addprefix install.tool.,$(notdir $(basename $(wildcard $(TOOLSDIR)/*.install))))

LIBS := $(notdir $(wildcard $(LIBDIR)/*))

Q=@
ifdef VERBOSE
	Q=
endif

# Targets

.PHONY: docs
docs: $(MAN_PAGES) $(MAN_HTMLS) $(GUIDE_PAGES) $(GUIDE_HTMLS)

.PHONY: install
install: $(INSTALLS)
	$(Q)$(DRYRUN) git project --version

.PHONY: uninstall
uninstall: $(UNINSTALLS)

.PHONY:clean
clean: docclean testclean
	$(Q)rm -rf $(BUILDDIR)

.PHONY: docclean
docclean:
	$(Q)rm -f $(MANDIR)/*.1
	$(Q)rm -f $(MANDIR)/*.7
	$(Q)rm -f $(MANDIR)/*.html

.PHONY: readme
readme: 
	$(Q)$(MANTOOL) $(MANDIR)/gitproject-userguide.7

.PHONY: readme-html
readme-html:
	$(Q)xdg-open $(MANDIR)/gitproject-userguide.html

.PHONY: dev-readme
dev-readme: 
	$(Q)$(MANTOOL) $(MANDIR)/gitproject-devguide.7

.PHONY: dev-readme-html
dev-readme-html:
	$(Q)xdg-open $(MANDIR)/gitproject-devguide.html


## git-project user guide (generated from README.md)
$(MANDIR)/gitproject-userguide.7: $(MANDIR)/readme-header.md $(MANDIR)/readme-toc.md README.md $(MANDIR)/footer.md
	@cat $^ |$(TOOLSDIR)/ronn --roff --manual "Git Project User Guide" --pipe > $@
		
$(MANDIR)/gitproject-userguide.html: $(MANDIR)/readme-header.md README.md $(MANDIR)/hr.md $(MANDIR)/footer.md
	@cat $^ |$(TOOLSDIR)/ronn --html --manual "Git Project User Guide" --style=toc --pipe > $@

## bash completion

.PHONY: install.bash_completion
install.bash_completion: $(ETCDIR)/bash_completion.sh | $(COMPLETIONDEST)
	$(Q)$(DRYRUN) cp -f $< $(COMPLETIONDEST)/git-project
	@echo "Installed bash completion"

.PHONY: uninstall.bash_completion
uninstall.bash_completion:
	$(Q)$(DRYRUN) rm  -f $(COMPLETIONDEST)/git-project
	@echo "Uninstalled bash completion"


## git-project config

.PHONY: install.config
install.config:
	$(Q)$(DRYRUN) git config $(GITCONFIG) project.update-repo `git config --file config/.gitproject project.update-repo`
	$(Q)$(DRYRUN) git config $(GITCONFIG) project.template `git config --file config/.gitproject project.template`
	$(Q)$(DRYRUN) git config $(GITCONFIG) project.install.destdir "$(DESTDIR)"
	$(Q)$(DRYRUN) git config $(GITCONFIG) project.install.prefix "$(PREFIX)"
	$(Q)$(DRYRUN) git config $(GITCONFIG) project.install.htmlprefix "$(HTMLPREFIX)"
	$(Q)$(DRYRUN) git config $(GITCONFIG) project.install.completionprefix "$(COMPLETIONPREFIX)"
	$(Q)$(DRYRUN) git config $(GITCONFIG) project.install.bin "$(BINDEST)"
	$(Q)$(DRYRUN) git config $(GITCONFIG) project.install.man "$(MANDEST)"
	$(Q)$(DRYRUN) git config $(GITCONFIG) project.install.html "$(HTMLDEST)"
	$(Q)$(DRYRUN) git config $(GITCONFIG) project.install.completion "$(COMPLETIONDEST)"
	@echo "Installed configuration"

.PHONY: uninstall.config	
uninstall.config:
	$(Q)$(DRYRUN) git config $(GITCONFIG) --remove-section project > /dev/null 2>&1 || true
	$(Q)$(DRYRUN) git config $(GITCONFIG) --remove-section project.install > /dev/null 2>&1 || true
	@echo "Uninstalled configuration"


## dev install
.PHONY: dev-install
dev-install: $(TOOL_INSTALLS)

.PHONY: dev-uninstall
dev-uninstall:
	$(Q)git config --global --remove-section project.dev > /dev/null 2>&1 || true
	@echo "Please remove the tools installed manually:"
	@echo "$(notdir $(basename $(wildcard $(TOOLSDIR)/*.install)))"
	
	
## test
.PHONY: check
check: test-prepare
	$(Q)cd $(TESTDIR) && $(MAKE) --no-print-directory test \
		TEST_OPTS="$(TEST_OPTS)" \
		SYSTEM_TEST=$(SYSTEM_TEST)

.PHONY: prove
prove: test-prepare
	$(Q)cd $(TESTDIR) && $(MAKE) --no-print-directory prove \
		PROVE_OPTS="$(PROVE_OPTS)" \
		TEST_OPTS="$(TEST_OPTS)" \
		SYSTEM_TEST=$(SYSTEM_TEST)

.PHONY: before-commit
before-commit:
	$(Q)$(MAKE) --no-print-directory clean
	$(Q)$(MAKE) --no-print-directory docs
	$(Q)$(MAKE) --no-print-directory check
	$(Q)$(MAKE) --no-print-directory prove PROVE_OPTS="-j8"

### Prepare for test
# Since we are doing concurent testing, and each test case does a 
# make install, we need to ensure that everything is pre-generated not to
# have half-finished generated artifacts interfere.
.PHONY: test-prepare
test-prepare: docs $(addprefix $(BUILDDIR)/,$(COMMANDS))

.PHONY: testclean
testclean:
	$(Q)cd $(TESTDIR) && $(MAKE) --no-print-directory clean

## Directories
$(BUILDDIR) $(BINDEST) $(MANDEST1) $(MANDEST7) $(HTMLDEST) $(COMPLETIONDEST):
	$(Q)mkdir -p $@


# Rules

## Artifact creation

### Generate bash script with library expanded/included
ifdef KEEP_BUILD_FILES
.PRECIOUS: $(BUILDDIR)/git-%
endif
$(BUILDDIR)/git-%: $(BINDIR)/git-% $(addprefix $(LIBDIR)/, $(LIBS))| $(BUILDDIR)
	$(Q)cp -f $< $@
	$(Q)$(foreach lib,$(LIBS),sed -i -e "/\#\#$(lib)\#\#/r $(LIBDIR)/$(lib)" -e "/\#\#$(lib)\#\#/d" $@;)
	$(Q)sync
	
### Project command documentation

$(MANDIR)/git-project%.1: $(MANDIR)/git-project%.md $(MANDIR)/footer.md
	$(Q)cat $^ | $(TOOLSDIR)/ronn \
		--manual "Git Project" \
		--roff \
		--pipe > $@

$(MANDIR)/git-project%.html: $(MANDIR)/git-project%.md $(MANDIR)/hr.md $(MANDIR)/footer.md
	$(Q)cat $^ | $(TOOLSDIR)/ronn \
		--manual "Git Project" \
		--html --style=toc \
		--pipe > $@

### Project guides

$(MANDIR)/gitproject-%.7: $(MANDIR)/gitproject-%.md $(MANDIR)/footer.md
	$(Q)cat $^ | $(TOOLSDIR)/ronn \
		--manual "Git Project" \
		--roff \
		--pipe > $@

$(MANDIR)/gitproject-%.html: $(MANDIR)/gitproject-%.md $(MANDIR)/hr.md $(MANDIR)/footer.md
	$(Q)cat $^ | $(TOOLSDIR)/ronn \
		--manual "Git Project" \
		--html --style=toc \
		--pipe > $@

### Non-project command documentation, should not have project footer 

$(MANDIR)/git-%.1: $(MANDIR)/git-%.md
	$(Q)cat $^ | $(TOOLSDIR)/ronn \
		--manual "Git $*" \
		--roff \
		--pipe > $@

$(MANDIR)/git-%.html: $(MANDIR)/git-%.md
	$(Q)cat $^ | $(TOOLSDIR)/ronn \
		--manual "Git $*" \
		--html --style=toc \
		--pipe > $@


## Install rules

### Commands
.PHONY: install.git-%
install.git-%: git-%.command.install git-%.1.install git-%.html.install
	@echo "installed git-$*"

### Guides
.PHONY: install.gitproject-%
install.gitproject-%: gitproject-%.7.install gitproject-%.html.install
	@echo "installed guide $* (gitproject-$*)"

### Default
.PHONY: install.%
install.%: %.1.install %.html.install
	@echo "Installed $*"

.PHONY: git-%.command.install
git-%.command.install: $(BUILDDIR)/git-% | $(BINDEST)
	$(Q)$(DRYRUN) cp -f $< $(BINDEST)/$(notdir $<)

.PHONY: git%.1.install
git%.1.install: | $(MANDEST1)
	$(Q)$(DRYRUN) cp -f $(MANDIR)/git$*.1 $(MANDEST1)/git$*.1

.PHONY: git%.7.install
git%.7.install: | $(MANDEST7)
	$(Q)$(DRYRUN) cp -f $(MANDIR)/git$*.7 $(MANDEST7)/git$*.7

.PHONY: git%.html.install
git%.html.install: | $(HTMLDEST)
	$(Q)$(DRYRUN) cp -f $(MANDIR)/git$*.html $(HTMLDEST)/git$*.html


## Uninstall rules

### Commands
.PHONY: uninstall.git-% 
uninstall.git-%: git-%.command.uninstall git-%.1.uninstall git-%.html.uninstall
	@echo "uninstalled git-$*"

### Guides
.PHONY: uninstall.gitproject-%
uninstall.gitproject-%: gitproject-%.7.uninstall gitproject-%.html.uninstall
	@echo "uninstalled guide $* (gitproject-$*)"

### Default
.PHONY: uninstall.%
uninstall.%: %.1.uninstall %.html.uninstall
	@echo "uninstalled $*"

.PHONY: git-%.command.uninstall
git-%.command.uninstall:
	$(Q)$(DRYRUN) rm -f $(BINDEST)/git-$*

.PHONY: git%.1.uninstall
git%.1.uninstall:
	$(Q)$(DRYRUN) rm -f $(MANDEST1)/git$*.1

.PHONY: git%.7.uninstall
git%.7.uninstall:
	$(Q)$(DRYRUN) rm -f $(MANDEST7)/git$*.7

.PHONY: git%.html.uninstall
git%.html.uninstall:
	$(Q)$(DRYRUN) rm -f $(HTMLDEST)/git$*.html


## Install tools

.PHONY: install.tool.%
install.tool.%: $(TOOLSDIR)/%.install
	@echo "Installing tool $*"
	$(Q)$(DRYRUN) $<


# Debug targets

.PHONY: debug-print-value-%
debug-print-value-%:
	@echo "$($*)"

.PHONY: debug-print-%
debug-print-%:
	@echo "$*=$($*)"

.PHONY: debug-is-def-%
debug-is-def-%:
ifdef $*
	@true
else
	@false
endif

.PHONY: debug-origin-%
debug-origin-%:
	@echo $(origin $*)
