# /*─────────────────────────────────────────────────────────────────╗
# │ To the extent possible under law, Jared Miller has waived        │
# │ all copyright and related or neighboring rights to this file,    │
# │ as it is written in the following disclaimers:                   │
# │   • http://unlicense.org/                                        │
# ╚─────────────────────────────────────────────────────────────────*/
.PHONY: all clean format test

PROJECT=zipfile-explorer.com
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
