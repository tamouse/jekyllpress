# Jekyllpress

A [Thor](http://whatisthor.com) script that provides several actions to help support and use a [Jekyll](http://jekyllrb.com) site.

## Installation

    $ gem install jekyllpress

## Usage

### New Post

Creating a new post is done with:

    $ jekyllpress new_post 'This is my new post!!' --categories=new really --tags=so what
    Configuration file: /Volumes/muis1t/Projects/rubystuff/jekyll/test_jekyll_2.1/_config.yml
          create  _posts/2014-07-28-this-is-my-new-post.markdown

This creates a new file in `_posts` with the current date stamp, and contents as:

```
---
layout: post
title: This is my new post!!
date: 2014-07-28 01:15
categories: ["new", "really"]
tags: ["so", "what"]
---
```

### New Page

Creating a new page is just as simple:

    $ jekyllpress new_page "Some Page" --location=pages
    Configuration file: /Volumes/muis1t/Projects/rubystuff/jekyll/test_jekyll_2.1/_config.yml
          create  pages/some-page/index.markdown

The content is:

```
---
layout: page
title: Some Page
date: 2014-07-28 01:17
---
```

### Getting Help

Actions and options can be seen by running `jekyllpress` with no paramters, or with the `help` action:

    $ jekyllpress help
    Jekyllpress::App commands:
      jekyllpress help [COMMAND]  # Describe available commands or one specific command
      jekyllpress new_page TITLE  # Create a new page with title TITLE
      jekyllpress new_post TITLE  # Create a new posts with title TITLE
      jekyllpress setup           # Set up templates
      jekyllpress version         # Display Jekyllpress::App version string

To see the options for `new_post`, enter:

    $ jekyllpress help new_post

```
Usage:
  jekyllpress new_post TITLE

Options:
  -c, [--categories=one two three]  # list of categories to assign this post
  -t, [--tags=one two three]        # list of tags to assign this post

Create a new post with title TITLE
```

* `categories` and `tags` are arrays. Give each category or tag item after the parameter.
* The equals sign after the option name is ... *optional*.

To see the options for `new_page`, enter:

    $ jekyllpress help new_page

```
Usage:
  jekyllpress new_page TITLE

Options:
  -l, --loc, [--location=LOCATION]  # Location for page to appear in directory

Create a new page with title TITLE
```

* the `location` option lets you specify a path down to where the page will live.
* the location *must* be relative, and will placed starting from the source folder.

### Setting Up Templates

If you don't have templates specified in your `_config.yml` file or in your `source` folder, you can create them with the `setup` action:

    $ jekyllpress setup
    Configuration file: /Volumes/muis1t/Projects/rubystuff/jekyll/test_jekyll_2.1/_config.yml
          create  _templates
          create  _templates/new_post.markdown
          create  _templates/new_page.markdown

You can edit the markdown templates to your heart's delight. :)

## Contributing

*"Fork it, Branch it, Commit it, Push it"*

1. Fork it ( https://github.com/tamouse/jekyllpress/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
