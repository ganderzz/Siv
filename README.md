# Siv

Siv is an opinionated, static website generator. The goal of siv is to be simple, and fast. Conventions have been setup to reduce complexities.

### Cli

Siv takes a single argument, the directory which contains the file structure defined below.

For example, if we were to run Siv in this current project for 'example' it would look like:

```
siv ./example
```


### Directory Structure

**view the examples directory for more info**

- posts: contains all markdown posts/content/entries
- templates: contains the files used by posts (uses mustache templating). Currently the only template supported is 'posts.html' to layout posts
  - partials: used to break use html, and be maintainable