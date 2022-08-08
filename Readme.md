# Rake tutorial for beginners

Click [here](https://toshiocp.github.io/Rake-tutorial-for-beginners-en/LearningRake.html) to see the tutorial.

This tutorial is originally written in Japanese and posted to "Omokon" blog.
The contents of this tutorial covers wider range than the original one.
There is a Japanese version [GitHub repository](https://github.com/ToshioCP/Rake-tutorial-for-beginners-jp).

## Download

- Click the green button named "Code" and Click "DownloadZIP".
- `git clone` is also possible.

## Rakefile

Rakefile in the top directory makes HTML file in the `docs` directory.
It converts `sec*.md` to HTML and copies `style.css` and image files into docs directory.

Type rake to generate an HTML file.

```
$ rake
```

Then you can get an HTML file in your local computer.

- `rake clean`: deletes `LerningRake.md`, which is an intermediate file.
- `rake clobber`: deletes all the generated files.
It makes the repository to the initial status.
