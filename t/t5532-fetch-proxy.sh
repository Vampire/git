#!/bin/sh

test_description='fetching via git:// using core.gitproxy'
. ./test-lib.sh

test_expect_success 'setup remote repo' '
	git init remote &&
	(cd remote &&
	 echo content >file &&
	 git add file &&
	 git commit -m one
	)
'

test_expect_success 'setup proxy script' '
	write_script proxy-get-cmd "$PERL_PATH" <<-\EOF &&
	sysread(STDIN, $buf, 4);
	my $n = hex($buf) - 4;
	sysread(STDIN, $buf, $n);
	my ($cmd, $other) = split /\0/, $buf;
	# drop absolute-path on repo name
	$cmd =~ s{ /}{ };
	print $cmd;
	EOF

	write_script proxy <<-\EOF
	echo >&2 "proxying for $*"
	cmd=$(./proxy-get-cmd)
	echo >&2 "Running $cmd"
	exec $cmd
	EOF
'

test_expect_success 'setup local repo' '
	git remote add fake git://example.com/remote &&
	git config core.gitproxy ./proxy
'

test_expect_success 'fetch through proxy works' '
	git fetch fake &&
	echo one >expect &&
	git log -1 --format=%s FETCH_HEAD >actual &&
	test_cmp expect actual
'

test_done
