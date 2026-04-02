runweb: buildjs
	chromium bin/index.html

runhl: buildhl
	hl ./bin/kriegskunst

runnative: buildc
	./bin/kriegskunst

buildjs:
	haxe compile.hxml

buildhl:
	haxe hl.hxml

buildc:
	haxe native.hxml
	gcc -o ./bin/kriegskunst out/main.c -Iout /usr/local/lib/*.hdll -lhl -lSDL2 -lm -lopenal -lGL -luv

	chmod +x ./bin/kriegskunst

push: buildjs
	zip -r Kriegskunst.zip *
	butler push Kriegskunst.zip nathmate/kriegskunst:HTML
	git push