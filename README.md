# Coverfield

One day I found a class in my ruby app with > 95% coverage in
[SimpleCov](https://github.com/colszowka/simplecov) but without any dedicated
spec. SimpleCov is an awesome tool if you want to get an idea of your test
coverage, but it has a flaw: It doesn't look whether theres a spec for a
class/module/method or not, it just reports if a line of code was executed while
the spec suite run thru. In my case a class which was used relative often so
gathered nearly 100% coverage, but I've never wrote any line of testing code
specific vor that class.

To get an overview which classes, modules and methods my test suite covers (and
more important: which not), I've wrote a small script, which scans all
production code, finds the classes and methods and checks if there are dedicated
tests for that methods whitin the specs. It compiles a report which clearly
tells me, what specs are missing.

This script is not a substitution for SimpleCov! SimpleCov is a wonderful peave
of software and it's coverage report is very important. Think of Coverfield as a
additional tool for examining the quality of your test suite under another
aspect and from a different view.

Together SimpleCov and Coverfield can tell you accurate how good or bad your
coverage really is: Coverfield tells you which methods, classes and files are
covered by specs and which not. SimpleCov then tells you how well the body of
those methods is tested and if there are edge cases which are not touched by the
test suite.



## Future

This project has still prototype character and there's plenty to do like
respecting `:nocov:` tags and so on.

And I'm gonna contact [Christoph Olszowka](https://github.com/colszowka) to ask
him if there is a chance that this code will be included to SimpleCov in some
way. I would really appreciate that!


## Thanks

Big thanks and Kudos to the folks of
[RuboCop](https://github.com/bbatsov/rubocop)! Coverfield is based on the AST
Ruby Parser, which is part of the RuboCop gem. Without that awesome peace of
software, covervield would have been much more code and much more complicated.
Thank you very much, nice work!

Also thanks to [Christoph Olszowka](https://github.com/colszowka) for his
[SimpleCov gem](https://github.com/colszowka/simplecov), I really hope there
will be some kind of integration in the future.


## Usage

Install via `gem install coverfield`.

Then just call `coverfield lib/ app/` in your apps root dir.


### Considerations

Coverfield requires you to have a specific architecture of your RSpec Suite.

1. All specs are located in `spec/`.
2. Within `spec` all specs are placed in the same path as the file which is
   tested by the spec. For example the spec for the file
   `/lib/some/nice_code.rb` have to be placed in
   `/spec/lib/some/nice_code_spec.rb`. And the spec for the file
   `/app/models/post.rb` goes to `/spec/models/post.rb`
   [Why?](http://stackoverflow.com/questions/14180003/rspec-naming-conventions-for-files-and-directory-structure)
3. The first and outer `describe` call have to be built like that:
   `describe Some::NiceCode do` assuming, that `/lib/some/nice_code.rb` defines
   the class `Some::NiceCode`.
   [Why?](http://rspec.info/documentation/3.4/rspec-core/#Basic_Structure)
4. All inner `describe` calls for the methods have to be built like that:
   `describe '#method_name' do`. The `#` is optional and may also be a `.`.
   [Why?](http://betterspecs.org/#describe)
