Meta = $(HOME)/compile/git/Meta
prefix := $(HOME)/local/git/$(shell $(Meta)/install/prefix)

CC = ccache gcc
O = 0
CFLAGS = -g -O$(O) -Wall -Werror
LDFLAGS = -g

# Relax compilation on a detached HEAD (which is probably
# historical, and may contain compiler warnings that later
# got fixed).
head = $(shell git symbolic-ref HEAD 2>/dev/null)
rebasing = $(shell test -d "`git rev-parse --git-dir`/"rebase-* && echo yes)
strict_compilation = $(or $(rebasing), $(head))
ifeq ($(strict_compilation),)
  CFLAGS += -Wno-error
endif

USE_LIBPCRE = YesPlease

GIT_TEST_OPTS = --root=/run/shm/git-tests
TEST_LINT = test-lint
GIT_PROVE_OPTS= -j16 --state=hot,all,save
DEFAULT_TEST_TARGET = prove
export GIT_TEST_HTTPD = Yes

GNU_ROFF = Yes
MAN_BOLD_LITERAL = Yes
