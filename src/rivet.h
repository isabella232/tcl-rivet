/* Copyright 2002-2004 The Apache Software Foundation

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

/* $Id$ */

/* This is for windows. */
#ifdef BUILD_rivet
#undef TCL_STORAGE_CLASS
#define TCL_STORAGE_CLASS DLLEXPORT
#endif /* BUILD_rivet */

#define STREQU(s1, s2)  (s1[0] == s2[0] && strcmp(s1, s2) == 0)
#define STRNEQU(s1, s2) (s1[0] == s2[0] && strncmp(s1, s2, strlen(s2)) == 0)
#define RIVET_NS                "::rivet"
#define RIVET_TCL_PACKAGE       "rivet"
#define RIVETLIB_TCL_PACKAGE    "rivetlib"

#define TCL_CMD_HEADER(cmd)	\
static int cmd(\
    ClientData clientData,\
    Tcl_Interp *interp,\
    int objc,\
    Tcl_Obj *CONST objv[])

#define TCL_OBJ_CMD( name, func ) \
Tcl_CreateObjCommand( interp, /* Tcl interpreter */\
		      name,   /* Function name in Tcl */\
		      func,   /* C function name */\
		      NULL,   /* Client Data */\
		      (Tcl_CmdDeleteProc *)NULL /* Tcl Delete Prov */)

/* RIVET_OBJ_CMD creates a command in the RIVET_NS namespace. Commands
 * are exported from the RIVET_NS (::rivet) namespace in the init.tcl 
 * script accordingly to configuration switches passed to ./configure
 * (see configure.ac)
 */

#define RIVET_OBJ_CMD(name,func) \
Tcl_CreateObjCommand( interp, /* Tcl interpreter */\
		      RIVET_NS "::" name,   /* Function name in Tcl */\
		      func,   /* C function name */\
		      NULL,   /* Client Data */\
		      (Tcl_CmdDeleteProc *)NULL /* Tcl Delete Prov */); 

#define RIVET_EXPORT_CMD(interp,ns,cmdname) Tcl_Export(interp,ns,cmdname,0);

//Tcl_ListObjAppendElement(interp,export_l,Tcl_NewStringObj(RIVET_NS "::" cmdname,-1));

/* 
 * Pointer in r is checked and in case Rivet_NoRequestRec is
 * called returning TCL_ERROR. This macro is used (and often
 * is the first code like) in commands that must ascertain
 * the request_rec object pointer in globals is valid 
 * (when a request processing ends it's set to NULL)
 */

#define CHECK_REQUEST_REC(r,cmd_name) \
if (r == NULL)\
{\
    Rivet_NoRequestRec(interp,Tcl_NewStringObj(cmd_name,-1));\
    return TCL_ERROR;\
}

EXTERN int Rivet_Init(Tcl_Interp *interp);
EXTERN int Rivet_InitList(Tcl_Interp *interp);
EXTERN int Rivet_InitCrypt(Tcl_Interp *interp);
EXTERN int Rivet_InitWWW(Tcl_Interp *interp);
EXTERN int Rivet_InitCore(Tcl_Interp *interp); 
