require 'spec_helper'

jekyll_match = %r[(gems/jekyll-.+/lib/jekyll)]
# load 'jekyllpress.rb'; STDERR.puts $".grep(jekyll_match);  exit;

Dir.chdir(Pathname.new('spec/test_site')) do |test_dir|
  $".delete_if{|x| x.match(jekyll_match)} ; load 'jekyllpress.rb' # Have to load this *after* we're in the working directory
  # STDERR.puts Jekyll::Configuration::DEFAULTS["source"]

  describe Jekyllpress::App do

    # it "should bloody well be in the damn spec/test_site directory!!!" do
    #   expect(Jekyll::Configuration::DEFAULTS["source"]).to include("spec/test_site")
    # end

    describe ":version" do
      it {expect(Jekyllpress::App.start(%w[version])).to include(Jekyllpress::VERSION)}
      it {expect(Jekyllpress::App.start(%w[-V])).to include(Jekyllpress::VERSION)}
      it {expect(Jekyllpress::App.start(%w[--version])).to include(Jekyllpress::VERSION)}
    end  

    describe ":new_post" do
      before(:all) do
        # STDERR.puts "test_dir is #{test_dir}"
        Dir.chdir(test_dir) do |test_dir|
          # binding.pry
          @posts_dir = Pathname.new('_posts')
          raise "#{@posts_dir} does not exist!" unless @posts_dir.directory?
          @posts_dir.children.each(&:unlink)
          @templates = Pathname.new('_templates')
          @templates.rmtree if @templates.exist?
          Jekyllpress::App.start(%w[setup])
          @action, @title, @filename, @categories, @tags = Jekyllpress::App.start(%w[new_post A\ New\ Post -c=one two three -t=a b c])
        end
      end
      # it "should bloody well be in the damn spec/test_site directory!!!" do
      #   expect(Jekyll::Configuration::DEFAULTS["source"]).to include("spec/test_site")
      # end
      it {expect(@action).to eq :new_post}
      it {expect(@title).to eq "A New Post"}
      it {expect(@categories).to eq %w[one two three]}
      it {expect(@tags).to eq %w[a b c]}
      it {expect(@filename).to be_a String}
      it {expect(@filename).not_to be_empty}
      it {expect(@filename).to include("#{test_dir}/_posts/#{Time.now.strftime("%Y-%m-%d")}-a-new-post.markdown")}
    end

    describe ":new_page" do
      it "should report an error if location is an absolute path" do
        expect{Jekyllpress::App.start(%w[new_page bogus --location /pages])}.to raise_error(RuntimeError, "location can not be an absolute path: /pages")
      end

      context "create a new page" do
        before(:all) do
          Dir.chdir(test_dir) do |test_dir|
            @pages_dir = Pathname.new('pages')
            raise "#{@pages_dir} does not exist!" unless @pages_dir.directory?
            @pages_dir.children.each(&:rmtree)
            @templates = Pathname.new('_templates')
            @templates.rmtree if @templates.exist?
            Jekyllpress::App.start(%w[setup])
            @action, @title, @filename, @location = Jekyllpress::App.start(%w[new_page A\ New\ Page -l=pages])
          end
        end
        it {expect(@action).to eq :new_page}
        it {expect(@title).to eq "A New Page"}
        it {expect(@location).to eq "pages"}
        it {expect(@filename).to be_a String}
        it {expect(@filename).not_to be_empty}
        it {expect(@filename).to include("#{test_dir}/pages/a-new-page/index.markdown")}
      end
    end

    describe "no templates" do

      before(:all) do
        Dir.chdir(test_dir) do |test_dir|
          @templates = Pathname.new('_templates')
          @templates.rmtree if @templates.exist?
        end
      end
      
      it "should abort when no templates are found" do
        expect{Jekyllpress::App.start(%w[new_page blah])}.to raise_error(::Errno::ENOENT)
        expect(@templates.directory?).not_to eq(true)
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
          Dir.chdir(test_dir) do |test_dir|
            expect(File.directory?(@template_dir)).to eq true
          end
        end
      
        it "new_post_template created" do
          Dir.chdir(test_dir) do |test_dir|
            expect(File.exist?(File.join(@template_dir, @new_post_template)))
          end
        end
      
        it "new_page_template created" do
          Dir.chdir(test_dir) do |test_dir|
            expect(File.exist?(File.join(@template_dir, @new_page_template)))
          end
        end
      
      end

    end

  end
end
