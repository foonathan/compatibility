# Compatibility

[![Build Status](https://travis-ci.org/foonathan/compatibility.svg?branch=master)](https://travis-ci.org/foonathan/compatibility)

This library provides an advanced `target_compile_features()` and `write_compiler_detection_header()`.
The problem with those is that they are controlled via a CMake internal database, which has to be kept manually up-to-date.
This version uses `check_cxx_source_compiles()` instead and is such automatically up-to-date - a compiler supports a feature,
if the test code compiles.

Based on the test results, a header file is generated that stores the result and often workaround code,
for example a `CONSTEXPR` macro that is `constexpr`, if supported, and `const` otherwise,
to use the features anyway.

It also provides the automatic standard deduction from `target_compile_features()` to activate the right standard.

## Example

If you only want the C++ standard activation, simply `include()` `comp_base.cmake` and replace `target_compile_features()` by `comp_compile_features()`.

This is a `CMakeLists.txt` for a more advanced usage:
```
# suppose we have a target 'tgt'
include(your/dir/to/comp_base.cmake) # only file you need to download, rest is taken as needed

# we want constexpr, noexcept, std::max_align_t and rtti_support
# instead of cpp11_lang/constexpr and cpp11_lang/noexcept, you could also write cxx_constexpr/cxx_noexcept
comp_target_features(tgt PUBLIC cpp11_lang/constexpr cpp11_lang/noexcept cpp11_lib/max_align_t env/rtti_support)
```

For convenience we include all generated files in a header named `config.hpp`.
The filenames are made available through macros.

```cpp
#ifndef CONFIG_HPP
#define CONFIG_HPP

#include COMP_CONSTEXPR_HEADER
#include COMP_NOEXCEPT_HEADER
#include COMP_MAX_ALIGN_T_HEADER
#include COMP_RTTI_SUPPORT_HEADER

#endif
```

And then we can use it just by including `config.hpp` in our code:

```cpp
#include "config.hpp"

// use a workaround macro
COMP_CONSTEXPR int i = 0;

void func() COMP_NOEXCEPT
{
    // use a workaround typedef
    comp::max_align_t foo;

    // or conditional compilation
#if COMP_HAS_RTTI_SUPPORT
    do_sth();
#endif
}
```

If you don't care about the workarounds, but just want a specific standard, simply call:
```
comp_target_features(tgt PUBLIC CPP11) # or CPP14 or CPP17
```
This will only activate C++11/14/17 without doing anything else.

*Note: The standard activation is always `PRIVATE` to allow users of a library to have a different (higher) standard than the library.*

## Usage

The only file needed is `comp_base.cmake`.
You can either manually download it, use CMakes `file(DOWNLOAD` facility,
or use git submodules.
The branch `git-submodule` only contains `comp_base.cmake` and is thus perfect for this purpose.
Run `git submodule add -b "git-submodule" https://github.com/foonathan/compatibility.git` to initialize it and fetch the file.
Then you only need to run `git submodule update --remote` to update it to the newest version.

`include()` it in your `CMakeLists.txt` now.
First it generates CMake options - `COMP_CPP11_FLAG`, `COMP_CPP14_FLAG` and `COMP_CPP17_FLAG` - storing the calculated compiler flag for a given standard,
useful if you want to override it, if it can't find one for your compiler.
It also provides the following function:

    comp_target_features(<target> <PRIVATE|PUBLIC|INTERFACE> <features...>
                         [NOPREFIX | PREFIX <prefix] [NAMESPACE <namespace>]
                         [CMAKE_PATH <path>] [INCLUDE_PATH <include_path>]
                         [NOFLAGS | CPP11 | CPP14 | CPP17])

Ignoring all the other options, it is like `target_compile_features()`.
It takes a list of features to activate for a certain target.
A features is a file in this repository without the `.cmake` extension, e.g. `cpp11_lang` for all C++11 language features,
or `cpp14_lang/deprecated` for the C++14 deprecated features.

A feature file with name `dir/xxx.cmake` belonging to a feature `dir/xxx` consists of the following,
where `dir` is the category of the feature, `xxx` the feature name in lowercase, `XXX` the feature name in upper case `<PREFIX>` the prefix as given to the function, `<prefix>` the prefix in lowercase and without a trailing underscore:

* a test testing whether or not the compiler supports this feature

* a CMake option with name `COMP_HAS_XXX` to override its result, useful if you want to act like it doesn't support a feature,
or if the test is poorly written (please contact me in this case!)

* a header named `<prefix>/xxx.hpp`.
The header contains at least a macro `<PREFIX>HAS_XXX` with the same value as the CMake option
and often workaround macros or functions that can be used instead of the feature.
The workaround uses either the feature, if it is available, or own code.
This allows using many new features already, without support.
If the compiler gets support, you will be automatically using the native feature or the standard library implementation.

* a globally available macro named `<PREFIX>_XXX_HEADER` to include the header file.

To use the generated header files, simply write `#include <PREFIX>_XXX_HEADER` inside your code, the macro is made available automatically (you could also `#incluce` the file directly but this is not recommended).

What `comp_target_features` function actually does is the following:

* For each feature, it downloads the latest version of the test file from Github, if it doesn't exist yet.
The remote url can be set via the option `COMP_REMOTE_URL`.

* For each feature, it calls `include(feature.cmake)` after some set up. This runs the test and generates the header file.

* It calls `target_include_directories` to allow including the generated header files
and `target_compile_definitions` for the file macro.
The `INTERFACE/PUBLIC/PRIVATE` specifier are only used in these calls.

* Activates the right C++ standard. E.g., if a feature requires C++11, it will be activated if it is available. If it is not, it will only activate the C++ standard required by the workaround code. This activation is always `PRIVATE`.

The behavior can be customized with the other options:

* `NOPREFIX`/`PREFIX`: The prefix of any generated macros or none if `NOPREFIX` is set. Default is `COMP_`.

* `NAMESPACE`: The namespace name of any generated code, default is `comp`. A given prefix must always use the same namespace name!

* `CMAKE_PATH`/`INCLUDE_PATH`: The download destination for the CMake files/the destination of the generated headers,
default is `${CMAKE_BINARY_DIR}/comp.downloaded` for cmake and `${CMAKE_BINARY_DIR}/comp.generated` for the headers.
`INCLUDE_PATH` is also given to `target_include_directories()`, but note that the generated headers are in a subfolder `<prefix>` (this cannot be changed).

* `NOFLAGS`/`CPP11`/`CPP14`/`CPP17`: Override for the standard detection, if you want to have a newer standard than deduced from the features,
or a lower (not recommended). They have priority over the deduction, C++17 over C++14 over C++11.
Specify `NOFLAGS` if you do not want to have any compiler flags set.
The latter is useful for `INTERFACE` libraries which are only there to run the tests and generate the options and headers.

## Feature Reference

A feature named `dir/xxx` is tested in `xxx.cmake`, defines an override CMake option `COMP_HAS_XXX` and a macro `<PREFIX>HAS_XXX` in a file named `<prefix>/xxx.hpp` (where `prefix` is `<PREFIX>` in lowercase without a trailing underscore), filename also made available over the global macro `<PREFIX>XXX_HEADER`.

There are also alternative names for the CMake `target_compile_features()` and SD-6 Feature Test Recommondations that are automatically translated.
Where appropriate, it will also generate the SD-6 feature macro as specified.
This will override the existing value if the new one is greater or the macro `COMP_OVERRIDE_SD6` is defined.
If a feature is not supported, it will not change or define anything.

For some features, macros are generated that can be used instead (i.e. for `noexcept`), they have the form `<PREFIX>XXX`.
Those macros often use compiler extensions.
If there is none (or a lacking implementation...), an error message will be emmitted.
To prevent this, simply define the macro as no-op or as you want prior to including the file.

There are often workaround functions for library features. Those are defined in a namespace and either use the own implementation or the standard library implementation, if it is available.

Prefix and namespace name can be controlled via parameters, see above.
A given prefix must always use the same namespace name on each call.

This library currently tests for the following features.
The code below assumes no prefix and a namespace name of `comp`.

*A feature will only be included if it is not a pure syntactic feature (like `auto` or lambdas which can be avoided) but if there is either sensible workaround code, e.g. through to compiler extensions or through reimplementing (small!) standard library functionality, or there can be conditional compilation based on the existense, e.g. optional literal definitions or move constructors.*

### C++11 language features

These features are all in the subdirectory `cpp11_lang`.

feature name|alternative name|example|workaround, if any
------------|----------------|-------|------------------
alias_template|cxx_alias_templas|`template <typename T> using my_map = std::map<int, T>;`|no workaround
alignas|cxx_alignas|`alignas(int) char c`|`ALIGNAS(x)`, fallback to compiler extension, if available
alignof|cxx_alignof|`alignof(int)`|`ALIGNOF(x)`, fallback to compiler extension, if available
constexpr|cxx_constexpr|`constexpr int foo()`|`CONSTEXPR`, fallback to `const`; `CONSTEXPR_FNC`, fallback to `inline`
decltype|cxx_decltype|`decltype(a)`|`DECLTYPE(x)`, fallback to `typeof` extension, if available
delete_fnc|cxx_deleted_functions|`void foo() = delete;`|no workaround
explicit_conversion_op|cxx_explicit_conversion|`explicit operator bool()`|no workaround
final|cxx_final|`void bar() final;`|`FINAL` macro, workaround expands to nothing
inline_namespace|none|`inline namespace foo {...}`|no workaround
literal_op|cxx_user_literals|`operator""`|no workaround
noexcept|cxx_noexcept|`void foo() noexcept;`|`NOEXCEPT`, fallback to nothing; `NOEXCEPT_IF(x)`, fallback to nothing; `NOEXCEPT_OP(x)`, fallback to `false`
noreturn|none|`[[noreturn]] void foo();`|`NORETURN`, fallback to compiler extension, if available
nullptr|cxx_nullptr|`void* ptr = nullptr;`|`NULLPTR`, fallback to [null pointer idiom](https://en.wikibooks.org/wiki/More_C%2B%2B_Idioms/nullptr); also `comp::nullptr_t`
override|cxx_override|`void bar() override;`|`OVERRIDE`, fallback to nothing
rvalue_ref|cxx_rvalue_references|`int&& a = 4;`|no workaround
static_assert|cxx_static_assert|`static_assert(std::is_integral<T>::value, "");`|`STATIC_ASSERT(Expr, Msg)`, fallback to simple undefined struct technique
thread_local|cxx_thread_local|`thread_local int i;`|`THREAD_LOCAL`, fallback to `__thread` extension or similar, if available - **does not call constructors or destructors!**

*Note: In general, it assumes proper C++11 support. The workarounds defined in this library rely on all common C++ features that can not be easily avoided (like `auto` or lambdas), except those listed here with a proper fallback (like `noexcept`, `constexpr`, ...).*

Get them all by specifying `cpp11_lang`..

### C++11 library features

These features are all in the subdirectory `cpp11_lib`.

feature name|example|workaround, if any
------------|-------|------------------
get_new_handler|`std::get_new_handler()`|`comp::get_new_handler()`, fallback to old `std::set_new_handler(nullptr)` technique - **not thread safe**
get_terminate|`std::get_terminate()`|`comp::get_terminate()`, same as above
is_trivially|`std::is_trivially_XXX<T>`|`comp::is_trivially_XXX`, workaround uses `std::is_XXX` combined with `std::is_trivial`
max_align_t|`std::max_align_t`|`comp::max_align_t`, fallback to `::max_align_t` or a struct with a `long double` and `long long`
mutex|`std::mutex`/`std::lock_guard`/`std::unique_lock`|no workaround
to_string|`std::to_string(54)`|`comp::to_string()`, fallback to `std::sprintf()`

*Note: It only checks for minor features where an easy workaround implementation is feasible in the scope of this library.*

Get them all by specifying `cpp11_lib`.

### C++14 language features \[complete\]

These features are all in the subdirectory `cpp14_lang`.

paper|feature name|alternative name|example|workaround, if any
-----|------------|----------------|-------|------------------
[N3760](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2013/n3760.html)|deprecated|cxx_attribute_deprecated|`[[deprecated]] int foo();`|`DEPRECATED` and `DEPRECATED(Msg)`, fallback to compiler attribute, if available
[N3652](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2013/n3652.html)|general_constexpr|cxx_relaxed_constexpr|generalized constexpr|no workaround
[N3638](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2013/n3638.html)|return_type_deduction|none|auto return type deduction for normal functions|`AUTO_RETURN` macro
[N3778](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2013/n3778.html)|sized_deallocation|none|`void operator delete(void *ptr, std::size_t size)`|no workaround
[N3651](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2013/n3651.html)|variable_template|cxx_variable_templates|`template <typename T> T pi;`|no workaround

Get them all by specifying `cpp14_lang`.

The following features are not and will never be supported:

paper|description|reason
-----|-----------|------
[N3323](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2012/n3323.pdf)|Tweak Certain C++ Contextual Conversions|difficult to check, avoid relying on behavior
[N3472](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2012/n3472.pdf)|Binary Literals|syntax sugar only
[N3648](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2013/n3648.html)|Generalized Lambda Capture|lambdas are syntax sugar only
[N3649](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2013/n3649.html)|Generic Lambdas|lambdas are syntax sugar only
[N3653](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2013/n3653.html)|Member initializers and aggregates|difficult to check, no big user impact
[N3664](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2013/n3664.html)|Clarifying Memory Allocation|wording change only
[N3781](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2013/n3781.pdf)|Digit seperator for literals|syntax sugar only

### C++14 library features \[complete\]

These features are all in the subdirectory `cpp14_lib`.

paper|feature name|example|workaround, if any
--------|------------|-------|------------------
[N3668](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2013/n3668.htm)|exchange|`std::exchange()`|`comp::exchange()`, own implementation
[N3421](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2012/n3421.html)|generic_operator_functors|`std::greater<>{}`|`comp::greater{}` and the rest, no class templates!
[N3658](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2013/n3658.html)|integer_sequence|`std::index_sequence<4>`|`comp::index_sequence<4>` and co, own implementation
[N3656](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2013/n3656.htm)|make_unique|`std::make_unique()`|`comp::make_unique`, own implementation
[N3654](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2013/n3654.html)|quoted|`ss >> std::quoted(str)`|no workaround, use boost
[N3659](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2013/n3659.html)|shared_lock|`std::shared_lock<std::shared_timed_mutex>`|no workaround
[N3671](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2013/n3671.html)|two_range_algorithm|`std::equal(first1, last1, first2, last2)`|`comp::equal()`/`comp::mismatch()`/`comp::is_permutation()`, own implementation

Get them all by specifying `cpp14_lib`.

The following features are not and will never be supported:

paper|description|reason
-----|-----------|------
[N3668](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2013/n3669.pdf)|Fixing constexpr member functions without const|workaround not possible, just avoid relying on that behavior
[N3670](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2013/n3670.htm)|Addressing Tuples by Type|just use index version
[N3462](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2012/n3462.html)|std::result_of and SFINAE|impossible to check
[N3545](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2013/n3545.html)|operator() for std::integral_constant|just "syntax" sugar
[N3642](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2013/n3642.pdf)|UDl's for standard library|just "syntax" sugar
[N3469](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2012/n3469.html)|Constexpr for std::chrono|no great workaround possible
[N3470](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2012/n3470.html)|Constexpr for std::array|no great workaround possible
[N3471](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2012/n3471.html)|Constexpr for utilities|no great workaround possible
[N3657](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2013/n3657.html)|Heterogeneous lookup|optimization only, workaround for transparent functors supports this extension
[N3655](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2013/n3655.pdf)|Alias templates for traits|just "syntax" sugar

### C++17 language features

These features are all in the subdirectory `cpp17_lang`.

paper|feature name|example|workaround, if any
-----|------------|-------|------------------
[N4295](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2014/n4295.html)|fold_expressions|`return (args && ....);`|no workaround
[N3928](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2014/n3928.pdf)|terse_static_assert|`static_assert(condition);`|`TERSE_STATIC_ASSERT(Cond)` macro
[N4267](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2014/n4267.html)|utf8_char_literal|`char c = u8'A';`|`UTF8_ChAR_LITERAL(Str)` macro taking a normal string, appending `u8` prefix and converting it to a character

### C++17 library features \[up-to-date\]

These features are all in the subdirectory `cpp17_lib`.

paper|feature name|example|workaround, if any
-----|------------|-------|------------------
[N4389](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2015/n4389.html)|bool_constant|`std::bool_constant`|`comp::bool_constant`
[N4280](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2014/n4280.pdf)|container_access|`std::size(cont)`|`comp::size(cont)`, likewise for `std::empty()`/`std::data()`
[N4169](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2014/n4169.html)|invoke|`std::invoke(f)`|`comp::invoke(f)`
[N4279](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2014/n4279.html)|map_insertion|`m.try_emplace(key, value)`|`comp::try_emplace(m, key, value)`, likewise for `insert_or_assign()`
[N4508](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2015/n4508.html)|shared_mutex|`std::shared_mutex`|no workaround
[N4259](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2014/n4259.pdf)|uncaught_exceptions|`std::uncaught_exceptions()`|no workaround, note the plural!
[N3911](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2014/n3911.pdf)|void_t|`std::void_t<int, char>`|`comp::void_t<int, char>`

Get them all by specifying `cpp17_lib`.

The following features are not and will never be supported:

paper|description|reason
-----|-----------|------
[N4190](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2014/n34190.htm)|Removing deprecated things|removal, just don't use it
[N4284](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2014/n4284)|Contiguous iterator|no actual code change
[N4089](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2014/n4089.pdf)|Conversion for `std::unique_ptr<T[]>`|difficult to check, avoid relying on behavior
[N4277](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2014/n4277.html)|TriviallyCopyable `std::reference_wrapper`|difficult to check, avoid relying on behavior
[N4258](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2014/n4258.pdf)|Cleaning-up `noexcept`|difficult to check, no big impact on user
[N4266](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2015/n4266.html)|Missing SFINAE rule in `std::unique_ptr`|difficult to check, no big impact on code, avoid relying on behavior
[N4387](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2015/n4387.html)|Improving constructor `std::pair` and `std::tuple`|difficult to check, avoid relying on behavior
[N4510](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2015/n4510.html)|Minimal incomplete type support for containers|difficult to check, avoid relying on behavior

### Technical specifications

The technical specifications for the C++ standard library.
These features are all in the subdirectory `ts`.

paper|feature name|description|workaround, if any
-----|------------|-----------|------------------
[N3804](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2013/n3804.html)|any|`std::experimental::any` class|none, use boost or other implementation
[N3915](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2014/n3915.pdf)|apply|`std::experimental::apply(f, tuple)`|`comp::apply()`, own implementation
[N4273](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2014/n4273.htm)|container_erausre|`std::experimental::erase_if(vector, pred)`|`comp::erase_if()`/`comp::erase()`, own implementation
[P0013R1](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2015/p0013r1.html)|logical_operator_traits|`std::experimental::disjunction`|`comp::conjunction`/`comp::disjunction`/`comp::negation`, own implementation
[N4391](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2015/n4391.html)|make_array|`std::experimental::make_array()`|`comp::make_array()`/`comp::to_array()`, own implementation
[N4076](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2014/n4076.html)|not_fn|`std::experimental::not_fn()`|`comp::not_fn()`, own implementation
[N3793](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2013/n3793.html)|optional|`std::experimental::optional`|none, use boost or other implementation
[N3916](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2014/n3916.pdf)|pmr|Polymorphic memory resource|only `comp::memory_resource` base class
[N3921](http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2014/n3921.html)|string_view|`std::experimental::string_view`| none, use other implementation

Get them all by specifying `ts`.

### Environment

Features regarding the general environment. These features are all in the subdirectory `env`.
Note: These checks here aren't that great, it is recommended to set option explicitly.

feature name|description|workaround, if any
------------|-------|------------------
exception_support|support for exception handling|`THROW(Ex)`, `RETHROW_EX`, fallback to `std::abort()`; `TRY`, fallback to `if (true)`, CATCH_ALL, fallback to `if (false)`
hosted_implementation|freestanding vs hosted|alias macro `HOSTED_IMPLEMENTATION`, implementation of `std::swap()` and `std::move()`/`std::forward()` (if rvalue references are supported); those are otherwise not available
rtti_support|support for RTTI|`comp::polymorhpic_cast`, fallback to `static_cast`
threading_support|support for threading|no workaround

Get them all by specifying `env`.

### Common extensions

These features are all in the subdirectory `ext`.

feature name|example|workaround, if any
------------|-------|------------------
assume|`__assume(cond)` (from MSVC)|`ASSUME(x)`, fallback to nothing
bswap|`__builtin_bswap(x)` (from GCC)|``comp::bswap(x)` (for unsigned fixed-sized integers), fallback to manual swap (constexpr)
clz|`__builtin_clz(x)` (from GCC)|`comp::clz(x)` (for unsigned fixed-sized integers), fallback to binary search (constexpr)
counter|`__COUNTER__` (most compilers)|no workaround
ctz|`__builtin_ctz(x)` (from GCC)|`comp::ctz(x)` (for unsigned integers), fallback to binary search (constexpr)
expect|`__builtin_expect(x, val)` (from GCC)|`EXPECT(x, val)` (and `LIKELY(cond)`,`UNLIKELY(cond)`), fallback to value itself
extension|`__extension__` (from GCC, marks extensions to silence warnings)|`EXTENSION`, fallback to nothing
fallthrough|`[[clang::fallthrough]]` (from clang)|`FALLTHROUGH`, fallback to nothing
has_include|`__has_include(header)`|`HAS_INCLUDE(x)`, fallback to always `0`
int128|`__int128` (from GCC)|`comp::(u)int128_t`, no workaround, just convenience typedefs
popcount|`__builtin_popcount(x)` (from GCC)|`comp::popcount(x)` (for unsigned integers), fallback to bithacks (constexpr)
pretty_function|`__PRETTY_FUNCTION__` (from GCC)|`PRETTY_FUNCTION`, fallback to `__FUNCSIG__` on MSVC
unreachable|`__builtin_unreachable()` (from GCC)|`UNREACHABLE`, fallback to `__assume(0)` under MSVC, otherwise nothing
unused|`[[gnu::unused]]` (from GCC)|`UNUSED`, fallback to nothing; also `MAKE_UNUSED(expr)` that uses `(void)` trick

Get them all by specifying `ext.cmake`.

## Contribution

As you probably noted, there are features missing.
I wrote this library in a few hours and concentrated on the most important features for me.
If you want to extend it or improve a workaround, please don't hesitate to fork and PR
(or just write an issue and let me take care of it, when I have time, if you're lazy).

To write a new feature check, just create a new file in the appropriate subdirectory.
Note: Do **not** include `comp_base.cmake!`.

Inside the feature file you should only use the following CMake functions in the given order:

1. `comp_api_version(major[.minor[.patch]])` - checks if the API has the required version. `major` must match exactly, the rest not higher than the API version. If there is a version mismatch, it is an error.

2. `comp_feature(<name> <test_code> <standard> <required...>)` - does the feature check.
`name` is the name of the feature without the directory, e.g. `constexpr`, not `cpp11_lang/constexpr`.
`test_code` is the code that will be tested to see if the feature is supported.
`standard` is the required C++ standard, this must be one of the `COMP_CPPXX_FLAG` values or `COMP_CPP98_FLAG` if no higher standard is needed.
`required` is a list of requirede featuers that need to be supported in order to support this feature. If any of them isn't, this will not be checked.

3. `comp_workaround(<name> <workaround_code> <standard> <required...>)` - writes workaround code (optional).
`name` must be the same as in `comp_feature()`.
`workaround_code` is the workaround code itself.
It must use `${COMP_PREFIX}` for macros and put anything else into the namespace `${COMP_NAMESPACE]` (variable expansion works there, so write it exactly like that).
The result of the test is available through `${COMP_PREFIX}HAS_NAME`, e.g. `#if ${COMP_PREFIX}HAS_CONSTEXPR ... #else ... #endif`.
`standard` is like in `comp_feature()` the standard required for the workaround code (the not-supported case, the supported case gets the standard of `comp_feature()`).
`required` is a list of required features inside the workaround code. Their headers will be included prior to the workaround making it possible to use other workarounds.

4. `comp_sd6_macro(<name> <sd6_name> <value>)` - writes SD 6 macro (optional, since 1.1).
`name` must be the same as in `comp_feature()`.
`sd6_name` is the SD-6 macro name and `value` its value.

5. `comp_unit_test(<name> <global_code> <test_code>)` - defines a (Catch) unit test for the workaround code (optional).
`name` must be the same as in `comp_feature()`.
`global_code` will be put into the global namespace right after the including of the appropriate feature header and catch.
`test_code` will be put into a Catch `TEST_CASE()`.

The code for feature checking should be minimal and do not depend on any other advanced features (for example, do not use `auto` or `nullptr`) to prevent false failure.
The workaround shouldn't use advanced features either, it can use other workarounds though.

The testing code should test the workaround. It will be run by the testing framework for both modes, supported and not supported.

Look at a few other files for example implementations.
