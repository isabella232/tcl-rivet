# Code example for the transmission of a pdf file. 

if {[var exists pdfname]} {
    set pdfname [var get pdfname]

# let's build the full path to the pdf file. The 'pdf_repository'
# directory must be readable by the apache children

    set pdf_full_path [file join $pdf_repository ${pdfname}.pdf]
    if {[file exists $pdf_full_path]} {

# Before the file is sent we inform the client about the file type and
# file name. The client can be proposed a filename different from the
# original one. In this case, this is the point where a new file name
# must be generated.

        headers type                    "application/pdf"
        headers add Content-Disposition "attachment; filename=${pdfname}.pdf"
        headers add Content-Description "PDF Document"

# The pdf is read and stored in a Tcl variable. The file handle is
# configured for a binary read: we are just shipping raw data to a
# client. The following 4 lines of code can be replaced by any code
# that is able to retrieve the data to be sent from any data source
# (e.g. database, external program, other Tcl code)

        set paper       [open $pdf_full_path r]
        fconfigure      $paper -translation binary
        set pdf         [read $paper]
        close $paper

# Now we got the data: let's tell the client how many bytes we are
# about to send (useful for the download progress bar of a dialog box)

        headers add Content-Length  [string length $pdf]

# Let's send the actual file content

        puts $pdf

    } else {
        parse pdf_not_found_error.rvt
    }
} else {
    parse parameter_not_defined_error.rvt
}
