all: fetch

fetch:
	hg clone https://code.google.com/p/pagedown/
	cd pagedown && rm -rf .hg demo resources README.txt
	perl -pi -e 's/"wmd-input"/"editcontent"/' pagedown/Markdown.Editor.js
	mv makefile pagedown

clean:
	mv makefile ..
	cd .. && rm -rf pagedown

update: clean
	cd .. && ${MAKE} fetch
