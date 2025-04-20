#pragma once

#if defined(__APPLE__)
#define OPENBLAS_OS_DARWIN
#elif defined(_WIN32)
#define OPENBLAS_OS_WINNT
#include "openblas_config_windows.h"
#elif defined(__linux__)
#define OPENBLAS_OS_LINUX
#include "openblas_config_linux.h"
#else
#warning("Unsupported platform")
#endif