# -- catch.tcl
#
# Wrapper of the core [::catch] command that checks whether 
# an error condition is actually raised by [::rivet::abort_page]
# or [::rivet::exit]. In case the error is thrown again to allow
# the interpreter to interrupt and pass execution to AbortScript
#
# $Id: $
#

namespace eval ::rivet {

    proc catch {script args} {

        set catch_ret [uplevel ::catch $script $args]

        if {$catch_ret && [::rivet::abort_page -aborting]} {

            return -code error -errorcode ABORTPAGE

        } elseif {$catch_ret && [::rivet::abort_page -exiting]} {

            return -code error -errorcode EXITPAGE

        } else {

            return $catch_ret

        }

    }
}