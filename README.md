# fluent-plugin-metric-splitter  [![Build Status](https://travis-ci.org/pikselpalette/fluent-plugin-metric-splitter.png)](https://travis-ci.org/pikselpalette/fluent-plugin-metric-splitter)
Fluent plugin to split large hashes into multiple small messages for pushing to a metrics backend

## Install

```bash
gem install fluent-plugin-metric-splitter
```

## Description

The purpose of this filter is to split large hashes produced by check scripts into
a series of hashes of the form:

```
{ 
    "time" => 1505999101,
    "path" => "foo.bar.baz.failures",
    "data" => 1
}
```

## Usage

```
<filter **>
  type metric_splitter
</filter>
```
