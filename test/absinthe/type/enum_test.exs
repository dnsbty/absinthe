defmodule Absinthe.Type.EnumTest do
  use Absinthe.Case, async: true

  alias Absinthe.Type
  alias Absinthe.Fixtures.Enums

  defmodule TestSchema do
    use Absinthe.Schema

    query do
      field :channel, :color_channel, description: "The active color channel" do
        resolve fn _, _ ->
          {:ok, :red}
        end
      end
    end

    enum :color_channel do
      description "The selected color channel"
      value :red, as: :r, description: "Color Red"
      value :green, as: :g, description: "Color Green"
      value :blue, as: :b, description: "Color Blue"

      value :alpha,
        as: :a,
        deprecate: "We no longer support opacity settings",
        description: "Alpha Channel"
    end

    enum :color_channel2 do
      description "The selected color channel"

      value :red, description: "Color Red"
      value :green, description: "Color Green"
      value :blue, description: "Color Blue"

      value :alpha,
        as: :a,
        deprecate: "We no longer support opacity settings",
        description: "Alpha Channel"
    end

    enum :color_channel3,
      values: [:red, :green, :blue, :alpha],
      description: "The selected color channel"

    enum :negative_value do
      value :positive_one, as: 1
      value :zero, as: 0
      value :negative_one, as: -1
    end
  end

  describe "enums" do
    test "can be defined by a map with defined values" do
      type = TestSchema.__absinthe_type__(:color_channel)
      assert %Type.Enum{} = type

      assert %Type.Enum.Value{name: "RED", value: :r, description: "Color Red"} =
               type.values[:red]
    end

    test "can be defined by a map without defined values" do
      type = TestSchema.__absinthe_type__(:color_channel2)
      assert %Type.Enum{} = type
      assert %Type.Enum.Value{name: "RED", value: :red} = type.values[:red]
    end

    test "can be defined by a shorthand list of atoms" do
      type = TestSchema.__absinthe_type__(:color_channel3)
      assert %Type.Enum{} = type
      assert %Type.Enum.Value{name: "RED", value: :red, description: nil} = type.values[:red]
    end
  end

  describe "enum value description evaluation" do
    Absinthe.Fixtures.FunctionEvaluationHelpers.function_evaluation_test_params()
    |> Enum.each(fn %{
                      test_label: test_label,
                      expected_value: expected_value
                    } ->
      test "for #{test_label} (evaluates description to '#{expected_value}')" do
        type =
          Enums.TestSchemaValueDescriptionKeyword.__absinthe_type__(:description_keyword_argument)

        assert type.values[unquote(test_label)].description == unquote(expected_value)
      end
    end)
  end

  describe "enum description keyword evaluation" do
    Absinthe.Fixtures.FunctionEvaluationHelpers.function_evaluation_test_params()
    |> Enum.each(fn %{
                      test_label: test_label,
                      expected_value: expected_value
                    } ->
      test "for #{test_label} (evaluates description to '#{expected_value}')" do
        type = Enums.TestSchemaDescriptionKeyword.__absinthe_type__(unquote(test_label))
        assert type.description == unquote(expected_value)
      end
    end)
  end

  describe "enum description attribute evaluation" do
    Absinthe.Fixtures.FunctionEvaluationHelpers.function_evaluation_test_params()
    |> Absinthe.Fixtures.FunctionEvaluationHelpers.filter_test_params_for_description_attribute()
    |> Enum.each(fn %{
                      test_label: test_label,
                      expected_value: expected_value
                    } ->
      test "for #{test_label} (evaluates description to '#{expected_value}')" do
        type = Enums.TestSchemaDescriptionAttribute.__absinthe_type__(unquote(test_label))
        assert type.description == unquote(expected_value)
      end
    end)
  end

  describe "enum description macro evaluation" do
    Absinthe.Fixtures.FunctionEvaluationHelpers.function_evaluation_test_params()
    |> Enum.each(fn %{
                      test_label: test_label,
                      expected_value: expected_value
                    } ->
      test "for #{test_label} (evaluates description to '#{expected_value}')" do
        type = Enums.TestSchemaDescriptionMacro.__absinthe_type__(unquote(test_label))
        assert type.description == unquote(expected_value)
      end
    end)
  end
end
