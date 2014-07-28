require 'spec_helper'

jekyll_match = %r[(gems/jekyll-.+/lib/jekyll)]
# load 'jekyllpress.rb'; STDERR.puts $".grep(jekyll_match);  exit;

Dir.chdir('spec/test_site') do |test_dir|
  $".delete_if{|x| x.match(jekyll_match)} ; load 'jekyllpress.rb' # Have to load this *after* we're in the working directory
  # load 'jekyllpress.rb'
  describe Jekyllpress::App do
    describe ":version returns the version string" do
      it {expect(Jekyllpress::App.start(%w[version])).to include(Jekyllpress::VERSION)}
      it {expect(Jekyllpress::App.start(%w[-V])).to include(Jekyllpress::VERSION)}
      it {expect(Jekyllpress::App.start(%w[--version])).to include(Jekyllpress::VERSION)}
    end  

    describe ":new_post returns the title, categories and tags" do
      FileUtils.rm_rf "_posts/"
      action, title, filename, categories, tags = Jekyllpress::App.start(%w[new_post A\ New\ Post -c=one two three -t=a b c])

      it {expect(action).to eq :new_post}
      it {expect(title).to eq "A New Post"}
      it {expect(categories).to eq %w[one two three]}
      it {expect(tags).to eq %w[a b c]}
      it {expect(filename).to be_a String}
      it {expect(filename).not_to be_empty}
      it {expect(filename).to include("#{test_dir}/_posts/#{Time.now.strftime("%Y-%m-%d")}-a-new-post.markdown")}
    end

    describe ":new_page returns title, filename, location" do
      FileUtils.rm_rf "pages/a-new-page"
      action, title, filename, location = Jekyllpress::App.start(%w[new_page A\ New\ Page -l=pages])

      it {expect(action).to eq :new_page}
      it {expect(title).to eq "A New Page"}
      it {expect(location).to eq "pages"}
      it {expect(filename).to be_a String}
      it {expect(filename).not_to be_empty}
      it {expect(filename).to include("#{test_dir}/pages/a-new-page/index.markdown")}
    end
  end
end

Dir.chdir('tmp') do |test_dir|

  FileUtils.rm_rf 'blank'
  raise "failed to erase blank" if File.directory?('blank')
  x = `bundle exec jekyll new blank`
  raise "jekyll new failed: #{x}" unless $?.success?
  Dir.chdir('blank') do |blank|
    $".delete_if{|x| x.match(jekyll_match)} ; load 'jekyllpress.rb' # Have to load this *after* we're in the working directory
    describe "pristine jekyll installation" do

      it "should bloody well be inside the blank directory!!!" do
        expect(Jekyll::Configuration::DEFAULTS["source"]).to include("blank")
      end
      it "should abort when no templates are found" do
        templates_dir = File.join(test_dir, blank, '_templates')
        FileUtils.rm_rf templates_dir
        expect{Jekyllpress::App.start(%w[new_page blah])}.to raise_error(::Errno::ENOENT)
        expect(File.directory?(templates_dir)).not_to eq(true)
      end

      describe ":setup creates the template directory and contents" do
        before(:all) do
          @templates_dir = File.join(test_dir, blank, '_templates')
          FileUtils.rm_rf @templates_dir
          @result = Jekyllpress::App.start(%w[setup])
        end

        it {expect(@result[0]).to eq(:setup)}
        it {expect(@result[1]).to include('blank')}
        it {expect(@result[2]).to eq("_templates")}
        it {expect(@result[4]).to eq("new_page.markdown")}
        it {expect(@result[3]).to eq("new_post.markdown")}
        it "templates directory exists" do
          expect(File.directory?(@templates_dir)).to eq(true)
        end
        it "new_page_template exists" do
          Dir.chdir(@templates_dir) do |templates_dir|
            expect(File.exist?("new_page.markdown")).to eq(true)
          end
        end
        it "new_post_template exists" do
          Dir.chdir(@templates_dir) do |templates_dir|
            expect(File.exist?("new_post.markdown")).to eq(true)
          end
        end
      end
    end


  end

end
