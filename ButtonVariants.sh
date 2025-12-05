#!/bin/bash

cd "res/img/ui/"
for path in "TriangleButton"; do
    cd $path
    rm -f Up* Down* Right* Left* # suppress no such file errors
    for f in "Hover.png" "Disabled.png" "Loading.png" "Active.png" "Enabled.png"; do
        cp $f "Up"$f
        magick $f -rotate 90 "Right"$f
        magick $f -rotate 180 "Down"$f
        magick $f -rotate 270 "Left"$f
    done
    cd ..
done

for path in "RotationButton"; do
    cd $path
    rm -f XMirror* # suppress no such file errors
    for f in "Hover.png" "Disabled.png" "Loading.png" "Active.png" "Enabled.png"; do
        magick $f -flop "XMirror"$f
    done
    cd ..
done