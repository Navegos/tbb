/*
    Copyright (c) 2005-2020 Intel Corporation

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

#if DO_ITT_NOTIFY

#if _WIN32||_WIN64
    #ifndef UNICODE
        #define UNICODE
    #endif
#else
    #pragma weak dlopen
    #pragma weak dlsym
    #pragma weak dlerror
#endif /* WIN */

#if __TBB_BUILD

extern "C" void ITT_DoOneTimeInitialization();
#define __itt_init_ittlib_name(x,y) (ITT_DoOneTimeInitialization(), true)

extern "C" void MallocInitializeITT();
#elif __TBBMALLOC_BUILD

extern "C" void MallocInitializeITT();
#define __itt_init_ittlib_name(x,y) (MallocInitializeITT(), true)

extern "C" void ITT_DoOneTimeInitialization();

#elif __IRML_BUILD

extern "C" void RmlInitializeITT();
#define __itt_init_ittlib_name(x,y) (RmlInitializeITT(), true)
#else
#error This file is expected to be used for either TBB or TBB allocator build.
#endif // __TBB_BUILD

#include "tools_api/ittnotify_static.c"

namespace tbb {
namespace internal {
int __TBB_load_ittnotify() {
#if !(_WIN32||_WIN64)
    // tool_api crashes without dlopen, check that it's present. Common case
    // for lack of dlopen is static binaries, i.e. ones build with -static.
    if (dlopen == NULL)
        return 0;
#endif
    return __itt_init_ittlib(NULL,          // groups for:
      (__itt_group_id)(__itt_group_sync     // prepare/cancel/acquired/releasing
                       | __itt_group_thread // name threads
                       | __itt_group_stitch // stack stitching
                       | __itt_group_structure
                           ));
}

}} // namespaces

#endif /* DO_ITT_NOTIFY */

#define __TBB_NO_IMPLICIT_LINKAGE 1
#include "itt_notify.h"

namespace tbb {

#if DO_ITT_NOTIFY
    const tchar
            *SyncType_GlobalLock = __TBB_T("TbbGlobalLock"),
            *SyncType_Scheduler = __TBB_T("%Constant")
            ;
    const tchar
            *SyncObj_SchedulerInitialization = __TBB_T("TbbSchedulerInitialization"),
            *SyncObj_SchedulersList = __TBB_T("TbbSchedulersList"),
            *SyncObj_WorkerLifeCycleMgmt = __TBB_T("TBB Scheduler"),
            *SyncObj_TaskStealingLoop = __TBB_T("TBB Scheduler"),
            *SyncObj_WorkerTaskPool = __TBB_T("TBB Scheduler"),
            *SyncObj_MasterTaskPool = __TBB_T("TBB Scheduler"),
            *SyncObj_TaskPoolSpinning = __TBB_T("TBB Scheduler"),
            *SyncObj_Mailbox = __TBB_T("TBB Scheduler"),
            *SyncObj_TaskReturnList = __TBB_T("TBB Scheduler"),
            *SyncObj_TaskStream = __TBB_T("TBB Scheduler"),
#if __TBB_PREVIEW_CRITICAL_TASKS
            *SyncObj_CriticalTaskStream = __TBB_T("TBB Scheduler"),
#endif
            *SyncObj_ContextsList = __TBB_T("TBB Scheduler")
            ;
#endif /* DO_ITT_NOTIFY */

} // namespace tbb

