Meta = $(HOME)/compile/git/Meta
prefix_base := $(shell $(Meta)/install/prefix)
ifeq ($(prefix_base), detached)
prefix := /do/not/install
else
prefix := $(HOME)/local/git/$(prefix_base)
endif

COMPILER ?= gcc
O = 0
CC = $(COMPILER)
CFLAGS = -g -O$(O)
CFLAGS += -Wall -Werror
CFLAGS += -Wno-format-zero-length
CFLAGS += -Wdeclaration-after-statement
CFLAGS += -Wpointer-arith
CFLAGS += -Wstrict-prototypes
ifeq ($(COMPILER), clang)
CFLAGS += -Qunused-arguments
CFLAGS += -Wno-parentheses-equality
CFLAGS += -Wtautological-constant-out-of-range-compare
else
CFLAGS += -Wold-style-declaration
endif
LDFLAGS = -g

# Relax compilation on a detached HEAD (which is probably
# historical, and may contain compiler warnings that later
# got fixed).
head = $(shell git symbolic-ref HEAD 2>/dev/null)
rebasing = $(shell test -d "`git rev-parse --git-dir`/"rebase-* && echo yes)
strict = $(or $(rebasing), $(head))
ifeq ($(strict),)
  CFLAGS += -Wno-error
endif

USE_LIBPCRE = YesPlease

GIT_TEST_OPTS = --root=/var/ram/git-tests
TEST_LINT = test-lint
GIT_PROVE_OPTS= -j16 --state=slow,save
DEFAULT_TEST_TARGET = prove
export GIT_TEST_HTTPD = Yes
export GIT_TEST_GIT_DAEMON = Yes

GNU_ROFF = Yes
MAN_BOLD_LITERAL = Yes

NO_GETTEXT = Nope
NO_TCLTK = Nope

-include $(Meta)/config/config.mak.local
