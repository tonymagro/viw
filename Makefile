CC=gcc
BIN=viw
BIN_TEST=viw_test
DEBUG=0
CVERSION=gnu99

UNAME=$(shell uname)
ifeq ($(findstring MINGW, $(UNAME)), MINGW)
	PLATFORM=WINDOWS
	WIN_CONSOLE=1
endif
ifeq ($(findstring Darwin, $(UNAME)), Darwin)
	PLATFORM=DARWIN
endif

INCLUDE= -I./include -I./src/proto
CFLAGS= -MMD -std=${CVERSION} -DPLATFORM_$(PLATFORM)

ifneq ($(DEBUG), 0)
	CFLAGS+= -g -O0 -DDEBUG
endif

ifeq ($(PLATFORM), WINDOWS)
	BIN:=$(BIN).exe
	BIN_TEST:=$(BIN_TEST).exe
	ifneq ($(WIN_CONSOLE), 0)
		LIBS= -lkernel32 -luser32 -lgdi32 -ladvapi32 -lcomdlg32 -lcomctl32 -lversion -lOle32 -luuid
		#-lgdi32 -lwinmm -limm32 -lversion -loleaut32 -lOle32 -luuid
	else
		LIBS= -mwindows
	endif
	CFLAGS+= $(INCLUDE) -DFEAT_GUI_W32 -DFEAT_CLIPBOARD -DWIN32
	LDFLAGS= -lmingw32 $(LIBS)
endif

ifeq ($(PLATFORM), DARWIN)
	CFLAGS+= $(INCLUDE) -I/usr/local/include -D_THREAD_SAFE
	LDFLAGS= -L/usr/local/lib
endif

GUIFILES=\
	gui.c\
	gui_w32.c\
	gui_beval.c\
	os_w32exe.c\

CFILES=\
	blowfish.c\
	buffer.c\
	charset.c\
	diff.c\
	digraph.c\
	edit.c\
	eval.c\
	ex_cmds.c\
	ex_cmds2.c\
	ex_docmd.c\
	ex_eval.c\
	ex_getln.c\
	fileio.c\
	fold.c\
	getchar.c\
	hardcopy.c\
	hashtab.c\
	main.c\
	mark.c\
	memfile.c\
	memline.c\
	menu.c\
	message.c\
	misc1.c\
	misc2.c\
	move.c\
	mbyte.c\
	normal.c\
	ops.c\
	option.c\
	os_win32.c\
	os_mswin.c\
	winclip.c\
	popupmnu.c\
	quickfix.c\
	regexp.c\
	screen.c\
	search.c\
	sha256.c\
	spell.c\
	syntax.c\
	tag.c\
	term.c\
	ui.c\
	undo.c\
	version.c\
	window.c\

EFILES=\
	pathdef.c\
	vimrc.c\


CFILES += $(GUIFILES)
OFILES=$(addprefix obj/, $(notdir $(CFILES:.c=.o)))
DFILES=$(OFILES:.o=.d)

all: $(BIN)

test: $(BIN_TEST)

$(BIN): $(OFILES)
	$(CC) $(OFILES) $(LDFLAGS) -o $@

$(BIN_TEST): EXTRA_CFLAGS := -DUNIT_TESTS
$(BIN_TEST): $(OFILES)
	$(CC) $(OFILES) $(LDFLAGS) -o $@

obj/%.o: ./src/%.c | obj
	$(CC) -c $< $(CFLAGS) $(EXTRA_CFLAGS) -o $@

# -MMD generated header dependencies
-include obj/*.d

obj:
	mkdir ./obj

run: all
	./$(BIN)

clean:
	-rm $(OFILES) $(DFILES) $(BIN) $(BIN_TEST)
