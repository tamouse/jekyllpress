require 'thor'
require 'jekyll'
require 'fileutils'
require 'stringex_lite'
require "jekyllpress/version"

module Jekyllpress

  class App < Thor
    include Thor::Actions
    package_name 'Jekyllpress::App'
    map ["-V","--version"] => :version

    class_option :config, :aliases => "-C", :default => "./_config.yml"

    source_root(Dir.pwd)

    desc "version", "Display Jekyllpress::App version string"
    def version
      say "Jekyllpress Version: #{Jekyllpress::VERSION}"
      Jekyllpress::VERSION
    end

    desc "setup", "Set up templates"
    def setup()
      with_config do |config|
        empty_directory(File.join(source, template_dir))
        create_file(File.join(source, template_dir, new_post_template),
          %q{---
            layout: post
            title: <%= @title %>
            date: <%= Time.now.strftime("%Y-%m-%d %H:%M") %>
            categories: <%= @categories %>
            tags: <%= @tags %>
            ---
            }.gsub(/^\s*/,''))
        create_file(File.join(source, template_dir, new_page_template), 
          %q{---
            layout: page
            title: <%= @title %>
            date: <%= Time.now.strftime("%Y-%m-%d %H:%M") %>
            ---
            }.gsub(/^\s*/,''))
        [__method__, source, template_dir, new_post_template, new_page_template]
      end
    end

    desc "new_post TITLE", "Create a new posts with title TITLE"
    method_option :categories, :desc => "list of categories to assign this post", :type => :array, :aliases => %w[-c]
    method_option :tags, :desc => "list of tags to assign this post", :type => :array, :aliases => %w[-t]
    def new_post(title="")
      check_templates
      @title = title.to_s
      @title = ask("Title for your post: ") if @title.empty?

      @categories = options.fetch("categories", [])
      @tags = options.fetch("tags", [])

      with_config do |config|
        check_templates
        filename = destination(source, posts_dir, post_filename(title))

        template(File.join(template_dir,new_post_template), filename)

        [__method__, @title, filename, @categories, @tags]
      end
    end

    desc "new_page TITLE", "Create a new page with title TITLE"
    method_option :location, :desc => "Location for page to appear in directory", :type => :string, :aliases => %w[-l --loc]
    def new_page(title="")
      check_templates
      @title = title.to_s
      @title = ask("Page title: ") if @title.empty?

      location = options.fetch("location", nil)

      with_config do |config|
        filename = destination(source, location, page_dirname(title), index_name)

        template(File.join(template_dir, new_page_template), filename)

        [__method__, @title, filename, location]
      end
    end

    private

    def with_config
      raise "no block given at #{caller[1]}" unless block_given?
      yield jekyll_config
    end

    def check_templates
      File.stat(File.join(source, template_dir))
      File.stat(File.join(source, template_dir, new_page_template))
      File.stat(File.join(source, template_dir, new_post_template))
    rescue ::Errno::ENOENT => error
      warn "It appears you have not set up a template directory yet.",
        "Run `#{$0} setup` to set up the templates directory"
      raise error
    end

    def jekyll_config
      @jekyll_config ||= begin
        conf = Jekyll.configuration({})
        unless conf.has_key?("templates")
          conf.merge!({
            "templates" => {
              "template_dir" => "_templates",
              "new_post_template" => "new_post.markdown",
              "new_page_template" => "new_page.markdown"
            }
            })
        end
      end

    end
    def new_ext
      jekyll_config["markdown_ext"].split(',').first
    end

    def source
      jekyll_config['source']
    end

    def post_filename(title)
      "#{Time.now.strftime("%Y-%m-%d")}-#{title.to_url}.#{new_ext}"
    end

    def page_dirname(title)
      "#{title.to_url}"
    end

    def index_name(default="index")
      "#{default}.#{new_ext}"
    end

    def posts_dir
      '_posts'
    end

    def destination(*paths)
      File.join(paths.compact.map(&:to_s))
    end

    def template_dir
      jekyll_config["templates"]["template_dir"]
    end

    def new_post_template
      jekyll_config["templates"]["new_post_template"]      
    end

    def new_page_template
      jekyll_config["templates"]["new_page_template"]
    end
  end

end
