
/*
    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.
*/

#ifndef _MOD_RIVET_COMMON_
#define _MOD_RIVET_COMMON_

EXTERN int Rivet_chdir_file (const char *file);
EXTERN int Rivet_CheckType (request_rec* r);
EXTERN void Rivet_CleanupRequest(request_rec *r);
EXTERN void Rivet_InitServerVariables(Tcl_Interp *interp, apr_pool_t *pool);
EXTERN void Rivet_CreateCache (server_rec *s, apr_pool_t *p);
EXTERN void Rivet_Panic TCL_VARARGS_DEF(CONST char *, arg1);

#endif
