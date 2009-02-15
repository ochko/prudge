
# AR_PATH = 'c:/dev/rails/activerecord' || ARGS[0]
# $:.unshift("#{AR_PATH}/test")
# $:.unshift("#{AR_PATH}/test/connections/native_mysql")
# $:.unshift(File.dirname(__FILE__) + '/../lib')

require 'abstract_unit'
require 'taggable'

ActiveRecord::Base.connection.drop_table :tags rescue nil
ActiveRecord::Base.connection.drop_table :tags_topics rescue nil
ActiveRecord::Base.connection.drop_table :keywords rescue nil
ActiveRecord::Base.connection.drop_table :keywords_companies rescue nil
ActiveRecord::Base.connection.drop_table :tags_posts rescue nil

ActiveRecord::Base.connection.create_table :tags do |t|
  t.column :name, :string
end

ActiveRecord::Base.connection.create_table :tags_topics, :id => false do |t|
  t.column :tag_id, :int
  t.column :topic_id, :int
  t.column :created_at, :time
end

ActiveRecord::Base.connection.create_table :keywords do |t|
  t.column :name, :string
end

ActiveRecord::Base.connection.create_table :keywords_companies, :id => false do |t|
  t.column :keyword_id, :int
  t.column :company_id, :int
end

ActiveRecord::Base.connection.create_table :tags_posts do |t|
  t.column :tag_id, :int
  t.column :post_id, :int
  t.column :created_at, :time
  t.column :created_by_id, :int  
  t.column :position, :int
end

class Tag < ActiveRecord::Base; end
class Topic < ActiveRecord::Base
  acts_as_taggable
end

class Keyword < ActiveRecord::Base; end
  
class Company < ActiveRecord::Base
  acts_as_taggable :collection => :keywords, :tag_class_name =>  'Keyword'
  def tag_model 
    Keyword
  end
end

class Firm < Company; end
class Client < Company; end

class Post < ActiveRecord::Base
  acts_as_taggable :join_class_name => 'TagPost'
end

class TagPost
  acts_as_list :scope => :post
  
  def before_save
    self.created_by_id = rand(3) + 1
  end
end

class Order < ActiveRecord::Base
end

class ActAsTaggableTest < Test::Unit::TestCase
  # fixtures :topics, :companies, :posts

  def setup
    Tag.delete_all
    Keyword.delete_all

    ActiveRecord::Base.connection.execute 'delete from tags_topics'
    ActiveRecord::Base.connection.execute 'delete from keywords_companies'
    ActiveRecord::Base.connection.execute 'delete from tags_posts'

    create_fixtures 'posts'
    create_fixtures 'companies'
    create_fixtures 'topics'
  end

  def test_singleton_methods
    assert !Order.respond_to?(:find_tagged_with)  
    assert Firm.respond_to?(:find_tagged_with)  
    assert Post.respond_to?(:find_tagged_with)  
    assert Topic.respond_to?(:find_tagged_with)  
    assert Topic.respond_to?(:tag_count)  
    assert Topic.respond_to?(:tags_count)  
  end
  
  def test_with_defaults
    test_tagging(Topic.find(:first), Tag, :tags)
  end

  def test_with_non_defaults
    test_tagging(Company.find(:first), Keyword, :keywords)
  end

  def test_tag_with_new_object
    topic = Topic.new
    topic.tag 'brazil rio beach'
    topic.save
  end
  
  def test_tagging_with_join_model
    Tag.delete_all
    TagPost.delete_all
    post = Post.find(:first)
    tags = %w(brazil rio beach)
    
    post.tag(tags)
    tags.each { |tag| assert post.tagged_with?(tag) }

    post.save
    post.tags.reload
    tags.each { |tag| assert post.tagged_with?(tag) }
    
    posts = Post.find_tagged_with(:any => 'brazil sampa moutain')
    assert_equal posts[0], post
    
    posts = Post.find_tagged_with(:all => 'brazil beach')
    assert_equal posts[0], post
    
    posts = Post.find_tagged_with(:all => 'brazil rich')
    assert_equal 0, posts.size
    
    posts = Post.find_tagged_with(:all => 'brazil', :conditions => [ 'tags_posts.position = ?', 1])
    assert_equal posts[0], post
    
    posts = Post.find_tagged_with(:all => 'rio', :conditions => [ 'tags_posts.position = ?', 2])
    assert_equal posts[0], post

    posts = Post.find_tagged_with(:all => 'beach', :conditions => [ 'tags_posts.position = ?', 3])
    assert_equal posts[0], post
  end

  def test_tags_count_with_join_model  
    p1 = Post.create(:title => 'test1')
    p2 = Post.create(:title => 'test2')    
    p3 = Post.create(:title => 'test3')    
     
    p1.tag 'a b c d'
    p2.tag 'a c e f'
    p3.tag 'a c f g'
    
    counts = Post.tags_count :count => '>= 2', :limit => 2
    assert_equal counts.keys.size, 2    
    counts.each { |tag, count| assert count >= 2 }
    assert counts.keys.include?('a')    
    assert counts.keys.include?('c')    
  end
  
  def test_tags_count
    t1 = Topic.create(:title => 'test1')
    t2 = Topic.create(:title => 'test2')    
    t3 = Topic.create(:title => 'test3')    
     
    t1.tag 'a b c d'
    t2.tag 'a c e f'
    t3.tag 'a c f g'
    
    count = Topic.tags_count    
    assert_equal 3, count['a']
    assert_equal 1, count['b']
    assert_equal 3, count['c']
    assert_equal 1, count['d']
    assert_equal 1, count['e']
    assert_equal 2, count['f']
    assert_equal 1, count['g']
    assert_equal nil, count['h']

    count = Topic.tags_count :count => '>= 2'    
    assert_equal 3, count['a']
    assert_equal nil, count['b']
    assert_equal 3, count['c']
    assert_equal nil, count['d']
    assert_equal nil, count['e']
    assert_equal 2, count['f']
    assert_equal nil, count['g']
    assert_equal nil, count['h']
    
    t4 = Topic.create(:title => 'test4')    
    t4.tag 'a f'
    
    count = Topic.tags_count :limit => 3    
    assert_equal 4, count['a']
    assert_equal nil, count['b']
    assert_equal 3, count['c']
    assert_equal nil, count['d']
    assert_equal nil, count['e']
    assert_equal 3, count['f']
    assert_equal nil, count['g']
    assert_equal nil, count['h']
    
    raw = Topic.tags_count :raw => true
    assert_equal 7, raw.size
    assert_equal Array, raw.class
    assert_equal 'a', raw.first['name']
    assert_equal '4', raw.first['count']
    assert_not_nil raw.first['id']
    assert_equal 'g', raw.last['name']
    assert_equal '1', raw.last['count']
    assert_not_nil raw.last['id']
  end
  
  def test_find_related_tagged
    t1, t2, t3, t4, t5, t6 = create_test_topics

    assert_equal [ t4, t2, t3 ], t1.tagged_related(:limit => 3)
    assert_equal [ t5, t1, t3 ], t2.tagged_related(:limit => 3)
    assert_equal [ t1, t4, t6 ], t3.tagged_related(:limit => 3)
    assert_equal [ t1, t3, t6 ], t4.tagged_related(:limit => 3)
    assert_equal [ t2, t1, t3 ], t5.tagged_related(:limit => 3)
    assert_equal [ t1, t3, t4 ], t6.tagged_related(:limit => 3)
  end

  def test_find_related_tags
    t1, t2, t3, t4, t5, t6 = create_test_topics
    
    tags = Topic.find_related_tags('rome walking')

    assert_equal 1, tags['greatview']
    assert_equal 2, tags['clean']
    assert_equal 1, tags['mustsee']

    # originaly was:
    # 
    # assert_equal 2, tags['greatview']
    # assert_equal 4, tags['clean']
    # assert_equal 2, tags['mustsee']
  end
  
  def test_find_tagged_with_on_subclasses
    firm = Firm.find(:first)
    firm.tag 'law'
    firms = Firm.find_tagged_with :any => 'law'
    assert_equal firm, firms[0]
    assert_equal 1, firms.size
  end
  
  def test_find_tagged_with_any
    topic1 = Topic.create(:title => 'test1')
    topic2 = Topic.create(:title => 'test2')    
    topic3 = Topic.create(:title => 'test3')    
    
    topic1.tag('a b c'); topic1.save
    topic2.tag('a c e'); topic2.save
    topic3.tag('c d e'); topic3.save
    
    topics = Topic.find_tagged_with(:any => 'x y z')
    assert_equal 0, topics.size
    
    topics = Topic.find_tagged_with(:any => 'a b c d e x y z')
    assert_equal 3, topics.size
    assert topics.include?(topic1)
    assert topics.include?(topic2)
    assert topics.include?(topic3)

    topics = Topic.find_tagged_with(:any => 'a z')
    assert_equal 2, topics.size
    assert topics.include?(topic1)   
    assert topics.include?(topic2)
    
    topics = Topic.find_tagged_with(:any => 'b')
    assert_equal 1, topics.size
    assert topics.include?(topic1)   
    
    topics = Topic.find_tagged_with(:any => 'c')
    assert_equal 3, topics.size
    assert topics.include?(topic1)   
    assert topics.include?(topic2)   
    assert topics.include?(topic3)   

    topics = Topic.find_tagged_with(:any => 'd')
    assert_equal 1, topics.size
    assert topics.include?(topic3)   

    topics = Topic.find_tagged_with(:any => 'e')
    assert_equal 2, topics.size
    assert topics.include?(topic2)   
    assert topics.include?(topic3)   
  end

  def test_find_tagged_with_all
    topic1 = Topic.create(:title => 'test1')
    topic2 = Topic.create(:title => 'test2')    
    topic3 = Topic.create(:title => 'test3')    
    
    topic1.tag('a b c'); topic1.save
    topic2.tag('a c e'); topic2.save
    topic3.tag('c d e'); topic3.save
    
    topics = Topic.find_tagged_with(:all => 'a b d')
    assert_equal 0, topics.size

    topics = Topic.find_tagged_with(:all => 'a c')
    assert_equal 2, topics.size
    assert topics.include?(topic1)   
    assert topics.include?(topic2)

    topics = Topic.find_tagged_with(:all => 'a+c', :separator => '+')
    assert_equal 2, topics.size
    assert topics.include?(topic1)   
    assert topics.include?(topic2)
    
    topics = Topic.find_tagged_with(:all => 'c e')
    assert_equal 2, topics.size
    assert topics.include?(topic2)   
    assert topics.include?(topic3)   
    
    topics = Topic.find_tagged_with(:all => 'c')
    assert_equal 3, topics.size
    assert topics.include?(topic1)   
    assert topics.include?(topic2)   
    assert topics.include?(topic3)   

    topics = Topic.find_tagged_with(:all => 'a b c')
    assert_equal 1, topics.size
    assert topics.include?(topic1)   

    topics = Topic.find_tagged_with(:all => 'a c e')
    assert_equal 1, topics.size
    assert topics.include?(topic2)   
  end
  
  private
  def test_tagging(tagged_object, tag_model, collection)
    tag_model.delete_all
    assert_equal 0, tag_model.count
    
    tagged_object.tag_names << 'rio brazil'    
    tagged_object.save    
    
    assert_equal 2, tag_model.count
    assert_equal 2, tagged_object.send(collection).size

    tagged_object.tag_names = 'beach surf'    
    assert_equal 4, tag_model.count
    assert_equal 2, tagged_object.send(collection).size
        
    tagged_object.tag_names.concat 'soccer+pele', :separator => '+'    
    assert_equal 6, tag_model.count
    assert_equal 4, tagged_object.send(collection).size
    
    tag_model.delete_all
    assert_equal 0, tag_model.count
    tagged_object.send(collection).reload
        
    tagged_object.tag_names = 'dhh'    
    assert_equal 1, tag_model.count
    assert_equal 1, tagged_object.send(collection).size
    
    tagged_object.tag 'dhh rails my', :clear => true
    
    assert_equal 3, tag_model.count
    assert_equal 3, tagged_object.send(collection).size
    
    tagged_object.tag 'dhh dhh ruby tags', :clear => true
    assert_equal 5, tag_model.count    
    assert_equal 3, tagged_object.send(collection).size
    
    tagged_object.tag 'tagging, hello, ruby', :separator => ','
    assert_equal 7, tag_model.count
    assert_equal 5, tagged_object.send(collection).size

    all_tags = %w( dhh rails my ruby tags tagging hello )
    first_tags = %w( dhh ruby tags tagging hello )
    
    tagged_object.send(collection).reload
    assert_equal first_tags, tagged_object.tag_names
    all_tags.each do |tag_name|
      tag_record = tag_model.find_by_name(tag_name)
      assert_not_nil tag_record
      
      if first_tags.include?(tag_name)
        assert tagged_object.send(collection).include?(tag_record) 
        assert tagged_object.tagged_with?(tag_name)
      end
    end
  end

  def create_test_topics 
    t1 = Topic.create(:title => 't1')
    t2 = Topic.create(:title => 't2')    
    t3 = Topic.create(:title => 't3')    
    t4 = Topic.create(:title => 't4')    
    t5 = Topic.create(:title => 't5')    
    t6 = Topic.create(:title => 't6')    
    
    t1.tag('rome, luxury, clean, mustsee, greatview', :separator => ','); t1.save
    t2.tag('rome, luxury, clean, italian, spicy, goodwine', :separator => ','); t2.save
    t3.tag('rome, walking, clean, mustsee', :separator => ','); t3.save
    t4.tag('rome, italy, clean, mustsee, greatview', :separator => ','); t4.save
    t5.tag('rome, luxury, clean, italian, spicy, wine', :separator => ','); t5.save
    t6.tag('rome, walking, clean, greatview', :separator => ','); t6.save
    
    [ t1, t2, t3, t4, t5, t6 ]     
  end
end
