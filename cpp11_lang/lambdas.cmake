# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

# Taken from: 
# http://www.open-std.org/jtc1/sc22/wg21/docs/cwg_defects.html#226
comp_feature(lambdas 
    "#include <algorithm>
#include <cmath>
void abssort(float *x, unsigned N) {
  std::sort(x, x+N,
            [](float a, float b) {
              return std::abs(a) < std::abs(b);
            });
}

int main()
{
    float* arr = new float[20];
    abssort(arr, 20);
}
" COMP_CPP11_FLAG)
