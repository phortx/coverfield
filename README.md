# Coverfield

[![Gem Version](http://img.shields.io/gem/v/coverfield.svg)](http://badge.fury.io/rb/coverfield)

**Warning:** This is a Beta Release!

One day I found a class in my ruby app with > 95% coverage in
[SimpleCov](https://github.com/colszowka/simplecov) but without any dedicated
spec. SimpleCov is an awesome tool if you want to get an idea of your test
coverage, but it has a flaw: It doesn't look whether there's a spec for a
class/module/method or not, it just reports if a line of code was executed while
the spec suite run through. In my case a class which was used relative often so
gathered nearly 100% coverage, but I've never wrote any line of testing code
specific vor that class.

To get an overview which classes, modules and methods my test suite covers (and
more important: which not), I've wrote a small script, which scans all
production code, finds the classes and methods and checks if there are dedicated
tests for that methods within the specs. It compiles a report which clearly
tells me, what specs are missing.

This script is not a substitution for SimpleCov! SimpleCov is a wonderful piece
of software and it's coverage report is very important. Think of Coverfield as a
additional tool for examining the quality of your test suite under another
aspect and from a different view.

Together SimpleCov and Coverfield can tell you accurate how good or bad your
coverage really is: Coverfield tells you which methods, classes and files are
covered by specs and which not. SimpleCov then tells you how well the body of
those methods is tested and if there are edge cases which are not touched by the
test suite.

[Click here for a screenshot of the coverfield generated report](https://twitter.com/phortx/status/745256593625911296).



## Future

This gem is still in beta phase and there's plenty to do (specs for example).

And I wrote [Christoph Olszowka](https://github.com/colszowka) to ask
him if there is a chance that this will be included to SimpleCov in some
way. I would really appreciate that!


## Thanks

Big thanks and Kudos to the folks of
[RuboCop](https://github.com/bbatsov/rubocop)! Coverfield is based on the AST
Ruby Parser, which is part of the RuboCop gem. Without that awesome peace of
software, coverfield would have been much more code and much more complicated.
Thank you very much, nice work!

Also thanks to [Christoph Olszowka](https://github.com/colszowka) for his
[SimpleCov gem](https://github.com/colszowka/simplecov), I really hope there
will be some kind of integration in the future.


## Usage

Install via `gem install coverfield`.

Then just call `coverfield -u lib/ app/` in your apps root dir.

For more info take a look at the usage information of `coverfield -h`.


### Considerations

Coverfield requires you to have a specific architecture of your RSpec Suite.

1. Within the spec directory all specs are placed in the same path as the file
   which is tested by the spec. For example the spec for the file
   `/lib/some/nice_class.rb` have to be placed in
   `/spec/lib/some/nice_class_spec.rb` or `/spec/some/nice_class_spec.rb`.
   And the spec for the file `/app/models/post.rb` goes to
   `/spec/app/models/post.rb` or `/spec/models/post.rb`
   [Why?](http://stackoverflow.com/questions/14180003/rspec-naming-conventions-for-files-and-directory-structure)
2. The first `describe` call have to be built like that:
   `describe Some::NiceClass do` assuming, that `/lib/some/nice_code.rb` defines
   the class `Some::NiceClass`.
   [Why?](http://rspec.info/documentation/3.4/rspec-core/#Basic_Structure)
3. All inner `describe` calls for the methods have to be built like that:
   `describe '#method_name' do`. The `#` is optional and may also be a `.`.
   [Why?](http://betterspecs.org/#describe)
4. All dependencies of your app have to be installed (`bundle install`).
