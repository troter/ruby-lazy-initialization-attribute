require File.dirname(__FILE__) + '/spec_helper'

describe LazyInitializationAttribute, 'includeしたとき' do
  before do
    @included_class = Class.new { include LazyInitializationAttribute }
  end

  it "lazy_attr_readerが定義される" do
    @included_class.should respond_to(:lazy_attr_reader)
  end
  it "lazy_attr_accessorが定義される" do
    @included_class.should respond_to(:lazy_attr_accessor)
  end

  after do
    @included_class = nil
  end
end

describe LazyInitializationAttribute, '#lazy_attr_reader' do
  before do
    @included_class = Class.new { include LazyInitializationAttribute }
  end
  it "はフックやブロックとともに呼び出されないと例外を投げる" do
    lambda do
      @included_class.class_eval do
        lazy_attr_reader :no_hook_or_block
      end
    end.should raise_error
  end

  it "はリーダを定義する" do
    @included_class.class_eval do
      def initialize; end
      def hook_method; nil end
      lazy_attr_reader :with_hook, :hook_method
      lazy_attr_reader :with_block do nil end
    end
    obj = @included_class.new
    obj.respond_to?(:with_hook).should be_true
    obj.respond_to?(:with_block).should be_true
  end

  it "はリーダにアクセスした後インスタンス変数を定義する" do
    @included_class.class_eval do
      def initialize; end
      def hook_method; nil end
      lazy_attr_reader :with_hook, :hook_method
      lazy_attr_reader :with_block do nil end
    end
    obj = @included_class.new
    obj.instance_variable_defined?(:@with_hook).should be_false
    obj.with_hook.should eql(nil)
    obj.instance_variable_defined?(:@with_hook).should be_true
    obj.instance_variable_defined?(:@with_block).should be_false
    obj.with_block.should eql(nil)
    obj.instance_variable_defined?(:@with_block).should be_true
  end

  it "は一度だけ値を初期化する" do
    @included_class.class_eval do
      def initialize; @inner = 0 end
      def inner_add; @inner += 1 end
      def inner_current; @inner end
      lazy_attr_reader :inner_snapshot_hook, :inner_current
      lazy_attr_reader :inner_snapshot_block do @inner end
    end
    obj_a = @included_class.new
    obj_a.inner_add
    obj_a.inner_add
    obj_a.inner_snapshot_hook.should eql(2)
    obj_a.inner_add
    obj_a.inner_snapshot_block.should eql(3)
    obj_a.inner_add
    obj_a.inner_snapshot_hook.should eql(2)
    obj_a.inner_snapshot_block.should eql(3)
    obj_a.inner_current.should eql(4)

    obj_b = @included_class.new
    obj_b.inner_add
    obj_b.inner_add
    obj_b.inner_add
    obj_b.inner_add
    obj_b.inner_snapshot_hook.should eql(4)
    obj_b.inner_add
    obj_b.inner_snapshot_block.should eql(5)
    obj_b.inner_add
    obj_b.inner_snapshot_hook.should eql(4)
    obj_b.inner_snapshot_block.should eql(5)
    obj_b.inner_current.should eql(6)
  end

  after do
    @included_class = nil
  end
end

describe LazyInitializationAttribute, '#lazy_attr_accessor' do
  before do
    @included_class = Class.new { include LazyInitializationAttribute }
  end

  it "はフックやブロックとともに呼び出されないと例外を投げる" do
    lambda do
      @included_class.class_eval do
        lazy_attr_accessor :no_hook_or_block
      end
    end.should raise_error
  end

  it "はアクセサを定義する" do
    @included_class.class_eval do
      def initialize; end
      def hook_method; nil end
      lazy_attr_accessor :with_hook, :hook_method
      lazy_attr_accessor :with_block do nil end
    end
    obj = @included_class.new
    obj.respond_to?(:with_hook).should be_true
    obj.respond_to?(:with_hook=).should be_true
    obj.respond_to?(:with_block).should be_true
    obj.respond_to?(:with_block=).should be_true
  end

  it "は一度だけ値を初期化する" do
    @included_class.class_eval do
      def initialize; @inner = 0 end
      def inner_add; @inner += 1 end
      def inner_current; @inner end
      lazy_attr_accessor :inner_snapshot_hook, :inner_current
      lazy_attr_accessor :inner_snapshot_block do @inner end
    end
    obj_a = @included_class.new
    obj_a.inner_add
    obj_a.inner_add
    obj_a.inner_snapshot_hook.should eql(2)
    obj_a.inner_add
    obj_a.inner_snapshot_block.should eql(3)
    obj_a.inner_add
    obj_a.inner_snapshot_hook.should eql(2)
    obj_a.inner_snapshot_block.should eql(3)
    obj_a.inner_current.should eql(4)

    obj_a.inner_snapshot_hook = 10
    obj_a.inner_snapshot_block = 11
    obj_a.inner_add
    obj_a.inner_snapshot_hook.should eql(10)
    obj_a.inner_snapshot_block.should eql(11)
    obj_a.inner_current.should eql(5)

    obj_b = @included_class.new
    obj_b.inner_add
    obj_b.inner_add
    obj_b.inner_add
    obj_b.inner_add
    obj_b.inner_snapshot_hook.should eql(4)
    obj_b.inner_add
    obj_b.inner_snapshot_block.should eql(5)
    obj_b.inner_add
    obj_b.inner_snapshot_hook.should eql(4)
    obj_b.inner_snapshot_block.should eql(5)
    obj_b.inner_current.should eql(6)

    obj_b.inner_snapshot_hook = 10
    obj_b.inner_snapshot_block = 11
    obj_b.inner_add
    obj_b.inner_snapshot_hook.should eql(10)
    obj_b.inner_snapshot_block.should eql(11)
    obj_b.inner_current.should eql(7)
  end

  after do
    @included_class = nil
  end
end
