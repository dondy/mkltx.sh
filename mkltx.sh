#!/usr/bin/env bash
# dependencies: texlive and mupdf
# build main.tex in the current folder, renaming it after the folder
# start viewing it with mupdf and watch for changes in main.tex or watch_list
# changes occuring trigger a rebuild and update in mupdf

# MAYBE: generate watch_list from main_file
main_file="./main.tex"

if [ ! -f "$main_file" ]
then
  cat << EOF
    "$main_file" not found in $(pwd)
    USAGE: "$0" include_file1 include_file2 ...
EOF
  exit 1
fi

pdf_file="./$(basename "$PWD").pdf"

build() {
  pdflatex "$main_file"
  mv "${main_file%.tex}.pdf" "$pdf_file"
}

[ ! -f "$pdf_file" ] && build

mupdf "$pdf_file" &
mupdf_pid=$!

clean_exit() {
  rm -f ./*.{aux,log}
  kill $mupdf_pid
  exit
}

trap clean_exit SIGINT

while sleep 1
do for file in $main_file "$@"
   do if [ "./$file" -nt "$pdf_file" ]
      then
        build && kill -HUP $mupdf_pid
	break
      fi
   done
done

