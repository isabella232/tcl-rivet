# convert_examples --
#
#
# reads the examples dir, checks if a file had been already converted
# in <target-dir> and compares their mtimes. If the file in
# <source-dir> is more recent the target dir is recreated.

# The script uses Rivet's escape_sgml_chars to convert examples code
# into text suitable to be inclued and displayed in XML/XHTML 
# documentation

# NOTICE: This script requires Rivet the rivet scripts and
# libraries in the auto_path.

# usage:
#
# tclsh ./convert_examples
#

lappend auto_path /usr/local/lib/rivet2.1
lappend auto_path [file join /usr/local/lib/rivet2.1 rivet-tcl]

package require Rivet

set source_dir examples
set target_dir examples-sgml

if {![info exists source_examples]} {
	set source_examples [glob [file join $source_dir *.*]]
	puts "escaping $source_examples to SGML compatible form"
}

foreach example $source_examples {

    set exam_name [file tail $example]
    set example_sgml [file join $target_dir $exam_name]

    set example_sgml_exists [file exists $example_sgml]

    if {!$example_sgml_exists || \
        ([file mtime $example] > [file mtime $example_sgml])} { 

        puts "$example needs rebuild"
        
        set example_text [read_file $example]

        set example_sgml_fid [open $example_sgml w+]
        puts $example_sgml_fid [escape_sgml_chars $example_text]
        close $example_sgml_fid

    }

}

