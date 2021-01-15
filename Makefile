SOURCES = ot3-top.stl ot3-bottom.stl ot3-clicker.stl
OUTPUTS = $(patsubst %.scad,%.stl,$(SOURCES))

.PHONY: all clean

all: $(OUTPUTS)

%.stl: %.scad
	openscad -o $@ $<

clean:
	rm -f $(OUTPUTS)
