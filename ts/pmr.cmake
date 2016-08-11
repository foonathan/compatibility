# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(pmr
        "#include <experimental/memory_resource>

         int main()
         {
            using namespace std::experimental::pmr;

            memory_resource* res = get_default_resource();
            polymorphic_allocator<int> alloc(res);
         }
        " COMP_CPP14_FLAG)
comp_workaround(pmr
"#include <cstddef>

#if ${COMP_PREFIX}HAS_PMR
    #include <experimental/memory_resource>
#endif

namespace ${COMP_NAMESPACE}
{
#if ${COMP_PREFIX}HAS_PMR
    using std::experimental::pmr::memory_resource;
#else
    // see N3916 for documentation
    class memory_resource
    {
        static const std::size_t max_alignment = ${COMP_PREFIX}ALIGNOF(max_align_t);
    public:
        virtual ~memory_resource() ${COMP_PREFIX}NOEXCEPT {}

        void* allocate(std::size_t bytes, std::size_t alignment = max_alignment)
        {
            return do_allocate(bytes, alignment);
        }

        void deallocate(void* p, std::size_t bytes, std::size_t alignment = max_alignment)
        {
            do_deallocate(p, bytes, alignment);
        }

        bool is_equal(const memory_resource& other) const ${COMP_PREFIX}NOEXCEPT
        {
            return do_is_equal(other);
        }

    protected:
        virtual void* do_allocate(std::size_t bytes, std::size_t alignment) = 0;

        virtual void do_deallocate(void* p, std::size_t bytes, std::size_t alignment) = 0;

        virtual bool do_is_equal(const memory_resource& other) const ${COMP_PREFIX}NOEXCEPT = 0;
    };

    inline bool operator==(const memory_resource& a, const memory_resource& b) ${COMP_PREFIX}NOEXCEPT
    {
        return &a == &b || a.is_equal(b);
    }

    inline bool operator!=(const memory_resource& a, const memory_resource& b) ${COMP_PREFIX}NOEXCEPT
    {
        return !(a == b);
    }
#endif
}" COMP_CPP11_FLAG cpp11_lang/alignof cpp11_lang/noexcept cpp11_lib/max_align_t)
