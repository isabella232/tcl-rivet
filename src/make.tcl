#!/bin/sh
# the next line restarts using tclsh \
	exec tclsh "$0" "$@"

# $Id$
#
# This file is responsible for the top-level "make" style processing.

# Source the other scripts we need.
source [file join [file dirname [info script]] buildscripts buildscripts.tcl]

# Do we have a threaded Tcl?
if { [info exists tcl_platform(threaded)] } {
    set TCL_THREADED "-DTCL_THREADED=1"
} else {
    set TCL_THREADED "-DTCL_THREADED=0"
}

namespace import ::aardvark::*

## Add variables

##
## Set this variable to the location of your apxs script if it cannot be
## found by make.tcl, or use the environmental variable 'APXS_LOCATION'.
##

set APXS "apxs"

if { [info exists env(APXS_LOCATION)] } {
    set APXS $env(APXS_LOCATION)
} else {
    ## Try to find the Apache apxs script.
    set APXS [FindAPXS $APXS]
}

# set APXS "path/to/apxs"

if { ![string length $APXS] } {
    puts stderr "Could not find Apache apxs script."
    append err "You need to edit 'make.tcl' to supply the location of "
    append err "Apache's apxs tool."
    puts stderr $err
    exit 1
}

set INCLUDEDIR [exec $APXS -q INCLUDEDIR]
set LIBEXECDIR [exec $APXS -q LIBEXECDIR]
set PREFIX [lindex $auto_path end]

set INC "-I$INCLUDEDIR -I$TCL_PREFIX/include"

set COMPILE "$TCL_CC $TCL_CFLAGS_DEBUG $TCL_CFLAGS_OPTIMIZE $TCL_CFLAGS_WARNING $TCL_SHLIB_CFLAGS $INC  $TCL_EXTRA_CFLAGS $TCL_THREADED -c"

set MOD_STLIB mod_rivet.a
set MOD_SHLIB mod_rivet[info sharedlibextension]
set MOD_OBJECTS "apache_multipart_buffer.o apache_request.o rivetChannel.o rivetParser.o rivetCore.o mod_rivet.o TclWebapache.o"

set RIVETLIB_STLIB librivet.a
set RIVETLIB_SHLIB librivet[info sharedlibextension]
set RIVETLIB_OBJECTS "rivetList.o rivetCrypt.o rivetWWW.o rivetPkgInit.o"

set PARSER_SHLIB librivetparser[info sharedlibextension]
set PARSER_OBJECTS "rivetParser.o parserPkgInit.o"

set TCL_LIBS "$TCL_LIBS -lcrypt"

set XML_DOCS [glob [file join .. doc packages * *].xml]
set HTML_DOCS [string map {.xml .html} $XML_DOCS]
set HTML "[file join .. doc html]/"
set XSLNOCHUNK [file join .. doc rivet-nochunk.xsl]
set XSLCHUNK [file join .. doc rivet-chunk.xsl]
set XSL [file join .. doc rivet.xsl]
set XML [file join .. doc rivet.xml]
# Existing translations.
set TRANSLATIONS {ru it}
set PKGINDEX [file join .. rivet pkgIndex.tcl]

# ------------

# "AddNode" adds a compile target

# "depends" lists the nodes on which it depends

# "sh" is a shell command to execute

# "tcl" executes some Tcl code.

AddNode apache_multipart_buffer.o {
    depends apache_multipart_buffer.c apache_multipart_buffer.h
    set COMP [lremove $COMPILE -Wconversion]
    sh {$COMP apache_multipart_buffer.c}
}

AddNode apache_request.o {
    depends apache_request.c apache_request.h
    set COMP [lremove $COMPILE -Wconversion]
    sh {$COMP apache_request.c}
}

AddNode rivetChannel.o {
    depends rivetChannel.c rivetChannel.h mod_rivet.h
    sh {$COMPILE rivetChannel.c}
}

AddNode rivetParser.o {
    depends rivetParser.c rivetParser.h mod_rivet.h
    sh {$COMPILE rivetParser.c}
}

AddNode rivetCore.o {
    depends rivetCore.c rivet.h mod_rivet.h
    sh {$COMPILE rivetCore.c}
}

AddNode rivetCrypt.o {
    depends rivetCrypt.c
    sh {$COMPILE rivetCrypt.c}
}

AddNode rivetList.o {
    depends rivetList.c
    sh {$COMPILE rivetList.c}
}

AddNode rivetWWW.o {
    depends rivetWWW.c
    sh {$COMPILE rivetWWW.c}
}

AddNode rivetPkgInit.o {
    depends rivetPkgInit.c
    sh {$COMPILE rivetPkgInit.c}
}

AddNode mod_rivet.o {
    depends mod_rivet.c mod_rivet.h apache_request.h parser.h
    sh {$COMPILE -DNAMEOFEXECUTABLE="[info nameofexecutable]" mod_rivet.c}
}

AddNode TclWebapache.o {
    depends TclWebapache.c mod_rivet.h apache_request.h TclWeb.h
    sh {$COMPILE TclWebapache.c}
}

AddNode parserPkgInit.o {
    depends parserPkgInit.c rivetParser.h
    sh {$COMPILE parserPkgInit.c}
}

AddNode $PARSER_SHLIB {
    depends $PARSER_OBJECTS
    sh {$TCL_SHLIB_LD -o $PARSER_SHLIB $PARSER_OBJECTS $TCL_LIB_SPEC $TCL_LIBS}
}

AddNode $RIVETLIB_STLIB {
    depends $RIVETLIB_OBJECTS
    sh {$TCL_STLIB_LD $RIVETLIB_STLIB $RIVETLIB_OBJECTS}
}

AddNode $RIVETLIB_SHLIB {
    depends $RIVETLIB_OBJECTS
    sh {$TCL_SHLIB_LD -o $RIVETLIB_SHLIB $RIVETLIB_OBJECTS $TCL_LIB_SPEC $TCL_LIBS}
}

AddNode $MOD_STLIB {
    depends $MOD_OBJECTS
    sh {$TCL_STLIB_LD $MOD_STLIB $MOD_OBJECTS}
}

AddNode $MOD_SHLIB {
    depends $MOD_OBJECTS
    sh {$TCL_SHLIB_LD -o $MOD_SHLIB $MOD_OBJECTS $TCL_LIB_SPEC $TCL_LIBS}
}

AddNode all {
    depends module
}

AddNode module {
    depends shared
}

# Make a shared build.

AddNode shared {
    depends $MOD_SHLIB $RIVETLIB_SHLIB $PARSER_SHLIB
}

# Make a static build - incomplete at the moment.

AddNode static {
    depends $MOD_STLIB $RIVETLIB_STLIB
}

# Clean up source directory.

AddNode clean {
    tcl {
	foreach fl [glob -nocomplain *.o *.so *.a] {
	    file delete $fl
	}
    }
}

AddNode $PKGINDEX {
    tcl {
	set curdir [pwd]
	cd [file dirname $PKGINDEX]
	eval pkg_mkIndex -verbose [pwd] init.tcl [glob [file join packages * *.tcl]]
	puts [list pkg_mkIndex -verbose [pwd] init.tcl [glob [file join packages * *.tcl]]]
	cd $curdir
    }
}

#AddNode testing.o {
#    sh {$COMPILE testing.c}
#}

#AddNode libtesting.so {
#    depends {parser.o testing.o}
#    sh {$TCL_SHLIB_LD -o libtesting.so parser.o testing.o}
#}

# Install everything.

AddNode install {
    depends $MOD_SHLIB $RIVETLIB_SHLIB $PARSER_SHLIB
    tcl file delete -force [file join $LIBEXECDIR rivet]
    tcl file delete -force [file join $PREFIX rivet]
    tcl file copy -force $MOD_SHLIB $LIBEXECDIR
    tcl file copy -force [file join .. rivet] $PREFIX
    tcl file copy -force $RIVETLIB_SHLIB [file join $PREFIX rivet packages rivet]
    tcl file copy -force $PARSER_SHLIB [file join $PREFIX rivet packages rivet]
}

# Install everything when creating a deb.  We need to find a better
# way of doing this.  It would involve passing arguments on the
# command line.

set DEBPREFIX [file join [pwd] .. debian tmp]
AddNode debinstall {
    depends $MOD_SHLIB $RIVETLIB_SHLIB $PARSER_SHLIB
    tcl {file delete -force [file join $DEBPREFIX/$LIBEXECDIR rivet]}
    tcl {file copy -force $MOD_SHLIB "$DEBPREFIX/$LIBEXECDIR"}
    tcl {file copy -force [file join .. rivet] "$DEBPREFIX/$PREFIX"}
    tcl {file copy -force $RIVETLIB_SHLIB "$DEBPREFIX/[file join $PREFIX rivet packages rivet]"}
    tcl {file copy -force $PARSER_SHLIB "$DEBPREFIX/[file join $PREFIX rivet packages rivet]"}
}

foreach doc $HTML_DOCS {
    set xml [string map {.html .xml} $doc]
    AddNode $doc {
	depends $XSLNOCHUNK $xml
	sh xsltproc --stringparam html.stylesheet rivet.css --nonet -o $doc $XSLNOCHUNK $xml
    }
}

AddNode ../VERSION {
    tcl cd ..
    sh ./cvsversion.tcl
    tcl cd src/
}

# Clean up everything for distribution.

AddNode distclean {
    depends clean
    tcl cd ..
    sh { find . -name "*~" | xargs rm -f }
    sh { find . -name ".#*" | xargs rm -f }
    sh { find . -name "\#*" | xargs rm -f }
    tcl cd src
}

# Create the HTML documentation from the XML document.

AddNode distdoc {
    depends $XML $XSL
    sh xsltproc --stringparam html.stylesheet rivet.css --stringparam html.ext ".html.en" --nonet -o $HTML $XSLCHUNK $XML
    foreach tr $TRANSLATIONS {
	sh xsltproc --stringparam html.stylesheet rivet.css  --stringparam html.ext ".html.${tr}" --nonet -o $HTML $XSLCHUNK [string map [list .xml ".${tr}.xml"] $XML]
    }
}

# Create the distribution.  This is a bit unix-specific for the
# moment, as it uses the bourne shell and unix commands.

AddNode dist {
    depends distclean distdoc ../VERSION $PKGINDEX
    tcl {
	set fl [open [file join .. VERSION]]
	set VERSION [string trim [read $fl]]
	close $fl
	cd [file join .. ..]
	exec tar czvf tcl-rivet-${VERSION}.tgz tcl-rivet/
    }
}

AddNode help {
    tcl {
	puts "Usage: $::argv0 target"
	puts "Targets are the following:"
    }
    tcl {
	foreach nd [lsort [Nodes]] {
	    puts "\t$nd"
	}
    }
}

Run
