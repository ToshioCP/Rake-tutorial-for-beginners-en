### A useful example of Rakefile (2), Namespace

In this section, we will combine Pandoc and Rake to create a PDF file.
The namespaces is also explained here.

#### Pandoc, LaTeX and PDF

Pandoc is able to convert Markdown to PDF.
There can be several intermediate file formats to generate PDF files.
LaTeX, ConTeXt, roff ms, and HTML are such formats.

We will convert Markdown to PDF via LaTeX in the example in this section.

```
Markdown => LaTeX => PDF
```

PdfLaTeX, XeLaTeX and LuaLaTeX can be used as a LaTeX engine to convert a tex file to PDF.
LuaLeTeX will be used in this section..

(Note) Some readers may like engines such as pLaTeX and upLaTeX.
Pandoc doesn't seem to support them as a PDF creation engine.
If you want to use those engines, generate a LaTeX document with Pandoc and convert it to PDF with the respective engine.
Rakefile will be a little more complicated.

#### Preparation

Metadata at the beginning of the Markdown configure some information for Pandoc.
They are written in YAML format.
For more information about YAML, see [Wikipedia](https://en.wikipedia.org/wiki/YAML) or [YAML official page](https://yaml.org/).

```
% Rake tutorial for beginners
% ToshioCP
% August 7, 2022

---
document class: article
toc: true
numbersections: true
secnumdepth: 2
---
```

Metadata starting with % is the same as the one in the previous section.
They represents the title, author, and date of creation, respectively.
The part surrounded by `---` lines is YAML metadata.
See the Pandoc manual for what items can be set here.
The items here are as follows.

- Use 'article' as the document class for LaTeX documents
- Output table of contents
- Number sections (no numbering, which is false, is the default value)
- Sections are numbered from the largest heading to the second largest.
The largest heading in the "article" document class is "section" and the second largest is "subsection".
These correspond to '#' and '##' ATX headings in Markdown.

Add the above to the beginning of "sec1.md".

In the previous section, I used "###" to "#####" for headings in the Markdown files, but that doesn't make it a LaTeX section or subsection, so I need to change it from "#" to "###".
Since it is troublesome to do it manually, I will create a Ruby program and change them.

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

Save this file as `ch_head.rb` and run it.
(Sample files are in `example/example5`)

```
$ ruby ​​ch_head.rb
```

The headings have fixed.

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

You can start with the previous Rakefile and modify it.
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

The Markdown files in `example/example5` have already been modified with metadata and headings.

Run Rake on `example/example5`.

```
$ rake
pandoc -s --pdf-engine lualatex -o Beginning Rake.pdf Beginning Rake.md
$
```

It takes a little longer than before (about 10 seconds).

Please check the created PDF.

It is convenient to create a PDF from Markdown.

HTML is suitable for publishing on the web, and PDF is suitable for viewing at hand.
In the next subsection, we'll combine these two tasks into a single Rakefile.

#### Namespaces

Now we combine two tasks (HTML and PDF) into one Rakefile.
I would like to organize the tasks in an easy-to-understand manner.
In general, complicated programs are hard to maintain.
It is called software "maintainability" and one of the most important thing in program developing.
We use namespaces here to make the program clearer.

Namespaces are a common technique when building large programs, and are not limited to Rake.
Here, we define two namespaces like this:

- Put the tasks for HTML in the namespace "html"
- Put the tasks for PDF in the namespace "pdf"

A namespace is declared with `namespace` method.

```
namespace namespace name do
  Task definition
  ・・・・
end
```

In the previous Rakefile, each work was started with the default task, but this time we will set up a "build" task for each.
Since the "build" task is defined under the namespace, they are:

- html:build => task to build HTML
- pdf:build => task to build PDF

In this way, tasks under a namespace are represented by connecting them with a colon, such as "namespace\_name: task\_name".

Namespaces only apply to general tasks (not file or directory tasks).
A file task is a filename, and the filename doesn't change even if it's defined in a namespace.
Namespaces are also not used when referencing file tasks.

#### Preparation

Some preparations are required to combine two tasks into one Rakefile.

- Keep all metadata (including title, author, date and time) in a separate file.
Prepare “metadata\_html.yml” for HTML and “metadata\_pdf.yml” for PDF.
- In PDF, it is necessary to change the heading (for example, change "###" to "#"), so save the changed "sec1.md" to "sec\_pdf1.md".
Do the same for other files.
This operation is described in the Rakefile.

First, create metadata.

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

Delete the metadata starting with % that was at the beginning of "sec1.md".
Please make sure that the heading of "sec1.md" is the ATX heading from "###" to "#####".

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
In the previous Rakefile, the source files are collected with `sources=FileList["sec*.md"]` statement.
But the statment possibly picks up intermediate files `sec?_pdf.md`.
So glob pattern is not appropriate in this version.
So, the each source file is specified in the arguments of `FileList[]` method.
- A new option `--metadata-file=` is given to Pandoc to import metadata.
- When creating the PDF, I used an intermediate file such as "sec_pdf1.md" with changed headings.
Also, changing the heading is defined as a file task action.
I used the `gsub` method instead of `gsub!` for string substitution.
Since the return values ​​are different between the both, it is better not to use methods with exclamation.
(It is prone to include bugs because `gsub!` returns `nil` when the replacement does not occur.)

Defining tasks with the same name in different namespaces will not cause name conflicts.
This works well especially for large projects.

Give arguments to `rake` like this:

- `rake` => Both HTML and PDF are created
- `rake html:build` => Only HTML is created
- `rake pdf:build` => Only PDF is created
- `rake clean` => Delete intermediate files
- `rake clobber` => Delete all generated files

#### The advantage of namespaces

Namespaces are useful for organizing the contents of large Rakefiles.
And a large Rakefile can often be split into two or more files.
Usually, they include one main Rakefile and other libraries.
Namespaces are especially useful in libraries to prevent task names from clashes with the other files.

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
