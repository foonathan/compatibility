# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(two_range_algorithms
        "#include <algorithm>

        int main()
        {
            int a[] = {1, 2, 3};
            int b[] = {3, 2, 1};
            bool eq = std::equal(a, a + 3, b, b + 3);
            std::mismatch(a, a + 3, b, b + 3);
            bool per = std::is_permutation(a, a + 3, b, b + 3);
        }" COMP_CPP14_FLAG)
comp_workaround(two_range_algorithms
"#include <algorithm>
#include <iterator>

namespace ${COMP_NAMESPACE}
{
    template <class Iter1, class Iter2>
    std::pair<Iter1, Iter2> mismatch(Iter1 first1, Iter1 last1, Iter2 first2, Iter2 last2)
    {
#if ${COMP_PREFIX}HAS_TWO_RANGE_ALGORITHMS
        return std::mismatch(first1, last1, first2, last2);
#else
        // taken from cppreference.com
        while (first1 != last1 && first2 != last2 && *first1 == *first2)
            ++first1, ++first2;
        return std::make_pair(first1, first2);
#endif
    }

    template <class Iter1, class Iter2, class Pred>
    std::pair<Iter1, Iter2> mismatch(Iter1 first1, Iter1 last1, Iter2 first2, Iter2 last2, Pred pred)
    {
#if ${COMP_PREFIX}HAS_TWO_RANGE_ALGORITHMS
        return std::mismatch(first1, last1, first2, last2, pred);
#else
        // taken from cppreference.com
        while (first1 != last1 && first2 != last2 && pred(*first1, *first2))
            ++first1, ++first2;
        return std::make_pair(first1, first2);
#endif
    }

#if !${COMP_PREFIX}HAS_TWO_RANGE_ALGORITHMS
    namespace detail
    {
        template <class Iter1, class Iter2>
        bool equal(std::input_iterator_tag, Iter1 first1, Iter1 last1,
                   std::input_iterator_tag, Iter2 first2, Iter2 last2)
        {
            while (first1 != last1 && first2 != last2)
            {
                if (*first1 != *last2)
                    return false;
            }
            return first1 == last1 && first2 == last2;
        }

        template <class Iter1, class Iter2, class Pred>
        bool equal(std::input_iterator_tag, Iter1 first1, Iter1 last1,
                   std::input_iterator_tag, Iter2 first2, Iter2 last2, Pred p)
        {
            while (first1 != last1 && first2 != last2)
            {
                if (!p(*first1, *last2))
                    return false;
            }
            return first1 == last1 && first2 == last2;
        }

        template <class Iter1, class Iter2>
        bool equal(std::random_access_iterator_tag, Iter1 first1, Iter1 last1,
                   std::random_access_iterator_tag, Iter2 first2, Iter2 last2)
        {
            if (last1 - first1 != last2 - first2)
                return false;
             return std::equal(first1, last1, first2);
        }

        template <class Iter1, class Iter2, class Pred>
        bool equal(std::random_access_iterator_tag, Iter1 first1, Iter1 last1,
                   std::random_access_iterator_tag, Iter2 first2, Iter2 last2,
                   Pred p)
        {
            if (last1 - first1 != last2 - first2)
                return false;
             return std::equal(first1, last1, first2, p);
        }
    }
#endif

    template <class Iter1, class Iter2>
    bool equal(Iter1 first1, Iter1 last1, Iter2 first2, Iter2 last2)
    {
#if ${COMP_PREFIX}HAS_TWO_RANGE_ALGORITHMS
        return std::equal(first1, last1, first2, last2);
#else
        return detail::equal(typename std::iterator_traits<Iter1>::iterator_category{}, first1, last1,
                             typename std::iterator_traits<Iter2>::iterator_category{}, first2, last2);
#endif
    }

    template <class Iter1, class Iter2, class Pred>
    bool equal(Iter1 first1, Iter1 last1, Iter2 first2, Iter2 last2, Pred pred)
    {
#if ${COMP_PREFIX}HAS_TWO_RANGE_ALGORITHMS
        return std::equal(first1, last1, first2, last2, pred);
#else
        return detail::equal(typename std::iterator_traits<Iter1>::iterator_category{}, first1, last1,
                             typename std::iterator_traits<Iter2>::iterator_category{}, first2, last2,
                             pred);
#endif
    }

    template <class Iter1, class Iter2>
    bool is_permutation(Iter1 first1, Iter1 last1, Iter2 first2, Iter2 last2)
    {
#if ${COMP_PREFIX}HAS_TWO_RANGE_ALGORITHMS
        return std::is_permutation(first1, last1, first2, last2);
#else
        if (std::distance(first1, last1) != std::distance(first2, last2))
            return false;
        return std::is_permutation(first1, last1, first2);
#endif
    }

    template <class Iter1, class Iter2, class Pred>
    bool is_permutation(Iter1 first1, Iter1 last1, Iter2 first2, Iter2 last2, Pred pred)
    {
#if ${COMP_PREFIX}HAS_TWO_RANGE_ALGORITHMS
        return std::is_permutation(first1, last1, first2, last2, pred);
#else
        if (std::distance(first1, last1) != std::distance(first2, last2))
            return false;
        return std::is_permutation(first1, last1, first2, pred);
#endif
    }
}" COMP_CPP98_FLAG)

if(COMP_API_VERSION VERSION_GREATER 1.0)
    comp_sd6_macro(two_range_algorithms __cpp_lib_robust_nonmodifying_seq_ops 201304)
endif()

comp_unit_test(two_range_algorithms
""
"
using namespace ${COMP_NAMESPACE};

int a[] = {1, 2, 3};
int b[] = {3, 1, 2};
int c[] = {1, 2, 3, 4};

SECTION(\"equal\")
{
    REQUIRE(equal(a, a + 0, b, b + 0));
    REQUIRE(equal(a, a + 3, a, a + 3));
    REQUIRE(!equal(a, a + 3, b, b + 3));
    REQUIRE(!equal(a, a + 3, c, c + 4));
}
SECTION(\"equal predicate\")
{
    REQUIRE(${COMP_NAMESPACE}::equal(a, a + 0, b, b + 0, std::not_equal_to<int>{}));
    REQUIRE((!${COMP_NAMESPACE}::equal(a, a + 3, a, a + 3, std::not_equal_to<int>{})));
    REQUIRE(${COMP_NAMESPACE}::equal(a, a + 3, b, b + 3, std::not_equal_to<int>{}));
    REQUIRE((!${COMP_NAMESPACE}::equal(a, a + 3, c, c + 4, std::not_equal_to<int>{})));
}

SECTION(\"is_permutation\")
{
    REQUIRE(is_permutation(a, a + 0, b, b + 0));
    REQUIRE(is_permutation(a, a + 3, a, a + 3));
    REQUIRE(is_permutation(a, a + 3, b, b + 3));
    REQUIRE(!is_permutation(a, a + 3, c, c + 4));
}

SECTION(\"mismatch\")
{
    std::pair<int*, int*> mm;

    mm = mismatch(a, a + 0, b, b + 0);
    REQUIRE(mm.first == a);
    REQUIRE(mm.second == b);

    mm = mismatch(a, a + 3, a, a + 3);
    REQUIRE(mm.first == a + 3);
    REQUIRE(mm.second == a + 3);

    mm = mismatch(a, a + 3, b, b + 3);
    REQUIRE(mm.first == a);
    REQUIRE(mm.second == b);

    mm = mismatch(a, a + 3, c, c + 4);
    REQUIRE(mm.first == a + 3);
    REQUIRE(mm.second == c + 3);
}
SECTION(\"mismatch predicate\")
{
    std::pair<int*, int*> mm;

    mm = ${COMP_NAMESPACE}::mismatch(a, a + 0, b, b + 0, std::not_equal_to<int>{});
    REQUIRE(mm.first == a);
    REQUIRE(mm.second == b);

    mm = ${COMP_NAMESPACE}::mismatch(a, a + 3, a, a + 3, std::not_equal_to<int>{});
    REQUIRE(mm.first == a);
    REQUIRE(mm.second == a);

    mm = ${COMP_NAMESPACE}::mismatch(a, a + 3, b, b + 3, std::not_equal_to<int>{});
    REQUIRE(mm.first == a + 3);
    REQUIRE(mm.second == b + 3);

    mm = ${COMP_NAMESPACE}::mismatch(a, a + 3, c, c + 4, std::not_equal_to<int>{});
    REQUIRE(mm.first == a);
    REQUIRE(mm.second == c);
}")
