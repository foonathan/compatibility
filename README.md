# Compatibility

This library consists of a bunch of CMake files that can be included to test for C++ features.
They will also generate a header to make the result available as macro and workaround code - like a `CONSTEXPR` macro - 
for portable use.
In addition, it provides interface libraries to activate C++11 or 14 for CMake targets.

## Usage

0\. Download the needed files (`comp_base.cmake` is always needed) and store them somewhere.

1\. In your CMakeLists.txt, `include()` all the needed files, `comp_base.cmake` first.

2\. Link to the interface library `comp_target` to setup the include directory for the files containing the macro definitions.

3\. Create a new header in your code - i.e. `compatibility.hpp` - that `#include`s `<cstddef>` (important!),
followed by all the generated headers you want. A macro can be overriden by defining it prior to the `#include`.

Example for a target that needs C++11 and wants compatibility for `noexcept`, `constexpr` and `std::max_align_t`:
```
add_executable(target ...)

include(your/dir/comp_base.cmake)
include(your/dir/cpp_standard.cmake) # for comp_cpp11
include(your/dir/cpp11_lang/noexcept.cmake)
include(your/dir/cpp11_lang/constexpr.cmake)
include(your/dir/cpp11_lib/max_align_t.cmake)
target_link_libraries(target PUBLIC comp_target comp_cpp11) # comp_cpp11 activates C++11 for me, see next section
```

And the header file, let's name it `config.hpp`:

```cpp
#ifndef CONFIG_HPP
#define CONFIG_HPP

#include <cstddef>

#include <comp/noexcept.hpp>
#include <comp/constexpr.hpp>
#include <comp/max_align_t.hpp>

#endif
```

Usage like so:

```cpp
#include "config.hpp"

// use workaround macro, if there is one
COMP_CONSTEXPR_FNC int foo() {...}

// or make conditional compilation (although for noexcept is a macro)
#if COMP_HAS_NOEXCEPT
    ...
#endif

// or use workaround code in namespace
comp::max_align_t max_align;
```

## C++11/14 Activation

File `cpp_standard.cmake` also defines two interface libraries, `comp_cpp11` and `comp_cpp14`.
Link to them to activate C++11 or 14, respectively.
They simply activate the appropriate flag, also available directly via `cpp11_flag` or `cpp14_flag`.

It is recommended, to only link `PRIVATE` to them, even for libraries.
This allows the user of a library to choose a higher standard than the library themselves.
For example, if a library wants C++11 and enforces it by publically linking to `comp_cpp11`,
a client cannot easily enable C++14.
The better way is to let the client decide which standard to use by explicitly linking.

## Feature Checks

A feature named `xxx` is tested in `xxx.cmake`, defines an override CMake option `COMP_HAS_XXX` and a macro `{PREFIX}HAS_XXX` in a file named `xxx.hpp`.

For some features, macros are generated that can be used instead (i.e. for `noexcept`), they have the form `{PREFIX}XXX`. Those macros often use compiler extensions. If there is none (or a lacking implementation...), an error message will be emmitted. To prevent this, simply define the macro as no-op or as you want prior to including the file.

Prefix and namespace name can be controlled via the CMake options `COMP_PREFIX` (default: `COMP_`) and `COMP_NAMESPACE` (default: `comp`).

*To use a C++11 or 14 feature, the target must obviously activate C++11 or 14!*

This library currently tests for the following features.
The code below assumes no prefix and a namespace name of `comp`.

### C++11 language features:

feature name|example|workaround, if any
------------|-------|------------------
alignof|`alignof(int)`|`ALIGNOF(x)`, fallback to compiler extension, if available
constexpr|`constexpr int foo()`|`CONSTEXPR`, fallback to `const`, `CONSTEXPR_FNC`, fallback to `inline`
decltype|`decltype(a)`|`DECLTYPE(x)`, fallback to `typeof` extension, if available
delete_fnc|`void foo() = delete;`|no workaround
literal_op|`operator""`|no workaround
noexcept|`void foo() noexcept;`|`NOEXCEPT`, fallback to nothing, `NOEXCEPT_OP(x)`, fallback to `false`
nullptr|`void* ptr = nullptr;`|`NULLPTR`, fallback to [null pointer idiom](https://en.wikibooks.org/wiki/More_C%2B%2B_Idioms/nullptr), also `comp::nullptr_t`
override|`void bar() override;`|`OVERRIDE`, fallback to nothing
rvalue_ref|`int&& a = 4;`|no workaround
static_assert|`static_assert(std::is_integral<T>::value, "");`|`STATIC_ASSERT(Expr, Msg)`, fallback to simple undefined struct technique
template_alias|`template <typename T> using my_map = std::map<int, T>;`|no workaround
thread_local|`thread_local int i;`|`THREAD_LOCAL`, fallback to `__thread` extension or similar, if available - **does not call constructors or destructors!**

Get them all by including `cpp11_lang.cmake`.

### C++11 library features:

feature name|example|workaround, if any
------------|-------|------------------
get_new_handler|`std::get_new_handler()`|`comp::get_new_handler()`, fallback to old `std::set_new_handler(nullptr)` technique - **not thread safe**
get_terminate|`std::get_terminate()`|`comp::get_terminate()`, same as above
max_align_t|`std::max_align_t`|`comp::max_align_t`, fallback to `::max_align_t` or a struct with a `long double` and `long long`

Get them all by including `cpp11_lib.cmake`.

### C++14 language features:

feature name|example|workaround, if any
------------|-------|------------------
deprecated|`[[deprecated]] int foo();`|`DEPRECATED` and `DEPRECATED(Msg)`, fallback to compiler attribute, if available
general_constexpr|generalized constexpr|no workaround
variable_template|`template <typename T> T pi;`|no workaround

Get them all by including `cpp14_lang.cmake`.

### C++14 library features:

feature name|example|workaround, if any
------------|-------|------------------
make_unique|`std::make_unique()`|`comp::make_unique`, own implementation

Get them all by including `cpp14_lib.cmake`.

### Common extensions

feature name|example|workaround, if any
------------|-------|------------------
counter|`__COUNTER__`|no workaround
pretty_function|`__PRETTY_FUNCTION__`|`PRETTY_FUNCTION`, fallback to `__FUNCSIG__` on MSVC

Get them all by including `ext.cmake`.

## Pull-Requests.

As you probably noted, there are *many* features missing.
I wrote this library in a few hours and concentrated on the most important features for me.
If you want to extend it or improve a workaround, please don't hesitate to fork and PR
(or just write an issue and let me take care of it, when I have time, if you're lazy).

To write a new feature check, just create a new file in the appropriate subdirectory.
You only need to call two CMake macros I have defined:

1. `comp_check_feature` - It takes three parameters. The first is a minimal test code that uses this feature.
It is recommended to avoid using multiple features (i.e. avoid `auto`, `nullptr` and the like).
The second parameter is the name of the feature, this should follow my naming convention.
The third is a list of required compiler flags, mostly pass `${cpp11_flag}` or `${cpp14_flag}` or `""`.

2. `comp_gen_header` - It takes two parameters. The first is the name of the feature, must be the same as above.
The second is code that will be appended to the file. It is used for workarounds.
If you define macros, wrap them in an `#ifndef ... #endif` and use `${COMP_PREFIX}` as prefix.
If you define anything else, do it inside namespace `${COMP_NAMESPACE}` or a sub namespace.

Look at a few other files for example implementations.
