# CGLib - Coding Game Library

This is a small library of functions/objects that have already proven useful
for me in solving some of the problems in [CodinGame][CG].

It is in [Raku][], which to my knowledge is not supported in [CodinGame][]; it
starts as an attempt to *translate* [cglib-perl][] actually, for study and fun.

The code is not particularly robust nor readable. Actually, the design
follows the following guidelines:

- aim for easy cut-and-paste, as I often just include functions in the
  solutions (which boil down to a single file anyway)
- privilege compactness where possible
- do only minimal parameters checking, assume that the usage will be
  "correct". This is a valid assumption while solving problems in [CG][]
  where you retain full control
- avoid `Carp`/`croak` even if useful. This is again in the spirit of
  easier cut-and-paste, even though `croak` is actually the best option
  inside a library instead of `die`
- use `Exporter` - its presence does not get in the way of easy
  copy-pasting anyway

A lot of the code would not be here were it not for the excellent courses
on Algorithms by Robert Sedgewick and Kevin Wayne as found on Coursera.
Their [mini-site][algs4] about the book is invaluable.

Copyright (C) 2021 by Flavio Poletti <polettix@cpan.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

> [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

[CG]: https://www.codingame.com/
[algs4]: https://algs4.cs.princeton.edu/code/
[cglib-perl]: https://github.com/polettix/cglib-perl
[Raku]: https://raku.org/
