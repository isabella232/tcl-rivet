/* mod_rivet.h -- The apache module itself, for Apache 2.x. */

/* Copyright 2000-2005 The Apache Software Foundation

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

   	http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

/* $Id: $ */

#ifndef MOD_RIVET_H
#define MOD_RIVET_H 1

#include <tcl.h>
#include "apache_request.h"
#include "TclWeb.h"

/* init.tcl file relative to the server root directory */

#define RIVET_DIR  RIVET_RIVETLIB_DESTDIR
#define RIVET_INIT RIVET_RIVETLIB_DESTDIR"/init.tcl"

#if 0
#define FILEDEBUGINFO fprintf(stderr, "Function " __FUNCTION__ "\n")
#else
#define FILEDEBUGINFO
#endif

/* Configuration options  */

/* If you do not have a threaded Tcl, you can define this to 0.  This
   has the effect of running Tcl Init code in the main parent init
   handler, instead of in child init handlers. */
#ifdef __MINGW32__
#define THREADED_TCL 1
#else
#define THREADED_TCL 0 /* Unless you have MINGW32, modify this one! */
#endif

/* End Configuration options  */

/* For Tcl 8.3/8.4 compatibility - see http://wiki.tcl.tk/3669 */
#ifndef CONST84
#   define CONST84
#endif

#define VAR_SRC_QUERYSTRING 1
#define VAR_SRC_POST 2
#define VAR_SRC_ALL 3

#define DEFAULT_ERROR_MSG "[an error occurred while processing this directive]"
#define DEFAULT_TIME_FORMAT "%A, %d-%b-%Y %H:%M:%S %Z"
#define MULTIPART_FORM_DATA 1
/* #define RIVET_VERSION "X.X.X" */

/* IMPORTANT: If you make any changes to the rivet_server_conf struct,
 * you need to make the appropriate modifications to Rivet_CopyConfig,
 * Rivet_CreateConfig, Rivet_MergeConfig and so on. */

module AP_MODULE_DECLARE_DATA rivet_module;

typedef struct _rivet_server_conf {
    Tcl_Interp *server_interp;          /* per server Tcl interpreter 	   */
    Tcl_Obj *rivet_server_init_script;  /* run before children are forked  */
    Tcl_Obj *rivet_global_init_script;	/* run once when apache is started */
    Tcl_Obj *rivet_child_init_script;
    Tcl_Obj *rivet_child_exit_script;
    Tcl_Obj *rivet_before_script;	    /* script run before each page	*/
    Tcl_Obj *rivet_after_script;	    /*            after             */
    Tcl_Obj *rivet_error_script;	    /*            for errors        */

    /* This flag is used with the above directives.  If any of them
       have changed, it gets set. */
    int user_scripts_updated;

    Tcl_Obj *rivet_default_error_script;    /* for errors */
    int *cache_size;
    int *cache_free;
    int upload_max;
    int upload_files_to_var;
    int separate_virtual_interps;
    int honor_header_only_reqs;
    char *server_name;
    const char *upload_dir;
    apr_table_t *rivet_server_vars;
    apr_table_t *rivet_dir_vars;
    apr_table_t *rivet_user_vars;
    char **objCacheList;		        /* Array of cached objects (for priority handling) */
    Tcl_HashTable *objCache;		    /* Objects cache - the key is the script name */

    Tcl_Channel *outchannel;		    /* stuff for buffering output */
} rivet_server_conf;

/* eventually we will transfer 'global' variables in here and
   'de-globalize' them */

typedef struct _rivet_interp_globals {
    request_rec     *r;			    /* request rec */
    TclWebRequest   *req;			/* TclWeb API request */
    Tcl_Namespace   *rivet_ns;      /* Rivet commands namespace */
} rivet_interp_globals;

int Rivet_ParseExecFile(TclWebRequest *req, char *filename, int toplevel);

rivet_server_conf *Rivet_GetConf(request_rec *r);

#ifdef ap_get_module_config
#undef ap_get_module_config
#endif
#ifdef ap_set_module_config
#undef ap_set_module_config
#endif

#define RIVET_SERVER_CONF(module) \
	(rivet_server_conf *)ap_get_module_config(module, &rivet_module)

#define RIVET_NEW_CONF(p) \
	(rivet_server_conf *)apr_pcalloc(p, sizeof(rivet_server_conf))


#endif /* MOD_RIVET_H */

