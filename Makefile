# redbean-zipfile
#
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
#
# You should have received a copy of the CC0 Public Domain Dedication along
# with this software. If not, see
# <http://creativecommons.org/publicdomain/zero/1.0/>.

.PHONY: all clean format test

PROJECT=redbean-zipfile.com
REDBEAN_DL=https://redbean.dev/redbean-2.0.17.com

all: add

format:
	npx -p prettier -p git+https://github.com/prettier/plugin-lua.git prettier . --write

${PROJECT}.template:
	curl -Rs ${REDBEAN_DL} -o $@ && chmod +x ${@}

add: ${PROJECT}.template
	cp -f ${PROJECT}.template ${PROJECT}
	zip -d ${PROJECT} 'usr/share/zoneinfo/*'
	cd srv/ && zip -r ../${PROJECT} '.'
	zipinfo ${PROJECT}

start: ${PROJECT}
	./${PROJECT} -vvmbag

clean:
	rm -f ${PROJECT} ${PROJECT}.template
