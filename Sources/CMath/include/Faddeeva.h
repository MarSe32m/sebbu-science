/* Copyright (c) 2012 Massachusetts Institute of Technology
 * 
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
 */

/* Available at: http://ab-initio.mit.edu/Faddeeva

   Header file for Faddeeva.c; see Faddeeva.cc for more information. */

#ifndef FADDEEVA_H
#define FADDEEVA_H 1

// Require C99 complex-number support
#include <complex.h>
#include "common.h"

/* Constructing complex numbers like 0+i*NaN is problematic in C99
   without the C11 CMPLX macro, because 0.+I*NAN may give NaN+i*NAN if
   I is a complex (rather than imaginary) constant.  For some reason,
   however, it works fine in (pre-4.7) gcc if I define Inf and NaN as
   1/0 and 0/0 (and only if I compile with optimization -O1 or more),
   but not if I use the INFINITY or NAN macros. */

/* __builtin_complex was introduced in gcc 4.7, but the C11 CMPLX macro
   may not be defined unless we are using a recent (2012) version of
   glibc and compile with -std=c11... note that icc lies about being
   gcc and probably doesn't have this builtin(?), so exclude icc explicitly */
#  if !defined(CMPLX) && (__GNUC__ > 4 || (__GNUC__ == 4 && __GNUC_MINOR__ >= 7)) && !(defined(__ICC) || defined(__INTEL_COMPILER))
#    define CMPLX(a,b) __builtin_complex((double) (a), (double) (b))
#  endif

#ifdef CMPLX // C11
#define C(a,b) CMPLX(a,b)
#define Inf INFINITY // C99 infinity
#ifdef NAN // GNU libc extension
# define NaN NAN
#else
# define NaN (0./0.) // NaN
#endif
#else
#ifdef _WIN32
#define C(a,b) _DCOMPLEX_(a,b)
#else
#define C(a,b) ((a) + I*(b))
#endif
#define Inf (1./0.) 
#define NaN (0./0.) 
#endif

#ifdef _WIN32
typedef _Dcomplex cmplx;
#else
typedef double complex cmplx;
#endif

typedef struct ComplexWrapper {
   double real;
   double imaginary;
} ComplexWrapper;

#define SHIM(func) \
   HEADER_SHIM ComplexWrapper func##_shim(double real, double imag, double relerr) { \
      cmplx res = func (C(real, imag), relerr); \
      ComplexWrapper result = {creal(res), cimag(res)}; \
      return result; }

// compute w(z) = exp(-z^2) erfc(-iz) [ Faddeeva / scaled complex error func ]
cmplx Faddeeva_w(cmplx z, double relerr);
SHIM(Faddeeva_w)
double Faddeeva_w_im(double x); // special-case code for Im[w(x)] of real x

// Various functions that we can compute with the help of w(z)

// compute erfcx(z) = exp(z^2) erfc(z)
cmplx Faddeeva_erfcx(cmplx z, double relerr);
SHIM(Faddeeva_erfcx)
double Faddeeva_erfcx_re(double x); // special case for real x

// compute erf(z), the error function of complex arguments
cmplx Faddeeva_erf(cmplx z, double relerr);
SHIM(Faddeeva_erf)
double Faddeeva_erf_re(double x); // special case for real x

// compute erfi(z) = -i erf(iz), the imaginary error function
cmplx Faddeeva_erfi(cmplx z, double relerr);
SHIM(Faddeeva_erfi)
double Faddeeva_erfi_re(double x); // special case for real x

// compute erfc(z) = 1 - erf(z), the complementary error function
cmplx Faddeeva_erfc(cmplx z, double relerr);
SHIM(Faddeeva_erfc)
double Faddeeva_erfc_re(double x); // special case for real x

// compute Dawson(z) = sqrt(pi)/2  *  exp(-z^2) * erfi(z)
cmplx Faddeeva_Dawson(cmplx z, double relerr);
SHIM(Faddeeva_Dawson)
double Faddeeva_Dawson_re(double x); // special case for real x

#endif // FADDEEVA_H
