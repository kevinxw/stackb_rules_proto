---
layout: default
title: java
permalink: examples/java
parent: Examples
---


# java example

`bazel test //example/golden:java_test`


## `BUILD.bazel` (after gazelle)

~~~python
load("@rules_proto//proto:defs.bzl", "proto_library")
load("@build_stack_rules_proto//rules:proto_compile.bzl", "proto_compile")
load("@rules_proto//proto:defs.bzl", "proto_library")

# "proto_rule" instantiates the proto_compile rule
# gazelle:proto_rule proto_compile implementation stackb:rules_proto:proto_compile

# "proto_plugin" instantiates the builtin java plugin
# gazelle:proto_plugin java implementation builtin:java

# "proto_language" binds the rule(s) and plugin(s) together
# gazelle:proto_language java rule proto_compile
# gazelle:proto_language java plugin java

proto_library(
    name = "example_proto",
    srcs = ["example.proto"],
    visibility = ["//visibility:public"],
)

proto_compile(
    name = "example_java_compile",
    outs = {"@build_stack_rules_proto//plugin/builtin:java": "example.srcjar"},
    outputs = ["example.srcjar"],
    plugins = ["@build_stack_rules_proto//plugin/builtin:java"],
    proto = "example_proto",
)
~~~


## `BUILD.bazel` (before gazelle)

~~~python
# "proto_rule" instantiates the proto_compile rule
# gazelle:proto_rule proto_compile implementation stackb:rules_proto:proto_compile

# "proto_plugin" instantiates the builtin java plugin
# gazelle:proto_plugin java implementation builtin:java

# "proto_language" binds the rule(s) and plugin(s) together
# gazelle:proto_language java rule proto_compile
# gazelle:proto_language java plugin java
~~~


## `WORKSPACE`

~~~python
~~~

