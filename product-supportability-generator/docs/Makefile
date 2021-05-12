sources := $(wildcard *.adoc)
targets := $(patsubst %.adoc,%.pdf,$(sources))
html5_targets := $(patsubst %.adoc,%.html5,$(sources))
all: $(html5_targets) $(targets)

%.pdf: %.adoc
	        asciidoctor-pdf -a pdf-stylesdir=./common-resources/themes -a pdf-fontsdir=./common-resources/fonts $*.adoc
%.html5: %.adoc
	        asciidoctor -b html5 -o $*.html5 $*.adoc

clean:
	        @rm -f $(targets)

