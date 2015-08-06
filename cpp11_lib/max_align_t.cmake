# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

# note: using namespace std; important here, as it might not be in namespace std
comp_check_feature("#include <cstddef>
                       using namespace std;
                       int main() {max_align_t val;}" max_align_t "${cpp11_flag}")
comp_gen_header(max_align_t
"
namespace ${COMP_NAMESPACE}
{
#if ${COMP_PREFIX}HAS_MAX_ALIGN_T
    namespace max_align
    {
        using namespace std; // might not be in namespace std
        typedef max_align_t type;
    }

    typedef max_align::type max_align_t;
#else
    // this struct should have maximum alignment
    struct max_align_t
    {
        long double ld;
        long long ll;
    };
#endif
}
")
