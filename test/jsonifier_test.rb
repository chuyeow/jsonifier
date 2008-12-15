require File.join(File.dirname(__FILE__), 'test_helper')

require 'jsonifier/json_encoding'

class DatabaseConnectedJsonEncodingTest < Test::Unit::TestCase
  fixtures :authors, :posts, :comments, :tags, :taggings

  def setup
    @david = authors(:david)
  end

  def test_includes_uses_association_name
    json = @david.to_json(:include => :posts)

    assert_match %r{"id": 1}, json
    assert_match %r{"name": "David"}, json
    assert_match %r{"posts": \[}, json

    assert_match %r{"author_id": 1}, json
    assert_match %r{"title": "Welcome to the weblog"}, json
    assert_match %r{"body": "Such a lovely day"}, json

    assert_match %r{"title": "So I was thinking"}, json
    assert_match %r{"body": "Like I hopefully always am"}, json
  end

  def test_includes_uses_association_name_and_applies_attribute_filters
    json = @david.to_json(:include => { :posts => { :only => :title } })

    assert_match %r{"name": "David"}, json
    assert_match %r{"posts": \[}, json

    assert_match %r{"title": "Welcome to the weblog"}, json
    assert_no_match %r{"body": "Such a lovely day"}, json

    assert_match %r{"title": "So I was thinking"}, json
    assert_no_match %r{"body": "Like I hopefully always am"}, json
  end

  def test_includes_fetches_second_level_associations
    json = @david.to_json(:include => { :posts => { :include => { :comments => { :only => :body } } } })

    assert_match %r{"name": "David"}, json
    assert_match %r{"posts": \[}, json

    assert_match %r{"comments": \[}, json
    assert_match %r{\{"body": "Thank you again for the welcome"\}}, json
    assert_match %r{\{"body": "Don't think too hard"\}}, json
    assert_no_match %r{"post_id": }, json
  end

  def test_includes_fetches_nth_level_associations
    json = @david.to_json(
      :include => {
        :posts => {
          :include => {
            :taggings => {
              :include => {
                :tag => { :only => :name }
              }
            }
          }
        }
    })

    assert_match %r{"name": "David"}, json
    assert_match %r{"posts": \[}, json

    assert_match %r{"taggings": \[}, json
    assert_match %r{"tag": \{"name": "General"\}}, json
  end

  def test_should_not_call_methods_on_associations_that_dont_respond
    def @david.favorite_quote; "Constraints are liberating"; end
    json = @david.to_json(:include => :posts, :methods => :favorite_quote)

    assert !@david.posts.first.respond_to?(:favorite_quote)
    assert_match %r{"favorite_quote": "Constraints are liberating"}, json
    assert_equal %r{"favorite_quote": }.match(json).size, 1
  end
end


class Contact < ActiveRecord::Base
  # mock out self.columns so no pesky db is needed for these tests
  def self.columns() @columns ||= []; end
  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  column :name,       :string
  column :age,        :integer
  column :avatar,     :binary
  column :created_at, :datetime
  column :awesome,    :boolean
  column :gender,     :string
end
class JsonEncodingWithMockedModelsTest < Test::Unit::TestCase

  def setup
    @david = Contact.new(
               :name => 'David',
               :age => 27,
               :awesome => true,
               :gender => 'Male')
  end

  def test_should_encode_all_encodable_attributes
    json = @david.to_json

    assert_match %r{"name": "David"}, json
    assert_match %r{"age": 27}, json
    assert_match %r{"awesome": true}, json
    assert_match %r{"gender": "Male"}, json
  end

  def test_binary_attributes_should_be_skipped
    assert_no_match %r{"avatar": }, @david.to_json
  end

  def test_should_allow_attribute_filtering_with_only
    json = @david.to_json(:only => [:age, :name])

    assert_match %r{"name": "David"}, json
    assert_match %r{"age": 27}, json
    assert_no_match %r{"awesome": true}, json
    assert_no_match %r{"gender": "Male"}, json
  end

  def test_should_allow_attribute_filtering_with_except
    json = @david.to_json(:except => [:age, :gender])

    assert_match %r{"name": "David"}, json
    assert_match %r{"awesome": true}, json
    assert_no_match %r{"age": 27}, json
    assert_no_match %r{"gender": "Male"}, json
  end

  def test_methods_are_called_on_object
    # Define methods on fixture.
    def @david.label; "Father of Rails"; end
    def @david.favorite_quote; "Constraints are liberating"; end

    # Single method.
    assert_equal %({"name": "David", "label": "Father of Rails"}), @david.to_json(:only => :name, :methods => :label)

    # Both methods.
    methods_json = @david.to_json(:only => :name, :methods => [:label, :favorite_quote])
    assert_match %r{"label": "Father of Rails"}, methods_json
    assert_match %r{"favorite_quote": "Constraints are liberating"}, methods_json
  end
end