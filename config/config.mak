Meta = $(HOME)/compile/git/Meta
prefix := $(HOME)/local/git/$(shell $(Meta)/install/prefix)

CC = ccache gcc
CFLAGS = -g -Wall -Werror
LDFLAGS = -g

GIT_TEST_OPTS = --root=/dev/shm/git-tests
TEST_LINT = test-lint
GIT_PROVE_OPTS= -j16 --state=hot,all,save
DEFAULT_TEST_TARGET = prove

GNU_ROFF = Yes
MAN_BOLD_LITERAL = Yes
