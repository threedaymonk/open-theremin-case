SOURCES = ot3-top.stl ot3-bottom.stl ot3-clicker.stl
OUTPUTS = $(patsubst %.scad,%.stl,$(SOURCES))

.PHONY: all clean

all: $(OUTPUTS)

%.stl: %.scad case.scad
	openscad -D '$$fs=0.1' -D '$$fa=0.1' -o $@ $<

clean:
	rm -f $(OUTPUTS)
