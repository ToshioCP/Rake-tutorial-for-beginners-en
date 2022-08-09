### Multitask method and TestTask class

#### Multitask method

"Multitask" here refers to a method name, not "multitask" in general.
The method `multitask` invokes prerequisites concurrently.
The prerequisites must not to affect each other, or bad error will happen.
Generally, it is faster to use `multitask` than `task` because `task` invokes prerequisites sequentially.

A program `fre.rb`, which counts each word in a text file, is located at `example/example8`.
The details of `fre.rb` is left out here.
This program scans the files given as arguments, finds the frequency of occurrence of each word, and displays the number of words and the top 10 words and the count.
Here, "word" means string separated by space characters (`/\s/` = `[\t\r\n\f\v]`).

```
$ ruby fre.rb ../../sec1.md
Number of words: 2030
Top 10 words
"the"      =>  106
"is"       =>  63
"a"        =>  57
"task"     =>  52
">"        =>  47
"```"      =>  37
"and"      =>  29
"in"       =>  28
"it"       =>  28
"to"       =>  27
```

This shows that the total number of words is 2030 and the most frequent occurrence word is "the".
Now, prepare two Rakefiles `Rakefile1` and `Rakefile2`.

Rakefile1

```ruby
require 'rake/clean'

files = FileList["../../sec*.md"]

task default: files

files.each do |f|
  task f do
    sh "ruby fre.rb #{f} > #{f.pathmap('%f').ext('txt')}"
  end
end

CLEAN.include files.pathmap('%f').ext('txt')
```

This `Rakefile1` calculates the word frequency of the files from `../../sec1.md` to `../../sec7.md` and writes the result to files.

`Rakefile2` is the same except that the output file name is different and the `task` method on line 5 is replaced with the `multitask` method.

```ruby
multitask default: files
```

The `multitask` method processes tasks concurrently in separate threads.
It is expected to work faster than `Rakefile1`.
We will use Ruby's Benchmark library to measure each execution time to compare.
The program `bm.rb` is as follows.

```ruby
require 'benchmark'

Benchmark.bm do |x|
  x.report {system "rake -f Rakefile1 -q"}
  x.report {system "rake -f Rakefile2 -q"}
end
```

Refer to the [Ruby documentation](https://ruby-doc.org/stdlib-3.1.2/libdoc/benchmark/rdoc/Benchmark.html#method-c-bm) for further information about benchmark library.

Run "bm.rb".

```
$ ruby bm.rb
       user     system      total        real
   0.000179   0.000043   0.566276 (  0.569218)
   0.000130   0.000031   0.980284 (  0.271294)
```

The first row is the execution time when the tasks were invoked sequentially (Rakefile1) and the second row is the one when the tasks were invoked concurrently (Rakefile2).
Both finishes in an instant, so you may feel there is no difference.
But `Rakefile2` was two times faster than `Rakefile1` as the results above.

You can expect speed improvements in the multitask method if you organize your tasks well and avoid interference.

#### TestTask class

The final topic is TestTask class.
The current Ruby standard test library is minitest.
Information about minitest can be found on its [homepage](https://www.rubydoc.info/gems/minitest).
The explanation of minitest is left out here.
But I think that using minitest is not so difficult.
If you use it a few times, you will get the hang of it.

Usually, test programs are collected in the `test` directory.
Put your Rakefile in the directory and you can run your tests concurrently.

Since creating test programs here would be a pretty big work, I'll leave it out and just explain Rakefile and TestTask here.

```ruby
require "rake/testtask"

FileList['test*.rb'].each do |file|
  Rake::TestTask.new do |t|
    t.libs << "test"
    t.test_files = [file]
    t.verbose = true
  end
end
```

In this example, it is assumed that the names of test files start with "test" such as "test_word_count.rb".

- Require `rake/testtask`
- Create a FileList instance of test files on the 3rd line and invoke `each` method.
- Create a TestTask instance with `Rake::TestTask.new`.
TestTask class and Task class are different.
But they have relationship.
When a TestTask instance is created, the same name Task instance is also created.
After the Rakefile is executed, the tasks will be invoked.
- The block argument `t` is the TestTask instance.
- `t.libs` is the list of directories added to $LOAD_PATH.
Its default is `lib`.
- `test_files` method explicitly defines the list of test files to be included in a test.
Each test file is a ruby program with minitest.
Make sure that the test files doesn't have any conflicts.
For example, if your test programs read or write files, the clash tends to happen.
- `t.verbose=true` will show information about the test.
The default is `false`.

Run the test task from the command line.
( There's no example in this tutorial.)

```
$ rake test
```

#### Conclusion

Rake is a powerful development tool, which controls programs and methods.
Rake has FileTask, which is similar to Make's task.
But Rake is more powerful than Make.
Such Rake features has been explained in this tutorial.
Rake is really flexible so that you can apply it to many projects.
Now what you do is just apply Rake to your project.

This tutorial itself also uses Rake to generate HTML from markdown.
See the Rakefile in the [repository](https://github.com/ToshioCP/Rake-tutorial-for-beginners-en).
It is similar to the Rakefile in section 4.

Thank you for having read this tutorial.
