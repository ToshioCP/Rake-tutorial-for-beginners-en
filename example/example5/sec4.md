# A useful example of Rakefile (1), Clean and Clobber

In this section we will combine Pandoc and Rake to create an HTML file.
Clean and Clobber will be also explained.

## Pandoc

Pandoc is an application that converts among lots of document formats.
for example,

- MS Word into HTML
- Markdown into PDF

Many other document formats are also supported.
For further information, see the [Pandoc website](https://pandoc.org/).

Pandoc is executed from the command line.

```
pandoc -o destination_file source_file
```

The option `-o` tells a destination file to pandoc.
Pandoc determines the file format from the extensions both source and destination.

In the following example, a word file `example.docx` is converted into a HTML file.
The word file looks like this:

<div style="text-align:center;">
  <img src="word.png" alt="Word screen" style="max-width:100%;">
</div>

Now convert it into an HTML file.
Pandoc is executed with `-s` option, which I will explain later.

~~~
$ pandoc -so example.html example.docx
~~~


This will create a file `example.html`.
Double-click to display it in a browser.

<div style="text-align:center;">
  <img src="html.png" alt="HTML screen" style="max-width:100%;">
</div>

The same contents as the one in Word are displayed.
The HTML is as follows.

```html
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="" xml:lang="">
<head>
  <meta charset="utf-8" />
  <meta name="generator" content="pandoc" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes" />
  <title>example</title>
  ... ... ...
  ... ... ...
</head>
<body>
<h1 id="pandoc-installation">Pandoc installation</h1>
<p>Use apt-get to install Pandoc from your distribution packages.</p>
<p>$ sudo apt-get install pandoc</p>
<p>The Pandoc distribution package is usually not the latest version. If
you want to get the latest one, download it from the Pandoc web
page.</p>
<h1 id="ruby-installation">Ruby installation</h1>
<p>Use apt-get.</p>
<p>$ sudo apt-get install ruby</p>
<p>If you want to get the latest version, use Rbenv. See Rbenv and
ruby-build GitHub pages.</p>
</body>
</html>
```

One important thing is that a header has been added.
This is because you gave pandoc the `-s` option.
Without `-s`, only the part between the body tags will be generated.

## Preparation for Pandoc

This section describes how to convert markdown to HTML and automate the work with Rake.

Assume all source files are in the current directory.
The generated HTML will be created in the docs directory.
The markdown files are "sec1.md", "sec2.md", "sec3.md" and "sec4.md".

The example files are in `example/example4`.

In Pandoc markdown, we write metadata with % first.
This represents the title, author and date.

```
% Rake tutorial for beginners
% ToshioCP
% August 5, 2022
```

The title will be put in the `title` tag in the HTML header.

PC screen width is usually too big to read a document so it is appropriate to put a CSS to make the width shorter.

``` css
body {
  padding-right: 0.75rem;
  padding-left: 0.75rem;
  margin-right: auto;
  margin-left: auto;
}

@media (min-width: 576px) {
  body {
    max-width: 540px;
  }
}
@media (min-width: 768px) {
  body {
    max-width: 720px;
  }
}
@media (min-width: 992px) {
  body {
    max-width: 960px;
  }
}
@media (min-width: 1200px) {
  body {
    max-width: 1140px;
  }
}
@media (min-width: 1400px) {
  body {
    max-width: 1320px;
  }
}
```

I wrote this CSS while referencing the Bootstrap's container class.

This CSS adjusts the width of `body` according to the screen size.
It's a technique called responsive web design (RWD).
You can get more information if you search for "responsive web design" in the internet.

Save this as `style.css` in the top directory, where you put your Rakefile.
The option `-c style.css` make pandoc include the stylesheet file in the header of the HTML.

## Rakefile

A Rakefile creates an HTML from the four files "sec1.md" to "sec4.md".
The target HTML and "style.css" will be located under `docs` directory.

There are two possible ways.

- Each markdown file is converted to HTML file.
Another HTML file (top page) has a table of contents that has links to each HTML file.
- Concatenate the markdown files into one file, then convert it to HTML.

Both have advantages and disadvantages.
This tutorial takes the second way because it's easier than the first.

```ruby
sources = FileList["sec*.md"]

task default: %w[docs/LearningRake.html docs/style.css]

file "docs/LearningRake.html" => %w[LearningRake.md docs] do |t|
  sh "pandoc -s --toc -c style.css -o #{t.name} #{t.source}"
end

file "LearningRake.md" => sources do |t|
  lerning_rake = t.sources.inject("") {|s1, s2| s1 << File.read(s2) + "\n"}
  File.write("LearningRake.md", lerning_rake)
end

file "docs/style.css" => %w[style.css docs] do |t|
  cp t.source, t.name
end

directory "docs"
```

Task relationships are a bit complicated.
Let's look at them one by one.

- The prerequisites of `default` are `docs/LearningRake.html` and `docs/style.css`.
- `docs/LearningRake.html` depends on `LearningRake.md` and a directory `docs`.
- `LearningRake.md` depends on 4 files (`sec1.md` to `sec4.md`).
- `docs/style.css` depends on `style.css` and the directory `docs`.
- `docs` is a directory task, defined with the directory method.

There is `sh` method in line 6.
It is similar to Ruby's `system` method and executes the argument as an external command.
It invokes Pandoc via `bash` on line 6.
The `sh` method is a Rake extension to FileUtils class.

Pandoc option `--toc` automatically generates a table of contents.
By default, Markdown headings from `#` to `###` will be put in the table of contents.

The `inject` method on line 10 is the array instance method.
The argument (an empty string) is the initial value of `s1`.
The values ​​in the array are sequentially assigned to `s2` and calculated, and the result is assigned to the next `s1`.
See how the method works step by step.

- The initial value is the empty string `""` (the argument).
it is assigned to `s1` in the block.
- `s2` is assigned the first array element, "sec1.md", and `s1 << File.read(s2) + "\n"` is executed.
As a result, "contents of sec1.md + newline" is added to the string pointed to by `s1`, and that string becomes the return value of the `<<` method.
The return value will be assigned to `s1` in the block when it is executed in the second time.
(The actual proces is complicated, but in short, it can be said that `s1` is added with "contents of sec1.md + newline" and becomes the next `s1`.)
- In the second block execution, `s1` is substituted with "sec1.md contents + newline", and `s2` is substituted with the next array element "sec2.md".
The block is executed, and "sec2.md contents + newline" is added to `s1`.
As a result, `s1` becomes "contents of sec1.md + newline + content of sec2.md + newline".
This will be assigned to the next `s1`.
- In the third execution of the block, the result of the previous execution is assigned to `s1`, and the next array element "sec3.md" is assigned to `s2`.
Then "contents of sec3.md + newline" is added.
- At the 4th (last) block execution, the result of the previous execution is assigned to `s1` and the next array element "sec4.md" is assigned to `s2`.
Then "contents of sec4.md + newline" is added.
- As a result, "sec1.md contents + newline + sec2.md contents + newline + sec3.md contents + newline + sec4.md contents + newline" is substituted for `lerning_rake`.
In short, it will be a string that combines four files with newlines in between.
Line 11 saves it to the file "LearningRake.md".

The reason I added a newline to the end of the file is that in general "a text file may or may not end with a newline".
If you connect the next file without newline, the first character of the second file will not start the line.
Then, it is possible that the "#" of the heading is shifted from the beginning of the line and is no longer a heading.
A line break is added to avoid this.

The examples are stored in `example/example4`.
Change your current directory to `example/example4` and execute rake.

```
$ rake -f Rakefile1
mkdir -p docs
pandoc -s --toc -c style.css -o docs/LearningRake.html LearningRake.md
cp style.css docs/style.css
$
```

Double click `example/example4/docs/LearningRake.html`, then your brouwser shows the contents.
Make sure that the contents are the same as the ones in `sec1.md` to `sec4.md`.

## clean and clobber

In this process, the file "LearningRake.md" is an intermediate file, which may be useless once the target file is created.
And it is probably appropriate that such intermediate files should be removed.
The clean task performs such operations.

- require `rake/clean`
- Add intermediate files to the FileList object pointed to by the constant `CLEAN`.
There are some methods to add files to `CLEAN` such as `<<`, `append`, `push`, and `include`.
- Task `clean` removes all the files stored in `CLEAN`

Another useful FileList is `CLOBBER`.

- The clobber task deletes files registered with `CLEAN`.
- In addition, it deletes the files registered in `CLOBBER`.

Now, the Rakefile with `CLEAN` and `CLOBBER` looks like this:

```ruby
require 'rake/clean'

sources = FileList["sec*.md"]

task default: %w[docs/LearningRake.html docs/style.css]

file "LearningRake.html" => %w[LearningRake.md docs] do |t|
  sh "pandoc -s --toc -c style.css -o #{t.name} #{t.source}"
end
CLEAN << "LearningRake.md"

file "LearningRake.md" => sources do |t|
  firstrake = t.sources.inject("") {|s1, s2| s1 << File.read(s2) + "\n"}
  File.write("LearningRake.md", firstrake)
end

file "docs/style.css" => %w[style.css docs] do |t|
  cp t.source, t.name
end

directory "docs"
CLOBBER << "docs"
```

The following instruction removes `LearningRake.md`.

```
$ rake -f Rakefile2 clean
```

The following instruction removes all the generated files.

```
$ rake -f Rakefile2 clobber
```
