// wgrib2/compat/win_alarm.h
#pragma once
#if defined(_WIN32) && !defined(__CYGWIN__)
/* Prototype for our Windows emulation in win_alarm.c */
unsigned int alarm(unsigned int seconds);
#endif
