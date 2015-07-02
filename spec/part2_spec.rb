# This is the autograder for CS169 HW5: Refactoring & Legacy.
# Author: James Eady <jeady@berkeley.edu>

require 'rspec'
require 'nokogiri'
require 'rubygems'
require 'mechanize'
require 'ruby-debug'

uri = ENV['HEROKU_URI']
uri = 'http://' + uri if uri and uri !~ /^http:\/\//
uri = URI.parse(uri) if uri
$host = URI::HTTP.build(:host => uri.host, :port => uri.port).to_s if uri
$admin_user = ENV['ADMIN_USER']
$admin_pass = ENV['ADMIN_PASS']

# Helper functions. Each of these methods also has a test case dedicated to
# performing a sanity check that ensures that each of these methods should
# succeed every time it is called, thus there is no need to do any extra rspec
# expectations to these functions.

# Log in using $user:$pass.
def login(agent, user, pass)
  page = agent.get URI.join($host, 'accounts/login')
  page.form_with(:action => '/accounts/login') do |f|
    f['user[login]'] = user
    f['user[password]'] = pass
    agent.submit f
  end
end

# Delete all categories containing '[CS169 Autograde] '.
def clean_categories(agent)
  page = agent.get URI.join($host, 'admin/categories/new')
  page.links_with(:text => /\[CS169 Autograder\]/).each do |link|
    link.href =~ /\/([0-9]+)$/
    destroy_category(agent, $1)
  end
end

# Destroy the specified category.
def destroy_category(agent, id)
  destroy_page = agent.get URI.join($host, 'admin/categories/destroy/' + id)
  destroy_page.form_with(:action => '/admin/categories/destroy/' + id) do |f|
    page = agent.submit f
  end
end

# These are essentially sanity tests. They ensure that the target is running,
# the supplied admin username and password are correct, and that the target
# is running as expected.
describe 'Typo' do
  it 'should respond to a simple request [0 points]' do
    agent = Mechanize.new
    page = agent.get($host)
  end

  it 'should authenticate the supplied user as an administrator [0 points]' do
    agent = Mechanize.new
    page = agent.get URI.join($host, 'accounts/login')

    page.search('form[action="/accounts/login"]').size.should == 1
    page.form_with(:action => '/accounts/login') do |f|
      f['user[login]'] = $admin_user
      f['user[password]'] = $admin_pass
      page = agent.submit f
      page.body.should include 'Login successful'
      page.body.should_not include 'Login unsuccessful'
    end
  end
end

# This is the meat of the grader, testing the admin categories functionality.
describe 'The categories page' do
  before :all do
    agent = Mechanize.new
    login(agent, $admin_user, $admin_pass)
    clean_categories(agent)
  end

  before :each do
    @agent = Mechanize.new
    login(@agent, $admin_user, $admin_pass)
  end

  after :each do
    clean_categories(@agent)
  end

  it 'should support creating new categories [50 points]' do
    page = @agent.get URI.join($host, 'admin/categories/new')
    page.search('form[action="/admin/categories/edit"]').size.should == 1
    page.form_with(:action => '/admin/categories/edit') do |f|
      name = '[CS169 Autograder] Cat 1234'
      desc = 'Lorem ipsum dolor sit amet 4444'
      f['category[name]'] = name
      f['category[permalink]'] = 'cs169agcat1234'
      f['category[description]'] = desc
      page = @agent.submit f
      page.body.should include 'was successfully saved'
      page.body.should include name
    end
  end

  it 'should support editing existing categories [50 points]' do
    page = @agent.get URI.join($host, 'admin/categories/new')
    page.search('form[action="/admin/categories/edit"]').size.should == 1
    page.form_with(:action => '/admin/categories/edit') do |f|
      name = '[CS169 Autograder] Cat 1234'
      desc = 'Lorem ipsum dolor sit amet 4444'
      f['category[name]'] = name
      f['category[permalink]'] = 'cs169agcat1234'
      f['category[description]'] = desc
      page = @agent.submit f
      page.body.should include 'was successfully saved'
      page.body.should include name
    end
  end

  it 'should support editing existing categories [50 points]' do
    page = @agent.get URI.join($host, 'admin/categories/new')
    page.search('form[action="/admin/categories/edit"]').size.should == 1
    page.form_with(:action => '/admin/categories/edit') do |f|
      name = '[CS169 Autograder] Cat 1234'
      desc = 'Lorem ipsum dolor sit amet 4444'
      f['category[name]'] = name
      f['category[permalink]'] = 'cs169agcat1234'
      f['category[description]'] = desc
      page = @agent.submit f
      page.body.should include 'was successfully saved'
      page.body.should include name

      page.links_with(:text => name).size.should == 1
      page.link_with(:text => name).href =~ /\/([0-9]+)$/
      id = $1

      page = @agent.get URI.join($host, 'admin/categories/edit/' + id)
      page.search('form[action="/admin/categories/edit/' + id.to_s + '"]').size.should == 1
      page.form_with(:action => '/admin/categories/edit/' + id.to_s) do |f|
        old_name = name
        name = '[CS169 Autograder] Cat 4321'
        desc = 'Lorem ipsum dolor sit amet 4444'
        f['category[name]'] = name
        f['category[permalink]'] = 'cs169agcat4321'
        f['category[description]'] = desc
        page = @agent.submit f
        page.body.should include 'was successfully saved'
        page.body.should include name
        page.body.should_not include old_name
      end
    end
  end
end