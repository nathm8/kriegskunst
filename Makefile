run: build
	chromium index.html

build:
	haxe compile.hxml

push: build
	zip -r Kriegskunst.zip *
	butler push Kriegskunst.zip nathmate/kriegskunst:HTML
	git push