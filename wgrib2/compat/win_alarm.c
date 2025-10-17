#if defined(_WIN32) && !defined(__CYGWIN__)
#include <windows.h>
#include <process.h>
#include <signal.h>
#include <stdint.h>

/* MinGW lacks SIGALRM; map to something deliverable. */
#ifndef SIGALRM
#define SIGALRM SIGBREAK
#endif

static unsigned __stdcall alarm_thread(void *arg) {
    unsigned sec = (unsigned)(uintptr_t)arg;
    if (sec > 0) {
        Sleep(sec * 1000);
        raise(SIGALRM);
    }
    return 0;
}

unsigned int alarm(unsigned int seconds) {
    uintptr_t h = _beginthreadex(NULL, 0, alarm_thread,
                                 (void*)(uintptr_t)seconds, 0, NULL);
    if (h) CloseHandle((HANDLE)h);
    return 0; /* we don't track prior timers */
}
#endif
