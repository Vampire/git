#include "cache.h"
#include "dir.h"
#include "revision.h"
#include "builtin.h"
#include "parse-options.h"
#include "pack-bitmap.h"

static const char * const ahead_behind_usage[] = {
	N_("git ahead-behind [--base=branch] [other...]"),
	NULL
};

static struct object_array_entry *find_pending(struct object_array *array,
					       int flags,
					       int mask)
{
	int i;
	for (i = 0; i < array->nr; i++) {
		struct object_array_entry *ent = array->objects + i;
		if ((ent->item->flags & mask) == flags)
			return ent;
	}
	return NULL;
}

int cmd_ahead_behind(int argc, const char **argv, const char *prefix)
{
	struct commit *default_base = NULL;
	const char *base_ref = "HEAD";
	struct option ahead_behind_opts[] = {
		OPT_STRING('b', "base", &base_ref, N_("base"), N_("base reference to process")),
		OPT_END()
	};

	struct rev_info revs;
	struct strbuf line = STRBUF_INIT;

	argc = parse_options(argc, argv, NULL, ahead_behind_opts,
			     ahead_behind_usage, 0);

	init_revisions(&revs, NULL);

	while (strbuf_getline(&line, stdin) != EOF) {
		struct object_array_entry *tip_ent, *base_ent;
		struct commit *tip, *base;
		int ahead, behind;

		if (!line.len)
			break;

		if (handle_revision_arg(line.buf, &revs, 0, REVARG_CANNOT_BE_FILENAME))
			die("bad revision '%s'", line.buf);

		base_ent = find_pending(&revs.pending, UNINTERESTING, UNINTERESTING);
		if (base_ent)
			base = lookup_commit_reference(base_ent->item->oid.hash);
		else if (default_base)
			base = default_base;
		else
			base = default_base = lookup_commit_reference_by_name(base_ref);
		if (!base)
			return 1;

		tip_ent = find_pending(&revs.pending, 0, UNINTERESTING);
		if (!tip_ent)
			die("not an interesting ref: %s", line.buf);
		tip = lookup_commit_reference(tip_ent->item->oid.hash);
		if (!tip)
			return 1;

		revision_ahead_behind(tip, base, &ahead, &behind);
		printf("%s %d %d\n", tip_ent->name, ahead, behind);

		object_array_clear(&revs.pending);
	}
	strbuf_release(&line);

	return 0;
}
