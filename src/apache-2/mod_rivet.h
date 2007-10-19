
#ifndef MOD_RIVET_H
#define MOD_RIVET_H 1

#include <tcl.h>
#include "apache_request.h"
#include "TclWeb.h"

/* init.tcl file relative to the server root directory */
#define RIVET_DIR "rivet"
#define RIVET_INIT RIVET_DIR"/init.tcl"

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

/* If you want to show the mod_rivet version in the server
   information, you can define this to 0.

   Otherwise, set this to 1 to hide the version from potential
   troublemakers.  */
#define HIDE_RIVET_VERSION 1

/* End Configuration options  */

/* For Tcl 8.3/8.4 compatibility - see http://mini.net/tcl/3669 */
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
    Tcl_Interp *server_interp;           /* per server Tcl interpreter */
    Tcl_Obj *rivet_global_init_script;   /* run once when apache is started */
    Tcl_Obj *rivet_child_init_script;
    Tcl_Obj *rivet_child_exit_script;
    char *rivet_before_script;        /* script run before each page */
    char *rivet_after_script;         /*            after            */
    char *rivet_error_script;         /*            for errors */

    /* This flag is used with the above directives.  If any of them
       have changed, it gets set. */
    int user_scripts_updated;

    Tcl_Obj *rivet_default_error_script;         /*            for errors */
    int *cache_size;
    int *cache_free;
    int upload_max;
    int upload_files_to_var;
    int separate_virtual_interps;
    char *server_name;
    char *upload_dir;
    apr_table_t *rivet_server_vars;
    apr_table_t *rivet_dir_vars;
    apr_table_t *rivet_user_vars;
    char **objCacheList;   /* Array of cached objects (for priority handling) */
    Tcl_HashTable *objCache; /* Objects cache - the key is the script name */

    /* stuff for buffering output */
    Tcl_Channel *outchannel;
} rivet_server_conf;

/* eventually we will transfer 'global' variables in here and
   'de-globalize' them */

typedef struct _rivet_interp_globals {
    request_rec *r;             /* request rec */
    TclWebRequest *req;         /* TclWeb API request */
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
