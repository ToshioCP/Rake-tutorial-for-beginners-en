### File task

File tasks are the most important tasks in Rake.

#### What is File Task?

A file task is a task but its name is a filename.
A file task has a "name", "prerequisites" and an "action" like a general task.
There are three differences from general tasks:

- The "name" of the file task represents a path (of a file).
- File tasks have conditions to perform their action or not.
- A file task is defined with a "file" method while a general task is defined with a "task" method.

Except for these things, file tasks behave like general tasks.
For example, they invoke prerequisites before executing their action and they invoke their action only once.

There are two conditions to determine the invocation of file tasks.

- The file of the task does not exist.
- The mtime (file content modification time) of the file of the task is older than the mtime of its prerequisites (at least one of them).
However, if the prerequisite task is not a file task (if it is a general task), the current time is used instead of mtime.
Therefore, if the prerequisites contain a general task, the file task action will always be invoked.

> \[R\] The mtime (file content modification time) here is the value of Ruby's File.mtime method.
> Linux files have three timestamps: atime, mtime and ctime.
>
> - atime last access time
> - mtime last modified time
> - ctime last inode change time
>
> Ruby's File.mtime method returns the mtime above. (The original Ruby written in C language gets its value with a C function.)

#### Backup files

I'd like to show you a simple example.
It is to create a backup file "a.bak" for the text file "a.txt".
The easiest way is to use cp command.

```
$ cp a.txt a.bak
```

But I'd like to show you a Rakefile which performs the same thing.

```ruby
file "a.bak" => "a.txt" do
  cp "a.txt", "a.bak"
end
```

The contents of this Rakefile is:

- `file` method defines a file task "a.bak"
- The prerequisite for the task "a.bak" is "a.txt".
- The action of the task "a.bak" is `cp "a.txt", "a.bak"`.

The cp method is a method that copies the first argument file to the second argument file.
This method is defined in the FileUtils module.
FileUtils is a standard Ruby library, but it's not built-in, so you usually have to write `require 'fileutils'` in your program.
But you don't need to write it in your Rakefile as Rake automatically requires it.

When the task "a.bak" is called, the prerequisite "a.txt" is called before a.bak's execution.
However, the definition of the task "a.txt" is not written in the Rakefile.
How does Rake behave when there are no task definitions?
Rake defines a file task "a.txt" as a name-only task (no prerequisites and no action) if the file "a.txt" exists.
Then it calls that task, but since it has no action, nothing happens and it returns to "a.bak".
If "a.txt" does not exist, an error will occur.

Now let's run rake.
Move your current directory to `example/example2` and type as follows.

```
$ rake -f Rakefile1 a.bak
cp a.txt a.bak
$ diff a.bak a.txt
$ rake a.bak
$
```

- When rake runs, "a.txt" is copied to "a.bak".
- When diff compares "a.bak" and "a.txt", it doesn't show any messages because the two files are exactly the same.
- Run rake again, but no action is taken because the mtime of "a.bak" is newer than the one of "a.txt"

Now you've learned the most basic file task here.

#### Backup multiple files

I'd like to show you how to backup multiple files in this subsection.
Create new files "b.txt" and "c.txt" in advance.
The simplest Rakefile would be something like this:

```ruby
file "a.bak" => "a.txt" do
  cp "a.txt", "a.bak"
end

file "b.bak" => "b.txt" do
  cp "b.txt", "b.bak"
end

file "c.bak" => "c.txt" do
  cp "c.txt", "c.bak"
end
```

There are three file tasks defined here.
This Rakefile has been saved as `example/example2/Rakefile2`.
Delete "a.bak" and run rake like this:

```
$ rm a.bak
$ rake -f Rakefile2 a.bak
cp a.txt a.bak
$ rake -f Rakefile2 b.bak
cp b.txt b.bak
$ rake -f Rakefile2 c.bak
cp c.txt c.bak
$ ls | grep .bak
a.bak
b.bak
c.bak
```

Maybe you would say:

"If I were you, I wouldn't do this. Using rake three times is the same as using cp three times."

You are right.
I also don't want to run rake three times.
I want to run rake once and copy all 3 files.
This can be achieved by associating a general task with three file tasks.
Let's start by creating a "copy" task, which has the three file tasks as its prerequisites.

```ruby
task copy: %w[a.bak b.bak c.bak]

file "a.bak" => "a.txt" do
  cp "a.txt", "a.bak"
end

file "b.bak" => "b.txt" do
  cp "b.txt", "b.bak"
end

file "c.bak" => "c.txt" do
  cp "c.txt", "c.bak"
end
```

This Rakefile has been saved as `example/example2/Rakefile3`.
Try it.

```
$ rm *.bak
$  rake -f Rakefile3 copy
cp a.txt a.bak
cp b.txt b.bak
cp c.txt c.bak
```

I got 3 backup files at once.

Now restructure the Rakefile.
It includes the following two:

- Change the top level task from "copy" to "default".
"Default" is the default task when rake's command line argument is left out.
- Combine 3 file methods into a Ruby iterator's block.

```ruby
backup_files = %w[a.bak b.bak c.bak]

task default: backup_files

backup_files.each do |backup|
  source = backup.ext(".txt")
  file backup => source do
    cp source, backup
  end
end
```

- First, create an array of backup files and assign it to the variable `backup_files`.
- Declare the top level task "default".
- Use the each method to get each element of the backup file array.
The element is assigned to the `backup` parameter of the block.
- Substitute the backup's extension from ".bak" to ".txt" and assign it to the variable `source`.
The "ext" method is a method added to the String class by rake.
The original String class does not have "ext" method.
- Define a file task with the `file` command.
The iterator "each" repeats the block three times, so the `file` command is executed also three times.
Then, three file tasks "a.bak", "b.bak" and "c.bak" will be defined.

This Rakefile has been saved as `example/example2/Rakefile4`.
Now, give it a try.

```
$ rm *.bak
$ rake -f Rakefile4
cp a.txt a.bak
cp b.txt b.bak
cp c.txt c.bak
$ touch a.txt
$rake -f Rakefile4
cp a.txt a.bak
$
```

- Delete all backup files
- Running rake will copy all three files.
- Touch "a.txt" to update the mtime of "a.txt".
- When you run rake again, the action of the file task "a.bak" is executed because the mtime of "a.txt" is newer than the mtime of "a.bak".
No other action is executed because the other backup files have newer mtime than the original files.

I used "touch" to change the mtime, but usually mtime is updated when the file is updated with an editor.
In other words, when the original file is updated, the file task action will be executed.

Let's refactor the rakefile a little to show how to use task instances inside blocks.

Change the file task definition to:

```ruby
file backup => source do |t|
  cp t.source, t.name
end
```

The block now has a new parameter "t", which the file task "backup" is assigned to.
The "backup" task is an instance of the Task class from the Ruby syntax's point of view.

The same parameters can be used in blocks of task methods.

Tasks and file tasks, which are instances of the Task class, have convenience methods.

- `name` returns the name of the task.
- `prerequisites` returns an array of prerequisites.
- `sources` returns a list of files that the task depends on.
- `source` returns the first element of `sources`.

There are some other methods, but the four methods above are the most commonly used.

In the new file task definition, its action has changed to copy from 't.source' to 't.name'.
This will be "source" and "backup" respectively, so it is the same as the previous file task.

The new file has been saved as `example/example2/Rakefile5`.

```
$ rm *.bak
$ rake -f Rakefile5
cp a.txt a.bak
cp b.txt b.bak
cp c.txt c.bak
```

#### Rules

The actions of the tasks were copying files with the ".txt" extension to files with the ".bak" extension.
If you apply this to the file "a.bak", you will get a file task with the action "copy a.txt to a.bak".
These way how to create file tasks are called rules.
Rules can be defined with the "rule" method.
Let's take a look at an example.

```ruby
backup_files = %w[a.bak b.bak c.bak]

task default: backup_files

rule '.bak' => '.txt' do |t|
  cp t.source, t.name
end
```

The first three lines are the same as before.
According to the definition on the third line, the prerequisites of the task "default" are "a.bak", "b.bak" and "c.bak".
But those tasks are not declared.
In that case, rake will try to define the file task when the prerequisite is invoked.

- If a rule is defined and the task name matches the rule, rake defines the task with the rule.
- if no rule matches and the task name matches an existing filename, rake defines a file task with the task name but no prerequisites and action.
- if none of the above, an error occurs.

The rule in this example looks like this:

- Task name extension is ".bak"
- The extension of the dependent file name is ".txt"
- The action is to copy `t.source` (the first element in the array of files that the task depends on) to `t.name` (task name = file name).

All three tasks "a.bak", "b.bak" and "c.bak" match the rule, so the task is defined according to the rule.

The Rakefile above has been saved as `example/example2/Rakefile6`.

```
$ rm *.bak
$ rake -f Rakefile6
cp a.txt a.bak
cp b.txt b.bak
cp c.txt c.bak
$
```

It worked the same as before.

The ".bak" part of the rule method is converted by Rake to a regular expression `/\.bak$/`.
And the regular expression is compared with the task names 'a.bak', 'b.bak' and 'c.bak'.
You can use regular expressions for the task name of the rule instead of string from the very first.

```ruby
rule /\.bak$/ => '.txt' do |t|
  cp t.source, t.name
end
```

Run rake with `Rakefile7`.

```
$ rm *.bak
$ rake -f Rakefile7
cp a.txt a.bak
cp b.txt b.bak
cp c.txt c.bak
$
```

> \[R\] Regular expression enables the pattern to match an arbitrary patterns as well as extensions.
> For example, it is possible to change the backup filename to include a tilde "`~`" at the beginning, such as "~a.txt".
>
> ```ruby
> backup_files = %w[~a.txt ~b.txt ~c.txt]
>
> task default: backup_files
>
> rule /^~.*\.txt$/ => '.txt' do |t|
> cp t.source, t.name
> end
> ```
>
> But this Rakefile doesn't work.
>
> ```
> $ rake
> rake aborted!
> Rake::RuleRecursionOverflowError: Rule Recursion Too Deep: [~a.txt => ~a.txt => ~a.txt => ~a.txt => ~a.txt => ~a.txt => ~a .txt => ~a.txt => ~a.txt => ~a.txt => ~a.txt => ~a.txt => ~a.txt => ~a.txt => ~a.txt => ~a.txt => ~a.txt]
>
> Tasks: TOP => default
> (See full trace by running task with --trace)
> ```
>
> This is because the `=> '.txt'` part.
> The filename "~a.txt" matches the rule again, so rake try to apply the rule to "~a.txt".
> In other words, the task name and the dependent task name are the same, so we end up in an infinite loop when applying the rule.
> Rake decides it an error at the 16th loop.
>
> To avoid this, define the dependent file with a Proc object.
>
> ```ruby
> backup_files = %w[~a.txt ~b.txt ~c.txt]
>
> task default: backup_files
>
> rule /^~.*\.txt$/ => proc {|tn| tn.sub(/^~/,"")} do |t|
> cp t.source, t.name
> end
> ```
>
> The task name (e.g. "~a.txt") is passed by Rake as an argument to the proc method block.
> You can use the lambda method or "->\( \)\{ \}" instead of proc method.
> See [Ruby documentation](https://docs.ruby-lang.org/en/master/syntax/literals_rdoc.html#label-Lambda+Proc+Literals).
>
> ```
> $ rm ~*
> $ rake -f Rakefile8
> cp a.txt ~a.txt
> cp b.txt ~b.txt
> cp c.txt ~c.txt
> $
> ```