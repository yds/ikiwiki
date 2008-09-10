#!/bin/sh 
rm -rf test-src test-repo.git /tmp/postal-test
cp -ar in test-src

ikiwiki-makerepo git test-src test-repo.git
ikiwiki --rebuild --setup test.setup
perl ../filters/postal-accept.pl -c test.setup < test1.eml
perl ../filters/postal-accept.pl -c test.setup < test2.eml
perl ../filters/postal-accept.pl -c test.setup < test3.eml
#ikiwiki --setup test.setup --refresh
