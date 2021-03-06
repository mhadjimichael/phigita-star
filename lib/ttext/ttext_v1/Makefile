# Makefile.in --
#
#	This file is a Makefile for Sample TEA Extension.  If it has the name
#	"Makefile.in" then it is a template for a Makefile;  to generate the
#	actual Makefile, run "./configure", which is a configuration script
#	generated by the "autoconf" program (constructs like "@foo@" will get
#	replaced in the actual Makefile.
#
# Copyright (c) 1999 Scriptics Corporation.
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# RCS: @(#) $Id: Makefile.in,v 1.17 1999/08/25 18:38:09 wart Exp $

#========================================================================
# Edit the following few lines when writing a new extension
#========================================================================

#========================================================================
# Change the name of the variable "exampleA_LIB_FILE" to match the one
# used in the configure script.  This is the parameterized name of the
# library that we are building.
#========================================================================

lib_BINARIES=$(ttext_LIB_FILE)
BINARIES=$(lib_BINARIES)

#========================================================================
# Enumerate the names of the source files included in this package.
# This will be used when a dist target is added to the Makefile.
#========================================================================

ttext_SOURCES = cluster.cpp datapoint.cpp  common.cpp evaluator.cpp map.cpp threshold.cpp bte.cpp ttext.cpp unaccent.cpp

SOURCES = $(ttext_SOURCES)

#========================================================================
# Enumerate the names of the object files included in this package.
# These objects are created and linked into the final library.  In
# most cases these object files will correspond to the source files
# above.
#
#========================================================================

ttext_OBJECTS = cluster.$(OBJEXT) datapoint.$(OBJEXT)  common.$(OBJEXT) evaluator.$(OBJEXT) map.$(OBJEXT) threshold.$(OBJEXT) tidy.$(OBJEXT) ttext.$(OBJEXT) unaccent.$(OBJEXT)

OBJECTS = $(exampleA_OBJECTS)

#========================================================================
# The substitution of "exampleA_LIB_FILE" into the variable name below
# let's us refer to the objects for the library without knowing the name
# of the library in advance.  It also lets us use the "$@" variable in
# the rule for building the library, so we can refer to both the list of 
# objects and the library itself in a platform-independent manner.
#========================================================================

ttext_LIB_FILE = libttext0.4.so
$(ttext_LIB_FILE)_OBJECTS = $(ttext_OBJECTS)

#========================================================================
# This is a list of header files to be installed
#========================================================================

GENERIC_HDRS= \
	$(srcdir)/cluster.h $(srcdir)/datapoint.h $(srcdir)/ttext.h $(srcdir)/map.h $(srcdir)/common.h $(srcdir)/evaluator.h $(srcdir)/mainnews.h $(srcdir)/threshold.h ${srcdir}/bte.h

#========================================================================
# Add additional lines to handle any additional AC_SUBST cases that
# have been added to the configure script.
#========================================================================

SAMPLE_NEW_VAR=@SAMPLE_NEW_VAR@

#========================================================================
# Nothing of the variables below this line need to be changed.  Please
# check the TARGETS section below to make sure the make targets are
# correct.
#========================================================================

SHELL = /bin/sh

srcdir = .
top_srcdir = .
prefix = /usr/local
exec_prefix = ${prefix}

bindir = ${exec_prefix}/bin
sbindir = ${exec_prefix}/sbin
libexecdir = ${exec_prefix}/libexec
datadir = ${prefix}/share
sysconfdir = ${prefix}/etc
sharedstatedir = ${prefix}/com
localstatedir = ${prefix}/var
libdir = ${exec_prefix}/lib
infodir = ${prefix}/info
mandir = ${prefix}/man
includedir = ${prefix}/include
oldincludedir = /usr/include

DESTDIR =

pkgdatadir = $(datadir)/ttext
pkglibdir = $(libdir)/ttext
pkgincludedir = $(includedir)/ttext

top_builddir = .

INSTALL = /usr/bin/install -c
INSTALL_PROGRAM = ${INSTALL}
INSTALL_DATA = ${INSTALL} -m 644
INSTALL_SCRIPT = ${INSTALL}
INSTALL_STRIP_FLAG =
transform = s,x,x,

NORMAL_INSTALL = :
PRE_INSTALL = :
POST_INSTALL = :
NORMAL_UNINSTALL = :
PRE_UNINSTALL = :
POST_UNINSTALL = :

PACKAGE = ttext
VERSION = 0.4
CC = g++
CFLAGS_DEBUG = -g
CFLAGS_DEFAULT = -O2
CFLAGS_OPTIMIZE = -O2
CLEANFILES = 
EXEEXT = 
LDFLAGS_DEBUG = @LDFLAGS_DEBUG@
LDFLAGS_DEFAULT = 
LDFLAGS_OPTIMIZE = @LDFLAGS_OPTIMIZE@
MAKE_LIB = ${SHLIB_LD} -o $@ $($@_OBJECTS) ${SHLIB_LDFLAGS} ${SHLIB_LD_LIBS}
MAKE_SHARED_LIB = ${SHLIB_LD} -o $@ $($@_OBJECTS) ${SHLIB_LDFLAGS} ${SHLIB_LD_LIBS}
MAKE_STATIC_LIB = ${STLIB_LD} $@ $($@_OBJECTS)
OBJEXT = o
RANLIB = :
SHLIB_CFLAGS = -fPIC
SHLIB_LD = g++ -pipe -shared -ltidy -lunac
SHLIB_LDFLAGS = 
SHLIB_LD_LIBS = -L/usr/lib -ltclstub8.4${TCL_DBGX}
STLIB_LD = ${AR} cr
TCL_BIN_DIR = /usr/lib
TCL_DEFS =  -DHAVE_LIMITS_H=1 -DHAVE_UNISTD_H=1 -DHAVE_SYS_PARAM_H=1 -DUSE_THREAD_ALLOC=1 -D_REENTRANT=1 -D_THREAD_SAFE=1 -DHAVE_PTHREAD_ATTR_SETSTACKSIZE=1 -DHAVE_PTHREAD_ATFORK=1 -DTCL_THREADS=1 -DPEEK_XCLOSEIM=1 -D_LARGEFILE64_SOURCE=1 -DTCL_WIDE_INT_TYPE=long\ long -DHAVE_STRUCT_STAT64=1 -DHAVE_OPEN64=1 -DHAVE_LSEEK64=1 -DHAVE_TYPE_OFF64_T=1 -DHAVE_GETCWD=1 -DHAVE_OPENDIR=1 -DHAVE_STRSTR=1 -DHAVE_STRTOL=1 -DHAVE_STRTOLL=1 -DHAVE_STRTOULL=1 -DHAVE_TMPNAM=1 -DHAVE_WAITPID=1 -DHAVE_GETPWUID_R_5=1 -DHAVE_GETPWUID_R=1 -DHAVE_GETPWNAM_R_5=1 -DHAVE_GETPWNAM_R=1 -DHAVE_GETGRGID_R_5=1 -DHAVE_GETGRGID_R=1 -DHAVE_GETGRNAM_R_5=1 -DHAVE_GETGRNAM_R=1 -DHAVE_GETHOSTBYNAME_R_6=1 -DHAVE_GETHOSTBYNAME_R=1 -DHAVE_GETHOSTBYADDR_R_8=1 -DHAVE_GETHOSTBYADDR_R=1 -DUSE_TERMIOS=1 -DHAVE_SYS_TIME_H=1 -DTIME_WITH_SYS_TIME=1 -DHAVE_TM_ZONE=1 -DHAVE_GMTIME_R=1 -DHAVE_LOCALTIME_R=1 -DHAVE_TM_GMTOFF=1 -DHAVE_TIMEZONE_VAR=1 -DHAVE_ST_BLKSIZE=1 -DSTDC_HEADERS=1 -DHAVE_SIGNED_CHAR=1 -DHAVE_LANGINFO=1 -DHAVE_SYS_IOCTL_H=1 
TCL_EXTRA_CFLAGS = -O2 -mtune=i686 -pipe
TCL_LD_FLAGS =  -Wl,--export-dynamic
TCL_LIBS = -ldl  -lpthread -lieee -lm
TCL_SHLIB_LD_LIBS = ${LIBS}
TCL_SRC_DIR = /usr/lib/tcl8.4/include
TCL_DBGX = 
TCL_STUB_LIB_FILE = libtclstub8.4${TCL_DBGX}.a
TCL_STUB_LIB_SPEC = -L/usr/lib -ltclstub8.4${TCL_DBGX}
TCL_TOOL_DIR_NATIVE = @TCL_TOOL_DIR_NATIVE@
TCL_TOP_DIR_NATIVE = @TCL_TOP_DIR_NATIVE@
TCL_UNIX_DIR_NATIVE = @TCL_UNIX_DIR_NATIVE@
TCL_WIN_DIR_NATIVE = @TCL_WIN_DIR_NATIVE@
INCLUDE_DIR_NATIVE = @INCLUDE_DIR_NATIVE@
TCL_BMAP_DIR_NATIVE = @TCL_BMAP_DIR_NATIVE@
TCL_PLATFORM_DIR_NATIVE = @TCL_PLATFORM_DIR_NATIVE@
TCL_GENERIC_DIR_NATIVE = @TCL_GENERIC_DIR_NATIVE@
TCLSH_PROG = /usr/bin/tclsh

AUTOCONF = autoconf

LDFLAGS = $(LDFLAGS_DEFAULT)

INCLUDES = -I"/usr/include"

EXTRA_CFLAGS = $(TCL_DEFS) $(PROTO_FLAGS) $(SECURITY_FLAGS) $(MEM_DEBUG_FLAGS) $(KEYSYM_FLAGS) $(NO_DEPRECATED_FLAGS)

DEFS = -DPACKAGE_NAME=\"\" -DPACKAGE_TARNAME=\"\" -DPACKAGE_VERSION=\"\" -DPACKAGE_STRING=\"\" -DPACKAGE_BUGREPORT=\"\" -DVERSION=\"0.4\" -DUSE_TCL_STUBS=1  $(EXTRA_CFLAGS)

ACLOCAL_M4 = $(top_srcdir)/aclocal.m4
mkinstalldirs = $(SHELL) $(top_srcdir)/mkinstalldirs
CONFIG_CLEAN_FILES = mkIndex.tcl

CPPFLAGS = 
LIBS = 
AR = ar
CFLAGS = ${CFLAGS_DEFAULT} ${CFLAGS_WARNING} ${SHLIB_CFLAGS}
COMPILE = $(CC) $(DEFS) $(INCLUDES) $(AM_CPPFLAGS) $(CPPFLAGS) $(AM_CFLAGS) $(CFLAGS)
CCLD = $(CC)
LINK = $(CCLD) $(AM_CFLAGS) $(CFLAGS) $(LDFLAGS) -o $@

#========================================================================
# Start of user-definable TARGETS section
#========================================================================

#========================================================================
# TEA TARGETS.  Please note that the "libraries:" target refers to platform
# independent files, and the "binaries:" target inclues executable programs and
# platform-dependent libraries.  Modify these targets so that they install
# the various pieces of your package.  The make and install rules
# for the BINARIES that you specified above have already been done.
#========================================================================

all: binaries libraries doc

#========================================================================
# The binaries target builds executable programs, Windows .dll's, unix
# shared/static libraries, and any other platform-dependent files.
# The list of targets to build for "binaries:" is specified at the top
# of the Makefile, in the "BINARIES" variable.
#========================================================================

binaries: $(BINARIES)

libraries:

doc:
	@echo "If you have documentation to create, place the commands to"
	@echo "build the docs in the 'doc:' target.  For example:"
	@echo ""
	@echo "xml2nroff exampleA.xml > exampleA.n"
	@echo "xml2html exampleA.xml > exampleA.html"

install: all install-binaries install-libraries install-doc

install-binaries: binaries install-lib-binaries install-bin-binaries

#========================================================================
# This rule installs platform-independent files, such as header files.
#========================================================================

install-libraries: libraries
	$(mkinstalldirs) $(includedir)
	echo "Installing header files in $(includedir)"
	@for i in $(GENERIC_HDRS) ; do \
	    echo "Installing $$i" ; \
	    $(INSTALL_DATA) $$i $(includedir) ; \
	done;

#========================================================================
# Install documentation.  Unix manpages should go in the $(mandir)
# directory.
#========================================================================

install-doc: doc
	$(mkinstalldirs) $(mandir)/man1
	$(mkinstalldirs) $(mandir)/man3
	$(mkinstalldirs) $(mandir)/mann
	@for i in $(srcdir)/*.n; \
	    do \
	    echo "Installing $$i"; \
	    rm -f $(mandir)/mann/$$i; \
	    $(INSTALL_DATA) $$i $(mandir)/mann/$$i ; \
	    chmod 444 $(mandir)/mann/$$i; \
	    done

test:

depend:

#========================================================================
# Enumerate the names of the object files included in this package.
# These objects are created and linked into the final library.  In
# most cases these object files will correspond to the source files
# above.
#
# $(exampleA_LIB_FILE) should be listed as part of the BINARIES variable
# at the top of the Makefile.  That will ensure that this target is built
# when you run "make binaries".
#
# You shouldn't need to modify this target, except to change the package
# name from "exampleA" to your package's name.
#========================================================================

$(ttext_LIB_FILE): $(ttext_OBJECTS)
	-rm -f $(ttext_LIB_FILE)
	${SHLIB_LD} -o $@ $($@_OBJECTS) ${SHLIB_LDFLAGS} ${SHLIB_LD_LIBS}
	$(RANLIB) $(ttext_LIB_FILE)

#========================================================================
# We need to enumerate the list of .c to .o lines here.
# Unfortunately, there does not seem to be any other way to do this
# in a Makefile-independent way.  We can't use VPATH because it picks up
# object files that may be located in the source directory.
#
# In the following lines, $(srcdir) refers to the toplevel directory
# containing your extension.  If your sources are in a subdirectory,
# you will have to modify the paths to reflect this:
#
# exampleA.$(OBJEXT): $(srcdir)/src/win/exampleA.c
# 	$(COMPILE) -c `echo $(srcdir)/src/win/exampleA.c` -o $@
#========================================================================
#=========
# cluster
#=========
cluster.$(OBJEXT): $(srcdir)/src/cluster/cluster.cpp
	$(COMPILE) -c `echo $(srcdir)/src/cluster/cluster.cpp` -o $@
datapoint.$(OBJEXT): $(srcdir)/src/cluster/datapoint.cpp
	$(COMPILE) -c `echo $(srcdir)/src/cluster/datapoint.cpp` -o $@

common.$(OBJEXT): $(srcdir)/src/cluster/common.cpp
	$(COMPILE) -c `echo $(srcdir)/src/cluster/common.cpp` -o $@
evaluator.$(OBJEXT): $(srcdir)/src/cluster/evaluator.cpp
	$(COMPILE) -c `echo $(srcdir)/src/cluster/evaluator.cpp` -o $@
map.$(OBJEXT): $(srcdir)/src/cluster/map.cpp
	$(COMPILE) -c `echo $(srcdir)/src/cluster/map.cpp` -o $@
threshold.$(OBJEXT): $(srcdir)/src/cluster/threshold.cpp
	$(COMPILE) -c `echo $(srcdir)/src/cluster/threshold.cpp` -o $@

#==========
# tidy
#==========
tidy.$(OBJEXT): $(srcdir)/src/tidy/tidy.cpp
	$(COMPILE) -c `echo $(srcdir)/src/tidy/tidy.cpp` -o $@

# unaccent
#==========
unaccent.$(OBJEXT): $(srcdir)/src/unac/unaccent.cpp
	$(COMPILE) -c `echo $(srcdir)/src/unac/unaccent.cpp` -o $@


#=======
# ttext
#=======
ttext.$(OBJEXT): $(srcdir)/src/ttext.cpp
	$(COMPILE) -c `echo $(srcdir)/src/ttext.cpp` -o $@


#========================================================================
# End of user-definable section
#========================================================================

#========================================================================
# Don't modify the file to clean here.  Instead, set the "CLEANFILES"
# variable in configure.in
#========================================================================

clean:  
	-test -z "$(BINARIES)" || rm -f $(BINARIES)
	-rm -f *.o core *.core
	-rm -f *.$(OBJEXT)
	-rm -f $(srcdir)/src/*.$(OBJEXT)
	-test -z "$(CLEANFILES)" || rm -f $(CLEANFILES)

distclean: clean
	-rm -f *.tab.c
	-rm -f Makefile $(CONFIG_CLEAN_FILES)
	-rm -f config.cache config.log stamp-h stamp-h[0-9]*
	-rm -f config.status

#========================================================================
# Install binary object libraries.  On Windows this includes both .dll and
# .lib files.  Because the .lib files are not explicitly listed anywhere,
# we need to deduce their existence from the .dll file of the same name.
# Additionally, the .dll files go into the bin directory, but the .lib
# files go into the lib directory.  On Unix platforms, all library files
# go into the lib directory.  In addition, this will generate the pkgIndex.tcl
# file in the install location (assuming it can find a usable tclsh8.2 shell)
#
# You should not have to modify this target.
#========================================================================

install-lib-binaries: installdirs
	@list='$(lib_BINARIES)'; for p in $$list; do \
	  if test -f $$p; then \
	    ext=`echo $$p|sed -e "s/.*\.//"`; \
	    if test "x$$ext" = "xdll"; then \
	        echo " $(INSTALL_DATA) $$p $(DESTDIR)$(bindir)/$$p"; \
	        $(INSTALL_DATA) $$p $(DESTDIR)$(bindir)/$$p; \
		lib=`basename $$p|sed -e 's/.[^.]*$$//'`.lib; \
		if test -f $$lib; then \
		    echo " $(INSTALL_DATA) $$lib $(DESTDIR)$(libdir)/$$lib"; \
	            $(INSTALL_DATA) $$lib $(DESTDIR)$(libdir)/$$lib; \
		fi; \
	    else \
		echo " $(INSTALL_DATA) $$p $(DESTDIR)$(libdir)/$$p"; \
	        $(INSTALL_DATA) $$p $(DESTDIR)$(libdir)/$$p; \
	    fi; \
	  else :; fi; \
	done
	@list='$(lib_BINARIES)'; for p in $$list; do \
	  if test -f $$p; then \
	    echo " $(RANLIB) $(DESTDIR)$(bindir)/$$p"; \
	    $(RANLIB) $(DESTDIR)$(bindir)/$$p; \
	  else :; fi; \
	done
	$(TCLSH_PROG) mkIndex.tcl

#========================================================================
# Install binary executables (e.g. .exe files)
#
# You should not have to modify this target.
#========================================================================

install-bin-binaries: installdirs
	@list='$(bin_BINARIES)'; for p in $$list; do \
	  if test -f $$p; then \
	    echo " $(INSTALL_DATA) $$p $(DESTDIR)$(bindir)/$$p"; \
	    $(INSTALL_DATA) $$p $(DESTDIR)$(bindir)/$$p; \
	  else :; fi; \
	done

.SUFFIXES: .c .o .obj

Makefile: $(srcdir)/Makefile.in  $(top_builddir)/config.status
	cd $(top_builddir) \
	  && CONFIG_FILES=$@ CONFIG_HEADERS= $(SHELL) ./config.status

config.status: $(srcdir)/configure $(CONFIG_STATUS_DEPENDENCIES)
	$(SHELL) ./config.status --recheck
$(srcdir)/configure: $(srcdir)/configure.in $(ACLOCAL_M4) $(CONFIGURE_DEPENDENCIES)
	cd $(srcdir) && $(AUTOCONF)


uninstall-binaries:
	@$(NORMAL_UNINSTALL)
	list='$(BINARIES)'; for p in $$list; do \
	  rm -f $(DESTDIR)$(libdir)/$$p; \
	done

installdirs:
	$(mkinstalldirs)  $(DESTDIR)$(libdir)
	$(mkinstalldirs)  $(DESTDIR)$(bindir)
	$(mkinstalldirs)  $(DESTDIR)$(pkglibdir)

.PHONY: all binaries clean depend distclean doc install installdirs \
libraries test

# Tell versions [3.59,3.63) of GNU make to not export all variables.
# Otherwise a system limit (for SysV at least) may be exceeded.
.NOEXPORT:
