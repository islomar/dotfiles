#!/bin/sh

gs -o salida.pdf \
  -sDEVICE=pdfwrite \
  -dDEVICEWIDTHPOINTS=595 \
  -dDEVICEHEIGHTPOINTS=841 \
  -dFIXEDMEDIA \
  -dPDFFitPage \
  entrada.pdf