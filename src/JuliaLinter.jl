module JuliaLinter

using JuliaWorkspaces
using JuliaWorkspaces.URIs2: uri2filepath

# Adapted from JuliaSyntax
function show_diagnostic(io::IO, diagnostic::Diagnostic, source::TextFile)
    color,prefix = diagnostic.severity === :error   ? (:light_red, "Error")      :
                   diagnostic.severity === :warning ? (:light_yellow, "Warning") :
                   diagnostic.severity === :note    ? (:light_blue, "Note")      :
                   (:normal, "Info")
    line, col = position_at(source.content, diagnostic.range.start)
    linecol = "$line:$col"
    filename = uri2filepath(source.uri)
    file_href = "$(source.uri)#$linecol"
    locstr = "$filename:$linecol"
    JuliaWorkspaces.JuliaSyntax._printstyled(io, "# $prefix @ ", fgcolor=:light_black)
    JuliaWorkspaces.JuliaSyntax._printstyled(io, "$locstr", fgcolor=:light_black, href=file_href)
    print(io, "\n")
    JuliaWorkspaces.JuliaSyntax.highlight(io, JuliaWorkspaces.JuliaSyntax.SourceFile(source.content.content), diagnostic.range,
              note=diagnostic.message, notecolor=color,
              context_lines_before=1, context_lines_after=0)
end

function cmdline(args)
    folder_to_lint = length(args) > 0 ? args[1] : pwd()

    jw = workspace_from_folders([folder_to_lint])

    files = get_text_files(jw)

    fail_lint_pass = false

    for file in files
        diagnostics = get_diagnostic(jw, file)

        for diag in diagnostics
            text_file = get_text_file(jw, file)

            println()
            println()
            println()

            show_diagnostic(stdout, diag, text_file)

            if diag.severity == :error
                fail_lint_pass = true
            end
        end
    end

    # if fail_lint_pass
    #     exit(1)
    # end
end

end # module JuliaLinter
