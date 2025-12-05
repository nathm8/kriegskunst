#!/bin/bash

cd "res/img/ui/"
for path in "RotationButton" "TriangleButton"; do
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