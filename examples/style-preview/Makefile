# Comment, variable, preprocessor, target, operator, and recipe.
PROJECT := mrbmacs
SOURCES = main.c theme.c
OBJECTS := $(SOURCES:.c=.o)

ifdef DEBUG
CFLAGS += -O0 -g
else
CFLAGS += -O2
endif

.PHONY: all clean preview

all: $(PROJECT)

$(PROJECT): $(OBJECTS)
	$(CC) $(CFLAGS) -o $@ $^

preview: ; @echo "project=$(PROJECT) objects=$(OBJECTS)"

clean:
	$(RM) $(PROJECT) $(OBJECTS)

# Intentionally malformed variable reference for IDEOL/error styling.
broken = $(PROJECT
