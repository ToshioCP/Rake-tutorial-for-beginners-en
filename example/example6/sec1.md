### Tasks

This tutorial is aimed at people learning Rake for the first time, but it is also useful for those already familiar with Rake.
This tutorial features

- Explains how Rake works and how it works
- Covers practical examples using Rake

Through this tutorial, let's acquire the ability to use Rake for various development.

The paragraph that starts with the symbol \[R\] in the text is "Commentary for advanced Ruby users".
*Advanced* basically refers to "a level where you can write a class".
Other users should skip this part.

#### Installing Rake

Rake is a Ruby application.
For Ruby installation, refer to [Ruby's official website](https://www.ruby-lang.org/en/documentation/installation/#package-management-systems).
Rake is a Ruby's standard library, so it is usually included in the installed Ruby.
But if not,

- If you installed the ruby ​​package of the Linux distribution => install its rake package.
- If you installed by another method => Install with `gem install rake` from the command line.

#### Download examples of this document

The Github repository of this documenti is [here](https://github.com/ToshioCP/Rake-tutorial-for-beginners-en).
Click "Code" button (green button) and choose "Download ZIP".
You can also clone the repository with git.

#### What is Rake?

Rake is a ruby application that implements the same functions as Make.

Make is a program developed to control the entire compilation process when compiling in C.
But Make can control not only C, but also various compilers and translators (programs that convert from one format to another).
Make is convenient, but its syntax is complicated.
It's easy to understand when you're using it for the first time, but the more you use it, the more difficult it becomes to understand.
For example:

```
application: $(OBJS)
$(CC) -o $(@F) $(OBJS) $(LIBS)

$(OBJS): %.o: %.c $(HEADER)
$(CC) -fPIC -c -o $(@F) $(CFLAGS) $<
```

On the other hand, Rake is:

- Easy to understand because you can use Ruby language.
- Therefore, you can write your code clearly and flexibly.

Reference:

- [RAKE - Ruby Make](https://ruby.github.io/rake/index.html)
- [Github, ruby/rake](https://github.com/ruby/rake)

#### Rake Basics

First, the important point is the command `rake` and the file `Rakefile` placed in the current directory.
The rake command takes a task name (tasks are explained later) as an argument.

```
$ rake hello
```

In this example the argument `hello` is the task name.

`rake` will then do the following in order:

- Initialize Rake
- Load and run Rakefile (Rakefile contains task definitions)
- Invoke a task given from the command line argument

When you use Rake, your main work is writing task definitions in your Rakefile.
The task called from the command line must be defined in the Rakefile.

> \[R\] "Define/Declare a task" are used in the [Rake documentation](https://ruby.github.io/rake/doc/rakefile_rdoc.html).
> It actually means "create an instance of the Task class" in terms of Ruby syntax.

#### Task definition in Rakefile

A task is an object that has a name, prerequisites, and an action.
Prerequisites and an action are optional.

The first example below has only a name.

```
task :simple_task
```

Write the line above with your editor and save it as a file named `Rakefile`.
The first element `task` can be considered to be a *command* which defines (or declares) a task.

In general, a *command* in a programming language is something that tells the computer to do something.
For example, in Bash, `cd`" is the *command* to change the current directory.
When you type `cd /var` in your command line, it moves the current directory to `/var`.
It is the result of executing the `cd` command with the `/var` argument.

Similarly, the `task` command is given with the argument `:simple_task`.
And executing the task command creates a task with the name simple\_task.
The argument `:simple_task` is a symbol, but you can also use a string like this:

```
task "simple_task"
```

The both created tasks are exactly the same.

On the other hand, the task command is actually a Ruby method from Ruby's syntactic point of view, and `:simple_task` is an argument to the method.
From now on, a task may be called a *command* or *methods* from the context.

- If it is focused on its "task creation" function, it will be called a *command*.
- If it is thought as a method in Ruby's syntax, it will be called a *method*.

I think it won't make any confusion and don't worry too much about it.

> \[R\] From Ruby's grammar, the `task` command is a "method call", and `:simple_task` is an argument of the method.
> In Ruby, you can write arguments with or without parentheses so the example above is a correct ruby program.
> If you use parentheses,
>
> ```
> task("simple_task")
> ```
>
> Be careful that there's no blank between the method and the left parenthesis.
>
> You can define it either way, but it's better to use it without parentheses.
>
> "Defining a task" means "creating an instance of the Task class".
> When you create a new instance, the class's `new` method is usually called.
> But it is *not* the only way to create an instance.
> The `task` method calls `Task.new` in its body to create an instance.
> In addition, the `task` method is more convenient than `new` method.

Task `simple_task` has no prerequisites and actions.

Let's run the task from the command line.
If you haven't download the [repository](https://github.com/ToshioCP/Rake-tutorial-for-beginners-en), do it before executing rake.

It is assumed that the current directory is the top directory of the downloaded and unzipped data.
Change your current directory to `example/example1`. 

```
$ ls
Rakefile  Rakefile2  Rakefile3  Rakefile4
$ cat Rakefile
task :simple_task
$ rake simple_task
```

First, make sure that there exists `Rakefile`.
Then, run rake.
The task `simple_task` has been called, but since it has no action, nothing happened.
Check whether the task is defined.

```
$ rake -AT
rake simple_task#
```

Option AT displays all registered tasks.
Now you know that simple\_task is defined.

#### actions

Actions are represented by a block of the task method.

```ruby
task: hello do
  print "Hello world!\n"
end
```

This task is named `hello`.
hello has no prerequisites.
The action is to display "Hello world!" on the screen.

The task command above is written in `Rakefile2`, not `Rakefile`.
So, it is necessary to give rake the filename `Rakefile2` as a rakefile.
To do this, `-f` option is used.

```
$ cat Rakefile2
task: hello do
  print "Hello world!\n"
end
$ rake -f Rakefile2 hello
Hello world!
```

The task hello was invoked and its action was executed.
As a result, the string "Hello world!" was displayed.

> \[R\] Ruby has two ways of representing blocks: (1) curly braces (`{` and `}`) and (2) `do` and `end`.
> Both will work in a Rakefile, but it's better to use `do` and `end` for readability.
> Also, if you use curly braces and write like this, it won't work:
>
> ```ruby
> task :hello {print "Hello world!\n"}
> ```
>
> This causes an error because curly braces bind more tightly to the preceding expression than do-ends.
> Please see [Ruby FAQ](https://www.ruby-lang.org/en/documentation/faq/5/) for further information.
> To fix this, put parentheses around the argument.
>
> ```ruby
> task(:hello) {print "Hello world!\n"}
> ```
>
> In Rakefile, it is good to express a task as if it were a command.
> Therefore, writing a task command with parenthses is NOT recommended.
>
> Thanks to Ruby's flexible syntax such as omitting parentheses in arguments, Ruby can make methods look like commands.
> And you can make a new language for a specific purpose.
> Such language is called "DSL (Domain-Specific Language)".
> The idea that Rake is a kind of DSL, brings the do-end recommendation.

#### Prerequisites

If a task has prerequistes, it call them before its action is invoked.

A task definition with prerequisites is like this:

```
task task name => [ a list of prerequisites ] do
  action
end
```

`task name => [ a list of prerequisites ]` is a Ruby hash.
You can leave out the braces (`{` and `}`) when the hash is the last argument of the method call.
If you do not omit it, it will be `{ task name => [ a list of prerequisites ] }`.
It also works.

If the task name is a symbol, you can write `abc: "def"` instead of  `:abc => "def"`.
Similarly, `:abc => :def` and `abc: :def` are the same.

There are two tasks in the following example.
Their names are "first" and "second".
"First" is a prerequisite for "second".

```ruby
task second: :first do
  print "Second.\n"
end

task: first do
  print "First.\n"
end
```

When you call the task "second", the prerequiste "first" is invoked before the invocation of "second".

```
invoke first => invoke second
```

Now, run rake.
THe name of the above file is "Rakefile3".

```
$ rake -f Rakefile3 second
First.
Second.
```

#### Rakefile example

Utagawa-san's [Write a recipe for ajitama in a Makefile](https://blog.utgw.net/entry/2022/06/22/221311) was so interesting that I made a Rake version of it.

```ruby
### Make a "ajitama" (flavored egg)

task :Boil_hot_water do
  print "Boil water.\n"
end

task Boil_eggs: :Boil_hot_water do
  print "Boil eggs.\n"
end

task :Wait_8_minutes => :Boil_eggs do
  print "Wait 8 minutes.\n"
end

task Add_ice_into_the_bowl: :Wait_8_minutes do
  print "Add ice to the bowl.\n"
end

task Fill_water_in_bowl: :Add_ice_into_the_bowl do
  print "Fill the bowl with water.\n"
end

task Put_the_eggs_in_the_bowl: :Fill_water_in_bowl do
  print "Put the eggs into the bowl.\n"
end

task Shell_the_eggs: :Put_the_eggs_in_the_bowl do
  print "Shell the eggs.\n"
end

task :Write_the_date_on_the_ziplock do
  print "Write the date on the ziplock.\n"
end

task Put_mentsuyu_into_a_ziplock: [:Write_the_date_on_the_ziplock, :Shell_the_eggs] do
  print "Put mentsuyu (Japanese soup base) into a ziplock.\n"
end

task Put_the_eggs_in_a_ziplock: :Put_mentsuyu_into_a_ziplock do
  print "Put eggs in a ziplock.\n"
end

task Keep_it_in_the_fridge_one_night: :Put_the_eggs_in_a_ziplock do
  print "Keep it in the fridge one night.\n"
end

task Ajitama: :Keep_it_in_the_fridge_one_night do
  print "Ajitama is ready.\n"
end
```

Now run rake.

```
$ rake -f Rakefile4 Ajitama
Write the date on the ziplock.
Boil water.
Boil eggs.
Wait 8 minutes.
Add ice to the bowl.
Fill the bowl with water.
Put the eggs into the bowl.
Shell the eggs.
Put mentsuyu (Japanese soup base) into a ziplock.
Put eggs in a ziplock.
Keep it in the fridge one night.
Ajitama is ready.
```

#### Task invocation is only once

Tasks that have already been invoked doesn't invoke their actions.
In other words, tasks are invoked only once.

For example, if you change the ajitama's Rakefile like this:

from:

```ruby
task Put_the_eggs_in_a_ziplock: :Put_mentsuyu_into_a_ziplock do
```

to:

```ruby
task Put_the_eggs_in_a_ziplock: [:Put_mentsuyu_into_a_ziplock, :Shell_the_eggs] do
```

Then, `:Shell_the_eggs` is a prerequisite in the two different tasks.
So, It is invoked twice, but the second invocation is ignored.
And the result is the same as before.

> \[R\] The Task class has two instance methods "invoke" and "execute".
> "Invoke" performs the action only once, while "execute" performs it as many times as the method is called.
> So, [Rake documentation](https://ruby.github.io/rake/doc/glossary_rdoc.html) distinguishes the two words "call" and "execute".
> There may be some ambiguous parts in this tutorial, but I don't think they bring any big confusion.
> Note that "invoke" calls the prerequisites before performing its own task, but "execute" does not call the prerequisites.

#### Strings can be used for task names instead of symbols.

So far we've used symbols in task names, but you can also use strings.

```
task "simple_task"
task "second" => "first"
```

It is possible to write it like this.
To describe a hash with a symbol, you can write something like "\{abc: :def\}", but you can't use this if the symbol starts with a number.
"\{0abc: :def\}" and "\{abc: :2def\}" are syntax errors.
It must be written like "\{:'0abc' => :def\}" and "\{abc: :'2def'\}".
There is no such problems if you use strings.

The following format is often used.

```
task abc: %w[def ghi]
```

`%w` returns an array of strings separated by spaces.
`%w[def ghi]` and `["def", "ghi"]` are the same.
Please refer to [The Ruby Programming Wikibook](https://en.wikibooks.org/wiki/Ruby_Programming/Syntax/Literals#Alternate_Notation).

If you use % notation in Ajitama Rakefile, it will be like this:

```
task Put_mentsuyu_into_a_ziplock: %w[Write_the_date_on_the_ziplock Shell_the_eggs] do
```
