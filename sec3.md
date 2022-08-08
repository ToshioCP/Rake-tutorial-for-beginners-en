### FileList, Pathmap and Directory Task

This section describes useful features that support file tasks.
Specifically, they are "FileList", "pathmap" and "directory task".

#### FileList

FileList is an array-like object of filenames.
It can be manipulated like an array of strings and has some nice features.

The `[ ]` class method creates a FileList instance which has elements of files given with the arguments.
The arguments are files separated with commas.

```ruby
files = FileList["a.txt", "b.txt"]
p files

task :default
```

The variable `files` is assigned a FileList instance which has "a.txt" amd "b.txt" as its elements.

If no task is defined in the Rakefile, Rake issues "Don't know how to build task 'default'" error.
To avoid thus, a default task is defined in the fourth line.

When Rake is invoked from the command line, it behaves like this:

1. Initialize the Rake environment
2. Load the Rakefile. The Rakefile is then executed (as Ruby code)
3. Invoke default task

When the Rakefile is executed, a FileList instance is created, displayed, and the default task is defined.
Note that these are done before the default task invocation.

```
$ rake -f Rakefile1
["a.txt", "b.txt"]
$
```

You can also use the glob pattern commonly used in Bash.

```ruby
files = FileList["*.txt"]
p files

task:default
```

Run Rake.

```
$ rm d.txt
$ ls
 Rakefile1   Rakefile4   Rakefile7   a.txt   dst
 Rakefile2   Rakefile5   Rakefile8   b.txt   src
 Rakefile3   Rakefile6   Rakefile9   c.txt  '~a.txt'
$ rake -f Rakefile2
["a.txt", "b.txt", "c.txt", "~a.txt"]
$
```

Please refer to the [Ruby documentation](https://docs.ruby-lang.org/en/master/Dir.html#method-c-glob) for glob patterns.

#### Backup all the text files

Let's think about the way to back up all the text files.
Here, "text file" is a file with ".txt" extension.
Note that "all the text files" are determined at the time rake runs, not the time you write the Rakefile.
So you have to create a mechanism in the Rakefile to get text files.

```ruby
files = FileList["*.txt"]
```

When this line is executed, ruby gets files that match "\*.txt".
The files include "~a.txt".
But it should be excluded since it is a backup file whose original is "a.txt".

```ruby
files = FileList["*.txt"]
files.exclude("~*.txt")
p files

task:default
```

The `exclude` method adds the given pattern to its own exclusion list.

```
$ rake -f Rakefile3
["a.txt", "b.txt", "c.txt"]
$
```

The file "~a.txt" is removed from the variable `files`.

The variable `files` is now set to the file list of the original files.
They are prerequisites.
For example,

- Task name is "a.bak"
- Dependent file name is "a.txt"

In order to define a file task, it is necessary to obtain the task name (destination filename) from the source filename.
To do so, use the `ext` method of FileList class.
The `ext` method changes the extension of all files included in the file list.

```ruby
names = sources.ext(".bak")
```

The Rakefile is like this.

```ruby
sources = FileList["*.txt"]
sources.exclude("~*.txt")
names = sources.ext(".bak")

task default: names

rule ".bak" => ".txt" do |t|
  cp t.source, t.name
end
```

Run Rake.

```
$rake -f Rakefile4
cp a.txt a.bak
cp b.txt b.bak
cp c.txt c.bak
$
```

Now add a text file and run Rake again.

```
$ echo Appended text file. >d.txt
$ rm *.bak
$ rake -f Rakefile4
cp a.txt a.bak
cp b.txt b.bak
cp c.txt c.bak
cp d.txt d.bak
$
```

A new file "d.txt" is also copied.
This means that Rakefile makes backup files of "all the text files" at the time Rake runs.

The "\*.txt" file in this example is sometimes referred to as the sources and the "\*.bak" files as the targets.
In general, it can be said that the source exists, but the target does not necessarily exist.
Therefore, source files is often get first and then the target filenames are created from the source.

#### Pathmap

The `pathmap` method is a powerful method for FileList.
Originally pathmap was an instance method of the String object.
The FileList's pathmap method performs String's pathmap for each element of the FileList.
Pathmap returns various information depending on its arguments.
Here are some examples.

- %p => Represents the full path
- %f => Represents the filename with extension. It does not contain the directory name.
- %n => Represents the filename without extension.
- %d => Represents a list of directories in the path.

In advance, create a "src" directory in the current directory and create "a.txt", "b.txt" and "c.txt" under it.

```
$ mkdir src
$ touch src/a.txt src/b.txt src/c.txt
$ tree
.
├── Rakefile
├── a.bak
├── a.txt
├── b.bak
├── b.txt
├── c.bak
├── c.txt
├── d.bak
├── d.txt
├── src
│   ├── a.txt
│   ├── b.txt
│   └── c.txt
└── ~a.txt

1 directory, 14 files
$
```

A Rakefile to test `pathmap` is like this:

```ruby
sources = FileList["src/*.txt"]
p sources.pathmap("%p")
p sources.pathmap("%f")
p sources.pathmap("%n")
p sources.pathmap("%d")

task:default
```

The variable `sources` contains "src/a.txt", "src/b.txt" and "src/c.txt".
Run Rake.

```
$ rake -f Rakefile5
["src/a.txt", "src/b.txt", "src/c.txt"]
["a.txt", "b.txt", "c.txt"]
["a", "b", "c"]
["src", "src", "src"]
```

The pathmap method allows you to specify a pattern and its replacement delimited by a comma and enclose them in curly braces.
The replacement specification is placed between the % and the directive.
For example, "%{src,dst}p" returns the pathname with "src" replaced by "dst".
This can be used to get the "task name" from the "dependent file name".

The following Rakefile copies all text files under the src directory to the dst directory.

```ruby
sources = FileList["src/*.txt"]
names = sources.pathmap("%{src,dst}p")

task default: names

mkdir "dst" unless Dir.exist?("dst")
names.each do |name|
  source = name.pathmap("%{dst,src}p")
  file name => source do |t|
    cp t.source, t.name
  end
end
```

The second line uses the `pathmap` replacement specification.

- `sources` is an array `["src/a.txt", "src/b.txt", "src/c.txt"]`
- `names` will be an array `["dst/a.txt", "dst/b.txt", "dst/c.txt"]`
 
Line 6 creates the destination directory "dst" if it does not exist.
The `mkdir` method is defined in the FileUtils module, which Rake automatically requires.
Line 8 uses the string pathmap method to get the dependency filename from the task name.

- `name` is `dst/a.txt`, `dst/b.txt` or `dst/c.txt`
- `source` will be `src/a.txt`, `src/b.txt` or `src/c.txt`

Run Rake

```
$ rm -rf dst
$ rake -f Rakefile6
mkdir dst
cp src/a.txt dst/a.txt
cp src/b.txt dst/b.txt
cp src/c.txt dst/c.txt
$
```

> \[R\] You can also use a rule that uses a regular expression and Proc object.
>
> ```ruby
> sources = FileList["src/*.txt"]
> names = sources.pathmap("%{src,dst}p")
>
> task default: names
>
> mkdir "dst" unless Dir.exist?("dst")
>
> rule /^dst\/.*\.txt$/ => proc {|tn| tn.pathmap("%{dst,src}p")} do |t|
> cp t.source, t.name
> end
> ```
>
> Run Rake
>
> ```
> $ rm dst/*
> $ rake -f Rakefile7
> cp src/a.txt dst/a.txt
> cp src/b.txt dst/b.txt
> cp src/c.txt dst/c.txt
> $
> ```
>
> Using a rule is simpler than an iterator.

#### Directory task

The `directory` method creates a directory task.
A directory task creates a directory with the task name if it does not exist.

```ruby
directory "a/b/c"
```

This directory task creates a directory "a/b/c".
If the parent directories "b" and "a" don't exist, create them too.

You can also use this to create the "dst" directory.

```ruby
sources = FileList["src/*.txt"]
names = sources.pathmap("%{src,dst}p")

task default: names
directory "dst"

names.each do |name|
  source = name.pathmap("%{dst,src}p")
  file name => [source, "dst"] do |t|
    cp t.source, t.name
  end
end
```

Note that directory tasks are "tasks", so they are just defined during the Rakefile are executed.
The tasks need to be invoked by another task.
So, add `dst` to the prerequisite for `dst/a.txt`, `dst/b.txt` and `dst/c.txt`.
This makes the directory before copying.

Run Rake

```
$ rm dst/*
$ rake -f Rakefile8
cp src/a.txt dst/a.txt
cp src/b.txt dst/b.txt
cp src/c.txt dst/c.txt
$
```

> \[R\] Rewrite the Rakefile with a rule.
>
> ```ruby
> sources = FileList["src/*.txt"]
> names = sources.pathmap("%{src,dst}p")
>
> task default: names
> directory "dst"
>
> rule /^dst\/.*\.txt$/ => [proc {|tn| tn.pathmap("%{dst,src}p")}, "dst"] do |t|
> cp t.source, t.name
> end
> ```
>
> A directory task has been added to the rule's prerequisites.

