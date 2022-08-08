### Other features of Rake

Rake features that haven't explained yet will be described here and next section.
This section includes:

- Task arguments
- Description
- Rake command line options
- How Rake Searches for Rakefile
- Library

Multitask method and TestTask class are described in the next section.

#### Task arguments

You can pass arguments when launching a task from the command line.
For example,

```
$ rake hello[James]
```

The task name is `hello` and the argument is `James`.

If you want to pass multiple arguments, separate them with commas.

```
$ rake hello[James,Kelly]
```

Be careful that you can't put spaces anywhere from the task name to the right bracket.
This is because spaces have a special meaning on the command line.
It is *argument delimiters*.

- `rake hello[James,Kelly]` => One argument `hello[James,Kelly]` is passed to the command `rake`.
Rake analyzes it and recognizes that `hello` is the task name and `James` and `Kelly` are arguments to the task.
- `rake hello[James, Kelly]` => Two arguments `hello[James,` and `Kelly]` are passed to the command `rake`.
Rake recognizes that `hello[James,` is a task name because no closing bracket exists.
But, since Rakefile doesn't have such task, rake issues an error.

If you want to put spaces in the argument, enclose it in double quotes (`"`).
For further information, refer to [Bash reference manual](https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html).

```
$ rake "hello[James Robinson, Kelly Baker]"
```

Bash recognizes that the characters between two double quotes is one argument.
And it passes it to Rake as the first argument.
Then, Rake determines that `hello` is the task.
And that `James Robinson` and `Kelly Baker` are two arguments for the task.

On the other hand, a task definition in a Rakefile has parameters after the task name, separated by commas.

```
task :a, [:param1, :param2]
```

This task `a` has parameters `:param1` and `:param2`.
Parameter names are usually symbols, but strings are also possible.
If it has only one parameter, you don't need to use an array.

In the example above, there is no action in the task `a`, so the arguments have no effect.
Arguments take effect in an action.

The action (block) can have two parameters.
The second parameter is an instance of TaskArguments class.
The instance is initialized with the arguments given to the task.

```ruby
task :hello, [:person1, :person2] do |t, args|
  print "Hello, #{args.person1}.\n"
  print "Hello, #{args.person2}.\n"
end
```

Block parameters are:

- t => instance of task "hello"
- arg => arguments. An instance of the TaskArguments class.

Suppose that the task is called from the command line like this:

```
# The current directory is example/example7
$ rake -f Rakefile1 hello[James,Kelly,David]
Hello James.
Hello Kelly.
```

You may have noticed that there are more arguments than parameters.
It is not an error even if the numbers don't match like this.

Some instance methods of the TaskArguments class are shown below.

- [] => returns the value of the parameter.
`args[:person1]` returns `James`.
- Parameter name. Returns the value of the parameter.
`args.person1` returns `James`.
- to_a => returns a list of values.
`args.to_a` returns `["James", "Kelly", "David"]`.
- extras => When there are more arguments than parameters, the extra arguments are returned.
`args.extras` returns `["David"]`.
- to_hash => Returns a hash that combines parameters and values.
Extra arguments are discarded.
`args.to_hash` returns `{:person1=>"James", :person2=>"Kelly"}`.
- each => Execute `each` method on hash of `to_hash`.

> [R] The parameter name is used as a method name in the example above.
> But it is not actually defined as a method.
> Rake uses the `method_missing` method (BasicObject's method) to return the value of the parameter name if the method name is not defined.
> Therefore, it looks as if the method with the parameter name was executed.

You can also set default values ​​for parameters.
Use the `with_defaults` method with a hash.

```ruby
task :hello, [:person1, :person2] do |t, args|
  args.with_defaults person1: "Dad", person2: "Mom"
  print "Hello, #{args.person1}.\n"
  print "Hello, #{args.person2}.\n"
end
```

The default values ​​are now `Dad` for `person1` and `Mom` for `person2`.

```
$ rake -f Rakefile2 hello[James,Kelly,David]
Hello James.
Hello Kelly.
$rake -f Rakefile2 hello[,Kelly,David]
Hello Dad.
Hello Kelly.
$ rake -f Rakefile2 hello
Hello Dad.
Hello Mom.
```

If you want to add prerequisites in the task definition, write `=>`  and the prerequisites following the parameter.

```
task :hello, [:person1, :person2] => [:prerequisite1, :prerequisite2] do |t, args|
・・・・
end
```

Prerequisites `prerequisite1` and `prerequisite2` are added to the task `hello`.

Arguments are inherited by the prerequisites, so if you set the parameters in it, it can get the arguments.

```ruby
task :how, [:person1, :person2] => :hello do |t, args|
  print "How are you, #{args.person1}?\n"
  print "How are you, #{args.person2}?\n"
end

task :hello, [:person1, :person2] do |t, args|
  print "Hello, #{args.person1}.\n"
  print "Hello, #{args.person2}.\n"
end
```

Arguments given to the task `how` are also given to the prerequisite `hello`.

```
$ rake -f Rakefile3 how[James,Kelly,David]
Hello James.
Hello Kelly.
How are you, James?
How are you, Kelly?
```

The example above isn't practical, but I hope it helps you understand the Rakefile arguments.

In addition to arguments, environment variables can also be used to pass values ​​to Rake, but it is the old way.
Rake didn't support arguments prior to version 0.8.0.
At that time, using environment variables was an alternative to arguments.
There is no need to use environment variables as arguments in the later version.

#### Descriptions and command line options

You can add a description for a task.
Use the `desc` command and put it just before the target task.
Or, add a description with `add_description` method.

```ruby
desc "Say hello."
task :hello do
  print "Hello.\n"
end
Rake::Task[:hello].add_description "Greeting task."
```

The description string is set to the task instance when the task is defined.
The description is displayed with `rake -T` or `rake -D`.

```
$ rake -f Rakefile4 -T
rake hello  # Say hello / Greeting task
$ rake -f Rakefile4 -D
rake hello
    Say hello.
    Greeting task.

$
```

If a task doesn't have description, it won't be displayed.
Only the tasks with descriptions are displayed.
Descriptions should only be attached to tasks that users invoke from the command line.
For example, the following is the Rakefile in the previous section,

```ruby
・・・・
desc "Creates both HTML and PDF files"
task default: %w[html:build pdf:build]
・・・・
namespace "html" do
  desc "Create a HTML file"
  task build: %w[docs/my first Rake.html docs/style.css]
・・・・
namespace "pdf" do
  desc "Create a PDF file"
  task build: %w[My First Rake.pdf]
・・・・
```

You can see the task description from the command line.

```
# change the current directory to example/example6
$ rake -T
rake clean # Remove any temporary products
rake clobber # Remove any generated files
rake default # creates both HTML and PDF files
rake html:build # create a HTML file
rake pdf:build # create a PDF file
```

WHen a user see the message above, they can know the task name to give `rake`.
You could say that the description is a comment for the user.

On the other hand, when the developer wants to leave a note about the program, they should use Ruby comments (`# ... ...`).

The `-T` option only prints what fits on one line, while the `-D` option prints the entire description.
You can add a pattern to limit the tasks to display.

The following options are for developers.

- `-AT` => Show all defined tasks.
Prerequisites that are not defined in the Rakefile are not displayed.
- `-P` => show task dependencies
- `-t` or `--trace` => show all backtrace

In particular, the `-t` or `--trace` options are useful for development.

#### Rakefile search order and libraries

If the Rakefile is not found in the current directory, it searches higher directories.
For example, if the current directory is `a/b/c` and the Rakefile is in `a`,

- Search Rakefile with `a/b/c` => no. go up one directory
- Search Rakefile with `a/b` => no. go up one directory
- Search Rakefile with `a` => Yes. Read Rakefile and execute. At this time, Rake's current directory will be `a` (not `a/b/c`).

You can also specify a Rakefile with the `-f` option.

Rakefile is often written in one file, but in large-scale development, it can be divided into multiple files.
In that case

- Add a `.rake` extension to the library Rakefile (the file name does not have to be Rakefile)
- Place the libraries in the `rakelib` directory under the top directory (the directory containing the Rakefile)

There is no programmatic master-slave relationship between the Rakefile and the library, but the Rakefile in the top directory is called the "main Rakefile".
