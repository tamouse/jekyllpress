require 'spec_helper'

TEST_SITE = 'test_site'

def kill_jekyll
  # This is a weird little discombobulation.
  # I'm not altogether sure why I have to do this, but apparently
  # the way thor, rspec, and jekyll all meld, something goes haywire.
  $".delete_if{|x| x.match(%r[(/gems/jekyll-.+/lib/jekyll)])}
  # run `load 'jekyllpress.rb'` in each test setup where you have a
  # jekyll test directory to work with
end

describe "my Jekyllpress Thor script" do

  describe ":version" do
    before(:all) do
      kill_jekyll
      load 'jekyllpress.rb'
    end

    it {expect(Jekyllpress::App.start(%w[version])).to include(Jekyllpress::VERSION)}
    it {expect(Jekyllpress::App.start(%w[-V])).to include(Jekyllpress::VERSION)}
    it {expect(Jekyllpress::App.start(%w[--version])).to include(Jekyllpress::VERSION)}
  end

  describe ":new_post" do
    before(:all) do
      kill_jekyll
      Dir.chdir("spec") do |spec_dir|
        FileUtils.rm_rf TEST_SITE
        `jekyll new #{TEST_SITE}`
        Dir.chdir(TEST_SITE) do |test_site|
          FileUtils.mkdir_p '_my_collection'
          load 'jekyllpress.rb'
          Jekyllpress::App.start(%w[setup])
        end
      end
    end

    after(:all) do
      Dir.chdir("spec") do |spec_dir|
        FileUtils.rm_rf TEST_SITE
      end
    end

    context "when using all defaults" do
      before(:all) do
        @action, @title, @date, @time, @filename, @categories, @tags, @layout, @url, @template, @location =
          Jekyllpress::App.start(%w[new_post Using\ The\ Defaults])
      end
      it {expect(@action).to eq :new_post}
      it {expect(@title).to eq "Using The Defaults"}
      it {expect(@date).to eq Date.today.iso8601}
      it {expect(@categories).to eq []}
      it {expect(@tags).to eq []}
      it {expect(@template).to eq 'new_post.markdown'}
      it {expect(@filename).to be_a String}
      it {expect(@filename).not_to be_empty}
      it {expect(@filename).to match %r{/_posts/.*-using-the-defaults\.markdown} }
      it {expect(@location).to eq "_posts"}
    end

    context "when using the default template" do
      before(:all) do
        @action, @title, @date, @time, @filename, @categories, @tags, @layout, @url, @template, @location = Jekyllpress::App.start(%w[new_post A\ New\ Post --date=2001-01-01 --time=11:15 -c one two three -t able baker charlie -l post2 --url=https://github.com/tamouse])
      end

      it {expect(@action).to eq :new_post}
      it {expect(@title).to eq "A New Post"}
      it {expect(@date).to eq '2001-01-01'}
      it {expect(@time).to eq '11:15'}
      it {expect(@categories).to eq %w[one two three]}
      it {expect(@tags).to eq %w[able baker charlie]}
      it {expect(@layout).to eq 'post2'}
      it {expect(@url).to eq 'https://github.com/tamouse'}
      it {expect(@template).to eq 'new_post.markdown'}
      it {expect(@filename).to be_a String}
      it {expect(@filename).not_to be_empty}
      it {expect(@filename).to include("/_posts/2001-01-01-a-new-post.markdown")}
      it {expect(@location).to eq "_posts"}
    end


    context "when giving an alternate template" do
      before(:all) do
        alt_template = <<-EOF
--
layout: link
title: <%= @title %>
date: <%= Time.now.strftime("%Y-%m-%d %H:%M") %>
---
alternate template

EOF
        test_dir = File.expand_path('../../',__FILE__)
        alt_template_file = File.join(test_dir, TEST_SITE, "_templates", "alt_post.markdown")


        File.write(alt_template_file, alt_template)

        @action, @title, @date, @time, @filename, @categories, @tags, @layout, @url, @template, @location = Jekyllpress::App.start(%w[new_post A\ New\ Post\ With\ Alt\ Template -c one two three -t able baker charlie -l link --url=https://github.com/tamouse --template=alt_post.markdown --date=2001-01-01 --time=11:15])
      end

      it {expect(@action).to eq :new_post}
      it {expect(@title).to eq "A New Post With Alt Template"}
      it {expect(@date).to eq '2001-01-01'}
      it {expect(@time).to eq '11:15'}
      it {expect(@categories).to eq %w[one two three]}
      it {expect(@tags).to eq %w[able baker charlie]}
      it {expect(@layout).to eq 'link'}
      it {expect(@url).to eq 'https://github.com/tamouse'}
      it {expect(@template).to eq "alt_post.markdown"}
      it {expect(@filename).to be_a String}
      it {expect(@filename).not_to be_empty}
      it {expect(@filename).to include("/_posts/2001-01-01-a-new-post-with-alt-template.markdown")}
      it {expect(@location).to eq "_posts"}
    end

    context "when using a different location" do
      before(:all) do
        @action, @title, @date, @time, @filename, @categories, @tags, @layout, @url, @template, @location =
          Jekyllpress::App.start(%w[new_post Diff-Location --location=_my_collection])
      end
      it {expect(@action).to eq :new_post}
      it {expect(@title).to eq "Diff-Location"}
      it {expect(@date).to eq Date.today.iso8601}
      it {expect(@categories).to eq []}
      it {expect(@tags).to eq []}
      it {expect(@template).to eq 'new_post.markdown'}
      it {expect(@filename).to be_a String}
      it {expect(@filename).not_to be_empty}
      it {expect(@filename).to match %r{/_my_collection/.*-diff-location\.markdown} }
      it {expect(@location).to eq "_my_collection"}
    end

  end

  describe ":new_page" do
    before(:all) do
      kill_jekyll
      Dir.chdir("spec") do |spec_dir|
        FileUtils.rm_rf TEST_SITE
        `jekyll new #{TEST_SITE}`
        Dir.chdir(TEST_SITE) do |test_site|
          load 'jekyllpress.rb'
          Jekyllpress::App.start(%w[setup])
        end
      end
    end

    after(:all) do
      Dir.chdir("spec") do |spec_dir|
        FileUtils.rm_rf TEST_SITE
      end
    end


    it "should report an error if location is an absolute path" do
      expect{Jekyllpress::App.start(%w[new_page bogus --location /pages])}.to raise_error(RuntimeError, "location can not be an absolute path: /pages")
    end

    context "create a new page" do
      before(:all) do
        @action, @title, @filename, @location, @layout = Jekyllpress::App.start(%w[new_page A\ New\ Page -l=pages --layout=page2])
      end

      after(:all) do
        File.unlink(@filename)
      end

      it {expect(@action).to eq :new_page}
      it {expect(@title).to eq "A New Page"}
      it {expect(@layout).to eq "page2"}
      it {expect(@location).to eq "pages"}
      it {expect(@filename).to be_a String}
      it {expect(@filename).not_to be_empty}
      it {expect(@filename).to include("/pages/a-new-page/index.markdown")}
    end
  end

  describe "no templates" do

    before(:all) do
      kill_jekyll
      Dir.chdir("spec") do |spec_dir|
        FileUtils.rm_rf TEST_SITE
        `jekyll new #{TEST_SITE}`
        Dir.chdir(TEST_SITE) do |test_site|
          load 'jekyllpress.rb'
        end
      end
    end

    after(:all) do
      Dir.chdir("spec") do |spec_dir|
        FileUtils.rm_rf TEST_SITE
      end
    end

    it "should abort when no templates are found" do
      expect{Jekyllpress::App.start(%w[new_page blah])}.to raise_error(Jekyllpress::SetupError)
    end

    context ":setup" do
      before(:all) do
        @action, @source, @template_dir, @new_post_template, @new_page_template = Jekyllpress::App.start(%w[setup])
      end

      it { expect(@action).to eq(:setup) }
      it { expect(@source).to include("spec/test_site") }
      it { expect(@template_dir).to eq("_templates") }
      it { expect(@new_post_template).to eq("new_post.markdown") }
      it { expect(@new_page_template).to eq("new_page.markdown") }

      it "templates directory created" do
        Dir.chdir(File.join("spec",TEST_SITE)) do |test_dir|
          expect(File.directory?(@template_dir)).to eq true
        end
      end

      it "new_post_template created" do
        Dir.chdir(File.join("spec",TEST_SITE)) do |test_dir|
          expect(File.exist?(File.join(@template_dir, @new_post_template)))
        end
      end

      it "new_page_template created" do
        Dir.chdir(File.join("spec",TEST_SITE)) do |test_dir|
          expect(File.exist?(File.join(@template_dir, @new_page_template)))
        end
      end

    end

  end

  xdescribe ":redirect" do
    before do
      kill_jekyll
      Dir.chdir("spec") do |spec_dir|
        FileUtils.rm_rf TEST_SITE
        `jekyll new #{TEST_SITE}`
        Dir.chdir(TEST_SITE) do |test_site|
          load 'jekyllpress.rb'
          File.open(File.join("_posts","2013-12-31-an-old-post.markdown"), 'w') do |post|
            frontmatter = {
              "title" => "An old post",
              "date" => "2013-12-31 12:31",
              "layout" => "post",
              "redirect_from" => Array("/oldsite/2013/12/31/an-old-post/")
            }
            post.puts frontmatter.to_yaml
            post.puts "---"
            post.puts "Old horse kitty kat peanut butter engine."
            post.puts "\n"
            post.puts "This is a post with a redirect_from."
          end
        end
      end
    end

    after do
      Dir.chdir("spec") do |spec_dir|
        FileUtils.rm_rf TEST_SITE
      end
    end

    # after(:each) do # restore backups to normal
    #   @posts.each do |post|
    #     FileUtils.mv("#{post[:file]}.bak", post[:file], force: true, verbose: true)
    #   end
    # end

    it "only one post has a redirect_from: in frontmatter" do
      Dir.chdir(File.join("spec", TEST_SITE)) do |test_site|
        @action, @old_dir, @posts = Jekyllpress::App.start(%w[redirect BLOG])
        expect(@posts.count).to eq(1)
        @posts.each do |post|
          post_content = File.read post[:file]
          expect(post_content).to match(%r{^redirect_from:$})
          expect(post_content).to  match(%r{^  - /BLOG/})
        end
      end
    end

    it "all posts have a redirect_from: in frontmatter" do
      @action, @old_dir, @posts = Jekyllpress::App.start(%w[redirect BLOG -F])
      expect(@posts.count).to  eq(2)
      @posts.each do |post|
        post_content = File.read post[:file]
        expect(post_content).to match(%r{^redirect_from:$})
        expect(post_content).to  match(%r{^  - /BLOG/})
      end
    end

  end

end
