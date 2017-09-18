require 'helper'

class MetricSplitterOutputTest < Test::Unit::TestCase
  CONFIG_NAME_KEY_PATTERN = %[
    name_key_pattern .*
  ]
  CONFIG_NAME_KEYS = %[
    tag_for prefix
    name_keys dstat.total cpu usage.usr,dstat.total cpu usage.sys,dstat.total cpu usage.idl
  ]
  CONFIG_TAG_FOR_IGNORE = %[
    name_keys dstat.total cpu usage.usr,dstat.total cpu usage.sys,dstat.total cpu usage.idl
    tag_for ignore
  ]
  CONFIG_TAG_FOR_SUFFIX = %[
    name_keys dstat.total cpu usage.usr,dstat.total cpu usage.sys,dstat.total cpu usage.idl
    tag_for suffix
  ]
  CONFIG_INVALID_TAG_FOR = %[
    name_key_pattern ^((?!hostname).)*$
    tag_for invalid
  ]
  CONFIG_SPECIFY_BOTH_NAME_KEYS_AND_NAME_KEY_PATTERN = %[
    name_keys dstat.total cpu usage.usr,dstat.total cpu usage.sys,dstat.total cpu usage.idl
    name_key_pattern ^((?!hostname).)*$
  ]

  def setup
  end

  def teardown
  end

  def create_driver(conf = CONFIG_NAME_KEY_PATTERN, tag='test')
    Fluent::Test::OutputTestDriver.new(Fluent::MetricSplitter, tag).configure(conf)
  end

  def test_configure
    d = create_driver
    assert_equal d.instance.tag_for, 'prefix'
    assert_equal d.instance.name_keys, nil
    assert_equal d.instance.name_key_pattern, /.*/

    d = create_driver(CONFIG_NAME_KEYS)
    assert_equal d.instance.tag_for, 'prefix'
    assert_equal d.instance.name_keys, ['dstat.total cpu usage.usr', 'dstat.total cpu usage.sys', 'dstat.total cpu usage.idl']
    assert_equal d.instance.name_key_pattern, nil

    d = create_driver(CONFIG_TAG_FOR_IGNORE)
    assert_equal d.instance.tag_for, 'ignore'
    assert_equal d.instance.name_keys, ['dstat.total cpu usage.usr', 'dstat.total cpu usage.sys', 'dstat.total cpu usage.idl']
    assert_equal d.instance.name_key_pattern, nil

    d = create_driver(CONFIG_TAG_FOR_SUFFIX)
    assert_equal d.instance.tag_for, 'suffix'
    assert_equal d.instance.name_keys, ['dstat.total cpu usage.usr', 'dstat.total cpu usage.sys', 'dstat.total cpu usage.idl']
    assert_equal d.instance.name_key_pattern, nil

    assert_raise(Fluent::ConfigError) { d = create_driver(CONFIG_INVALID_TAG_FOR) }
    assert_raise(Fluent::ConfigError) { d = create_driver(CONFIG_SPECIFY_BOTH_NAME_KEYS_AND_NAME_KEY_PATTERN) }
  end

  def test_format_metrics
    record = {
      'hostname' => 'localhost.localdomain',
      'dstat.total cpu usage.usr' => '0.0',
      'dstat.total cpu usage.sys' => '0.0',
      'dstat.total cpu usage.idl' => '100.0',
      'dstat.total cpu usage.wai' => '0.0',
      'dstat.total cpu usage.hiq' => '0.0',
      'dstat.total cpu usage.siq' => '0.0'
    }

    d = create_driver
    m1 = d.instance.format_metrics('test.', record)
    assert_equal m1, { 'test.dstat.total_cpu_usage.usr' => 0.0, 'test.dstat.total_cpu_usage.sys' => 0.0, 'test.dstat.total_cpu_usage.idl' => 100.0, 'test.dstat.total_cpu_usage.wai' => 0.0, 'test.dstat.total_cpu_usage.hiq' => 0.0, 'test.dstat.total_cpu_usage.siq' => 0.0 }

    d = create_driver(CONFIG_NAME_KEYS)
    m1 = d.instance.format_metrics('test.', record)
    assert_equal m1, { 'test.dstat.total_cpu_usage.usr' => 0.0, 'test.dstat.total_cpu_usage.sys' => 0.0, 'test.dstat.total_cpu_usage.idl' => 100.0 }

    d = create_driver(CONFIG_TAG_FOR_IGNORE)
    m1 = d.instance.format_metrics('test.', record)
    assert_equal m1, { 'dstat.total_cpu_usage.usr' => 0.0, 'dstat.total_cpu_usage.sys' => 0.0, 'dstat.total_cpu_usage.idl' => 100.0 }

    d = create_driver(CONFIG_TAG_FOR_SUFFIX)
    m1 = d.instance.format_metrics('test.', record)
    assert_equal m1, { 'dstat.total_cpu_usage.usr.test' => 0.0, 'dstat.total_cpu_usage.sys.test' => 0.0, 'dstat.total_cpu_usage.idl.test' => 100.0 }
  end
end
