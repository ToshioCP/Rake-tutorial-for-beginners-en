### A useful example of Rakefile (2), Namespace

In this section, we will create a PDF file with Pandoc and Rake.
The namespaces is also explained here.

#### Pandoc, LaTeX and PDF

Pandoc is able to convert Markdown to PDF.
There are several intermediate file formats to generate PDF files.
LaTeX, ConTeXt, roff ms, and HTML are such formats.

We'll choose LaTeX as an intermediate file format here.

```
Markdown => LaTeX => PDF
```

PdfLaTeX, XeLaTeX and LuaLaTeX can be used as a LaTeX engine to convert a tex file to PDF.
LuaLeTeX will be used here.

#### Preparation

Pandoc Markdown has its own extensions from the original Markdown.
One of the extensions is Metadata.
It's written at the beginning of the Markdown text and configures some information for Pandoc.
They are written in YAML format.
For more information about YAML, see [Wikipedia](https://en.wikipedia.org/wiki/YAML) or [YAML official page](https://yaml.org/).

```
% Rake tutorial for beginners
% Toshio CP
% August 5, 2022

---
document class: article
geometry: margin=2.4cm
toc: true
numbersections: true
secnumdepth: 2
---
---
```

Metadata starting with % is the same as the one in the previous section.
They represents the title, author, and date of creation, respectively.
The part surrounded by `---` lines is YAML metadata.
See the Pandoc manual for what items can be set here.
The items here are as follows.

- Use 'article' as the document class for LaTeX documents
- Use geometry package and set all the margins to 2.4cm
- Output table of contents
- Number sections (the default is false)
- Sections are numbered from the largest heading to the second largest.
The largest heading in the "article" document class is "section" and the second largest is "subsection".
These correspond to '#' and '##' ATX headings in Markdown.

Add the above to the beginning of "sec1.md".

In the previous section, I used "###" to "#####" for headings in the Markdown files, but that doesn't make it a LaTeX section or subsection, so I need to change it from "#" to "###".
Since it is troublesome to do it manually, I've written a Ruby program.

```ruby
files = (1..4).map {|n| "sec#{n}.md"}
files.each do |file|
  s = File.read(file)
  s.gsub!(/^###/,"#")
  s.gsub!(/^####/,"##")
  s.gsub!(/^#####/,"###")
  File.write(file,s)
end
```

File in `example/example5` has already changed its ATX headings so you don't need to run `ch_head.rb`.

We need to change one more.
Sec2.md has a long line in a fence code block.
It will overflow in the PDF.

```
> $ rake
> rake aborted!
> Rake::RuleRecursionOverflowError: Rule Recursion Too Deep: ... ... ...

The long line is devided into three lines like this:

> $ rake
> rake aborted!
> Rake::RuleRecursionOverflowError: Rule Recursion Too Deep: [~a.txt => ~a.txt =>
> ~a.txt => ~a.txt => ~a.txt => ~a.txt => ~a .txt => ~a.txt => ~a.txt => ~a.txt =>
> ~a.txt => ~a.txt => ~a.txt => ~a.txt => ~a.txt => ~a.txt => ~a.txt]
```

#### Rakefile

We start with the previous Rakefile and modify it.
It is easier than writing it from scratch.

```ruby
require 'rake/clean'

sources = FileList["sec*.md"]

task default: %w[LearningRake.pdf]

file "LearningRake.pdf" => "LearningRake.md" do |t|
  sh "pandoc -s --pdf-engine lualatex -o #{t.name} #{t.source}"
end
CLEAN << "LearningRake.md"

file "LearningRake.md" => sources do |t|
  learning_rake = t.sources.inject("") {|s1, s2| s1 << File.read(s2) + "\n\n"}
  File.write("LearningRake.md", learning_rake)
end

CLOBBER << "LearningRake.pdf"

```

Change your current directory to `example/example5` and run Rake.

```
$ rake
pandoc -s --pdf-engine lualatex -o Beginning Rake.pdf Beginning Rake.md
$
```

It takes a little longer than before (about 10 seconds).

HTML is suitable for publishing on the web, and PDF is suitable for viewing at hand.
In the next subsection, we'll combine these two tasks into a single Rakefile.

#### Namespaces

Now we combine two tasks (HTML and PDF) into one Rakefile.
Namespaces is used here to make the Rakefile organized.

Namespaces are a common technique when building large programs, and are not limited to Rake.
Here, we define two namespaces like this:

- Put the tasks for HTML in the namespace "html"
- Put the tasks for PDF in the namespace "pdf"

A namespace is declared with `namespace` method.

```
namespace namespace_name do
  Task definition
  ・・・・
end
```

In the previous Rakefile, each work was started with the default task.
In the new Rakefile, we will make a `build` task for each.
Since the `build` task is defined under the namespace, they are:

- html:build => task to build HTML
- pdf:build => task to build PDF

In this way, tasks under a namespace are represented by connecting them with a colon, such as "namespace\_name: task\_name".

Namespaces only apply to general tasks (not file or directory tasks).
A file task is a filename, and the filename doesn't change even if it's defined in a namespace.
Namespaces are not used when referencing file tasks, too.

#### Preparation

Some preparations are required to combine two tasks into one Rakefile.

- Move all metadata (including title, author, date and time) to other files.
Prepare “metadata\_html.yml” for HTML and “metadata\_pdf.yml” for PDF.
- When creating PDF, it is necessary to change the heading (for example, change "###" to "#").
New intermediate files are needed.
Name them "sec\_pdf?.md", where `?` is a number from 1 to 7.

The metadata files are as follows.

metadata\_html.yml

```yml
title: Rake tutorial for beginners
author: ToshioCP
date: August 7, 2022
```

metadata\_pdf.yml

```yml
title: Rake tutorial for beginners
author: ToshioCP
date: August 7, 2022
documentclass: article
geometry: margin=2.4cm
toc: true
numbersections: true
secnumdepth: 2
```

Delete the metadata from `sec1.md`.
Please make sure that the heading of "sec1.md" is the ATX heading from "###" to "#####" (not from "#" to "###").

#### Rakefile

The new Rakefile for HTML and PDF is as follows.

```ruby
require 'rake/clean'

sources = FileList["sec1.md", "sec2.md", "sec3.md", "sec4.md"]
sources_pdf = sources.pathmap("%{sec,sec_pdf}p")

task default: %w[html:build pdf:build]

namespace "html" do
  task build: %w[docs/LearningRake.html docs/style.css]
  
  file "docs/LearningRake.html" => %w[LearningRakee.md docs] do |t|
    sh "pandoc -s --toc --metadata-file=metadata_html.yml -c style.css -o #{t.name} #{t.source}"
  end
  CLEAN << "LearningRake.md"
  
  file "LearningRake.md" => sources do |t|
    learning_rake = t.sources.inject("") {|s1, s2| s1 << File.read(s2) + "\n\n"}
    File.write("LearningRake.md", learning_rake)
  end

  file "docs/style.css" => %w[style.css docs] do |t|
    cp t.source, t.name
  end

  directory "docs"
  CLOBBER << "docs"
end

namespace "pdf" do
  task build: %w[LearningRake.pdf]

  file "LearningRake.pdf" => "LearningRake_pdf.md" do |t|
    sh "pandoc -s --pdf-engine lualatex --metadata-file=metadata_pdf.yml -o #{t.name} #{t.source}"
  end
  CLEAN << "LearningRake_pdf.md"
  
  file "LearningRake_pdf.md" => sources_pdf do |t|
    learning_rake = t.sources.inject("") {|s1, s2| s1 << File.read(s2) + "\n\n"}
    File.write("LearningRake_pdf.md", learning_rake)
  end
  CLEAN.include sources_pdf

  sources_pdf.each do |dst|
    src = dst.sub(/_pdf/,"")
    file dst => src do
      s = File.read(src)
      s = s.gsub(/^###/,"#").gsub(/^####/,"##").gsub(/^#####/,"###")
      File.write(dst, s)
    end
  end

  CLOBBER << "LearningRake.pdf"
end
```

The points are:

- The definition of `sources` are changed.
An intermediate file such as "sec_pdf1.md" is created in the `pdf` namespace.
The glob pattern `FileList["sec*.md"]` possibly picks up such intermediate files.
Therefore, the each source file is specified in the arguments of `FileList[]` method.
- A new option `--metadata-file=` is given to Pandoc to import metadata.
- When creating the PDF, intermediate file tasks such as "sec_pdf1.md" are defined.
The headings in "sec?.md" is changed in the file task action.
A `gsub` method is used instead of `gsub!` for string substitution.
Since the return values ​​are different between the both, it is better to use methods without exclamation.
(Using `gsub!` is prone to include bugs because it returns `nil` when the replacement does not occur.)

Defining tasks with the same name in different namespaces will not cause name conflicts.
This works well especially for large projects.

Rake behaves as follows when it is given the arguments below.

- `rake` => Creates both HTML and PDF
- `rake html:build` => Creates only HTML
- `rake pdf:build` => Creates only PDF
- `rake clean` => Deletes intermediate files
- `rake clobber` => Deletes all generated files

#### The advantage of namespaces

Namespaces are useful for a large Rakefiles and libraries.
When Rakefile becomes very big, it is often split into two or more files.
Usually, they are one main Rakefile and libraries.
If you put a namespace to your library, you don't need to worry about any clashes with the other files.

On the other hand, a small Rakefile can be fine without namespaces.

Namespaces are also useful for categorizing tasks.
When you have a large number of tasks that are called from the command line, you should consider organizing them in namespaces.
For example,

```
# Database related tasks
$ rake db:create
・・・・
# Post related tasks
$ rake post:new
・・・・
```

This helps users remember commands easily.
