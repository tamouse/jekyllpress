require 'thor'
require 'jekyll'
require 'fileutils'
require 'stringex_lite'
require "jekyllpress/version"

module Jekyllpress

  SETUPERROR_MESSAGE = "It appears you have not set up a template directory yet.\nRun `#{$0} setup` to set up the templates properly."
  class SetupError < RuntimeError; end

  class App < Thor
    include Thor::Actions
    package_name 'Jekyllpress::App'
    map ["-V","--version"] => :version

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
      raise "location can not be an absolute path: #{location}" if location[0] == ?/

      with_config do |config|
        filename = destination(source, location, page_dirname(title), index_name)

        template(File.join(template_dir, new_page_template), filename)

        [__method__, @title, filename, location]
      end
    end

    desc "redirect OLD_DIR", "Add a jekyll-redirect-from entry in every post based on OLD_DIR"
    method_option :permalink_template, :desc => "Format of permalink for redirect (old format)", :type => :string, :aliases => %w[-p]
    method_option :force, :desc => "Force writing of redirect_from, even if there is one already", :type => :boolean, :aliases => %w[-F]
    def redirect(old_dir="")
      @old_dir = old_dir.to_s
      @old_dir = ask("Old directory to use in redirect: ") if @old_dir.empty?
      permalink_template = options.fetch("permalink_template") { Jekyll::Configuration::DEFAULTS["permalink"] }
      force_redirect = options.fetch("force") { false }
      processed_posts = []
      with_posts({"permalink" => permalink_template}) do |post|
        # binding.pry
        if post.data.has_key?("redirect_from") && !force_redirect
          say "skipping #{post.name} - redirect_from detected"
          next 
        end

        time_now = Time.now
        insert_text = %Q{# BEGIN: redirect added by jekyllpress on #{time_now}
redirect_from:
  - #{File.join('', old_dir, post.url)}
# END:   redirect added by jekyllpress on #{time_now}
}
        insert_into_file(post_file_name(post), insert_text, :after => %r{\A---\n})

        processed_posts << {name: post.name, file: post_file_name(post)}
      end

      binding.pry
      [__method__, @old_dir, processed_posts]
    end

    private

    def with_config(options={})
      raise "no block given at #{caller[1]}" unless block_given?
      self.class.source_root(jekyll_config["source"])
      yield jekyll_config
    end

    def with_posts(options={})
      with_config(options) do |config|
        site = Jekyll::Site.new(config)
        site.reset
        site.read
        site.posts.each do |post|
          yield post
        end
        site.reset
      end
    end

    def check_templates
      raise SetupError.new SETUPERROR_MESSAGE unless jekyll_config.has_key?("templates")
      File.stat(File.join(source, template_dir))
      File.stat(File.join(source, template_dir, new_page_template))
      File.stat(File.join(source, template_dir, new_post_template))
    rescue ::Errno::ENOENT => error
      raise SetupError.new SETUPERROR_MESSAGE
    end

    def jekyll_config(options={})
      @jekyll_config ||= begin
        conf = Jekyll.configuration(options)
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
      # @jekyll_config ||= Jekyll.configuration(options)
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

    def post_file_name(post)
      File.join(post.site.source, post.path)
    end

  end

end
