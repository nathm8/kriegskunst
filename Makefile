clean:
	rm -fr bin/ out/

runjs: buildjs
	chromium index.html

runhl: buildhl
	hl ./bin/kriegskunst.hl

runnative: buildc
	./bin/kriegskunst

buildjs:
	haxe js.hxml

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