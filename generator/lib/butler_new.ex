defmodule Mix.Tasks.Butler.New do
  use Mix.Task
  import Mix.Generator

  @version Mix.Project.config[:version]
  @shortdoc "Create a new Butler application"

  @new_files ~w(
    README.md
    mix.exs
    .gitignore
    plugins/example.ex
    config/config.exs
    config/dev.exs
    config/prod.exs
  )

  root = Path.expand("../templates", __DIR__)

  for file <- @new_files do
    @external_resource Path.join(root, file)
    def contents(unquote(file)), do: unquote(File.read!(Path.join(root, "new/#{file}")))
  end

  @moduledoc """
  Creates a new Butler application.

      mix butler.new PATH

  A robot will be created at the given PATH.
  """
  def run([version]) when version in ~w(-v --version) do
    Mix.shell.info "Butler v#{@version}"
  end

  def run(argv) do
    case argv do
      [] ->
        Mix.raise "Expected PATH to be given, `mix butler.new PATH`"
      [path|_] ->
        app_name = path |> Path.expand |> Path.basename
        mod_name = app_name |> Mix.Utils.camelize
        run(path, app_name, mod_name)
    end
  end

  def run(path, app_name, mod_name) do
    bindings = [mod_name: mod_name, app_name: app_name, version: @version]
    create_directory(path)
    create_files(path, bindings)
    print_info(path)
  end

  defp create_files(path, bindings) do
    for file <- @new_files do
      contents = rendered_template(file, bindings)
      new_file = Path.join(path, file)
      create_file(new_file, contents)
    end
  end

  defp rendered_template(file, bindings) do
    EEx.eval_string contents(file), bindings, file: file
  end

  defp print_info(path) do
    Mix.shell.info """

    Your Butler has been installed. Run it with:

        $ cd #{path}
        $ mix deps.get
        $ mix run --no-halt

    Enjoy your new Robot!
    """
  end
end
