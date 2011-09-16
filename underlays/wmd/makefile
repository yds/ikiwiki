all: fetch

fetch:
	ftp ftp://ftp.NetBSD.org/pub/NetBSD/packages/distfiles/wmd-1.0.1.zip
	unzip wmd-1.0.1.zip '*/wmd/*'
	mv wmd-1.0.1/wmd wmd
	rm -rf wmd-1.0.1*
	mv makefile wmd

clean:
	mv makefile ..
	cd .. && rm -rf wmd

update: clean
	cd .. && ${MAKE} fetch
