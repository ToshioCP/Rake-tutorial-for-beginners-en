### Multitask method and TestTask class

#### Multitask method

"Multitask" here refers to processing using Rake's "multitask" method, not "multitask" in general.
A task may contain multiple tasks that do not affect each other.
At that time, it is faster to execute them in parallel in multi-thread than to execute them sequentially in one thread.
The method "multitask" is the task for that.

As an example, we will use a program `fre.rb` that counts each word in a text file.
The `example/example8` folder contains this program, but I won't explain the details of the code.
This program scans the file given as an argument, finds the frequency of occurrence of each word, and displays the number of words and the top 10 words and the count.
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

Refer to the [Ruby documentation](https://ruby-doc.org/stdlib-3.1.2/libdoc/benchmark/rdoc/Benchmark.html#method-c-bm) for how to use the benchmark library.

Run "bm.rb".

```
$ ruby bm.rb
       user     system      total        real
   0.000179   0.000043   0.566276 (  0.569218)
   0.000130   0.000031   0.980284 (  0.271294)
```

The first row is the execution time when the task method was invoked sequentially and the second row is the one when the task was invoked concurrently.
Both finishes in an instant, so you may feel there is no difference.
But `Rakefile2` was two times faster than `Rakefile1` as the results above.

In order to use multitasking, it is necessary that each task does not interfere.
You can expect speed improvements in the multitask method if you organize your tasks well and avoid interference.

#### TestTask class

The final topic is TestTask class.
The current Ruby standard test library is minitest.
Information about minitest can be found on its [homepage](https://www.rubydoc.info/gems/minitest).
The explanation of minitest is left out here in this section.
But I think that using minitest is not so difficult.
If you use it a few times, you will get the hang of it.

Usually, test programs are collected in the `test` directory.
Put your Rakefile in the directory and you can run your tests concurrently.

Since creating test programs here would be a pretty big work, I'll leave out it and just explain Rakefile and TestTask here.

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
- Create a FileList instance of test files on the 3rd line and invoke its each method.
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

The last section may be difficult for beginners.
But section 1 to 4 is enough to write a Rakefile.
So, read the first 4 sections and practice writing your Rakefiles.
It would be good experience for you to understand the rest of the tutorial.

This tutorial itself also uses Rake to generate HTML from markdown.
See the Rakefile in the [repository](https://github.com/ToshioCP/Rake-tutorial-for-beginners-en).
It is similar to the Rakefile in section 4.

Thank you for having read this tutorial.
