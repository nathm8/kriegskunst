clean:
	rm -r bin/ out/

runweb: buildjs
	chromium bin/index.html

runhl: buildhl
	hl ./bin/kriegskunst.hl

runnative: buildc
	./bin/kriegskunst

buildjs:
	haxe compile.hxml

buildhl:
	haxe hl.hxml

buildc:
	haxe native.hxml
	mkdir -p bin
	gcc -o bin/kriegskunst out/main.c -Iout /usr/local/lib/*.hdll -lhl -lSDL2 -lm -lopenal -lGL -luv -w
	chmod +x bin/kriegskunst

push: clean buildjs
	zip -r Kriegskunst.zip *
	butler push Kriegskunst.zip nathmate/kriegskunst:HTML
	git push