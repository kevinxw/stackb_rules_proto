"gencopy.bzl provides an action for copying generated files into the workspace."

load("@bazel_skylib//lib:shell.bzl", "shell")

gencopy_attrs = {
    "mode": attr.string(
        doc = "The gencopy mode.  For update, overwrite existing files.  For check, assert file equality",
        values = ["update", "check"],
        default = "check",
    ),
    "file_mode": attr.string(
        doc = "The target unix file mode.",
        default = "0644",
    ),
    "package": attr.string(
        doc = "The target package for the rule. If empty, default to ctx.label.package",
    ),
    "update_target_label_name": attr.string(
        doc = "The label.name used to regenerate targets",
        mandatory = True,
    ),
    "_gencopy_script": attr.label(
        doc = "The gencopy script template",
        default = str(Label("//cmd/gencopy:gencopy.bash.in")),
        allow_single_file = True,
    ),
    "_gencopy": attr.label(
        doc = "The gencopy binary",
        default = str(Label("//cmd/gencopy")),
        allow_single_file = True,
        cfg = "host",
        executable = True,
    ),
}

def gencopy_config(ctx):
    return struct(
        mode = ctx.attr.mode,
        fileMode = ctx.attr.file_mode,
        updateTargetLabelName = ctx.attr.update_target_label_name,
        packageConfigs = [],
    )

def gencopy_action(ctx, config, runfiles):
    script = ctx.actions.declare_file(ctx.label.name + ".bash")
    config_json = ctx.actions.declare_file("%s.%s.json" % (ctx.label.name, config.mode))

    substitutions = {
        "@@GENCOPY_LABEL@@": shell.quote(str(ctx.attr._gencopy.label)),
        "@@GENCOPY_SHORT_PATH@@": shell.quote(ctx.executable._gencopy.short_path),
        "@@CONFIG_SHORT_PATH@@": shell.quote(config_json.short_path),
        "@@GENERATED_MESSAGE@@": """
# Generated by {label}
# DO NOT EDIT
""".format(label = str(ctx.label)),
        "@@RUNNER_LABEL@@": shell.quote(str(ctx.label)),
    }

    ctx.actions.write(
        output = config_json,
        content = config.to_json(),
    )

    ctx.actions.expand_template(
        template = ctx.file._gencopy_script,
        output = script,
        substitutions = substitutions,
        is_executable = True,
    )

    return config_json, script, ctx.runfiles(files = [ctx.executable._gencopy, config_json] + runfiles)
