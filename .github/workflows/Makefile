.DELETE_ON_ERROR:
.PHONY: all default clean

all default: ci.yml

%: %.m4 defs.m4
	@set -e; \
	trap 'rm -f $@.tmp' EXIT; \
	chmod -f +w $@ || true; \
	m4 $< > $@; \
	cat -s $@ > $@.tmp; \
	sed '/[^[:blank:]]/,$$!d' $@.tmp > $@; \
	sed -e :a -e '/^[[:space:]]*$$/{$$d;N;ba' -e '}' $@ > $@.tmp; \
	mv -f $@.tmp $@; \
	chmod -w $@

clean:
	rm -f ci.yml
