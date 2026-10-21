# doctest.mk

A Makefile snippet for small C++ projects tested with
[doctest](https://github.com/doctest/doctest).

Let's `make test` great (again?).

## Motivation

When I was learning Go I read [Learn Go with Tests](https://quii.gitbook.io/learn-go-with-tests)
and it was a delightful experience to learn a new language through tests.
Since then I've wanted the same approach to learn any new language.

When I decided to (re)learn C++ I wanted to do it with tests, but became
frustrated by the amount of knowledge I needed and the number decisions had
to take just to write a simple test. A C++ newbie should be able to easily
write tests and learn the language at the same time!

Fortunately I discovered [doctest](https://github.com/doctest/doctest), which
is a C++ testing framework that is simple and easy to install. Some tooling
knowledge is still needed, but that's why I created this project here.

The `doctest.mk` tries to bring to C++ a similar experience we have in Go,
with `go test`. Just include the `doctest.mk` in your project's `Makefile`,
follow the file naming conventions (`*_test.cpp`), and `make test` will run
your tests.

## Install

**NOTE**: I'm assuming you have doctest installed. I tested with the packages
provided by Arch (`pacman -S doctest`) and Debian (`apt-get install doctest-dev`).

Save [doctest.mk](https://raw.githubusercontent.com/meleu/doctest.mk/refs/heads/main/doctest.mk)
anywhere you like, and then `include` it from your project's `Makefile`.

Here's what I do:

```sh
# create the directory
mkdir -p ~/.local/include

# downloads the file from this repo
curl -fsSL -o ~/.local/include/doctest.mk \
  https://raw.githubusercontent.com/meleu/doctest.mk/refs/heads/main/doctest.mk
```

Then, in my project's `Makefile`:

```make
include $(HOME)/.local/include/doctest.mk
```

## Usage

The role of each `.cpp` file in the project directory is defined by its name:

| File             | Role                                                  |
|------------------|-------------------------------------------------------|
| `*_test.cpp`     | Tests, linked into the test binary (doctest provides `main()`) |
| `main.cpp`       | Entry point of the application                        |
| any other `.cpp` | Domain code, linked into both the tests and the app   |

For example:

```
calc.h
calc.cpp        # domain code
calc_test.cpp   # tests for calc
main.cpp        # the application
Makefile        # just the include line
```

With that in place, `make test` builds and runs the tests, and `make run`
builds and runs the application.

See the comments in [`doctest.mk`](doctest.mk) for the available settings,
and the [`sample/`](sample/) directory for a working example.
