# This file is part of Edgehog.
#
# Copyright 2026 SECO Mind Srl
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

defmodule Edgehog.Localization.LocalizedTest do
  use ExUnit.Case, async: true

  alias Edgehog.Localization.Calculations.LocalizedAttributes
  alias Edgehog.Localization.Changes.UpsertLocalizedAttribute
  alias Edgehog.Localization.LocalizedAttribute
  alias Edgehog.Localization.LocalizedAttributeUpdateInput

  describe "LocalizedAttributes.init/1" do
    test "returns ok with valid attribute option" do
      assert {:ok, [attribute: :description]} == LocalizedAttributes.init(attribute: :description)
    end

    test "returns error without attribute option" do
      assert {:error, _} = LocalizedAttributes.init([])
    end

    test "returns error with non-atom attribute" do
      assert {:error, _} = LocalizedAttributes.init(attribute: "not_atom")
    end
  end

  describe "LocalizedAttributes.load/3" do
    test "returns the attribute wrapped in a list" do
      assert [:description] == LocalizedAttributes.load(nil, [attribute: :description], %{})
    end
  end

  describe "LocalizedAttributes.calculate/3" do
    test "returns localized attributes as list of maps" do
      records = [%{description: %{"en" => "Hello", "de" => "Hallo", "fr" => "Bonjour"}}]
      opts = [attribute: :description]
      context = %{arguments: %{}}

      [result] = LocalizedAttributes.calculate(records, opts, context)

      assert is_list(result)
      assert length(result) == 3

      tags = result |> Enum.map(& &1.language_tag) |> Enum.sort()
      assert tags == ["de", "en", "fr"]
    end

    test "filters by preferred_language_tags" do
      records = [%{description: %{"en" => "Hello", "de" => "Hallo", "fr" => "Bonjour"}}]
      opts = [attribute: :description]
      context = %{arguments: %{preferred_language_tags: ["en", "de"]}}

      [result] = LocalizedAttributes.calculate(records, opts, context)

      assert length(result) == 2
      tags = result |> Enum.map(& &1.language_tag) |> Enum.sort()
      assert tags == ["de", "en"]
    end

    test "returns empty when attribute is nil" do
      records = [%{description: nil}]
      opts = [attribute: :description]
      context = %{arguments: %{}}

      [result] = LocalizedAttributes.calculate(records, opts, context)
      assert result == []
    end

    test "returns empty when attribute is empty map" do
      records = [%{description: %{}}]
      opts = [attribute: :description]
      context = %{arguments: %{}}

      [result] = LocalizedAttributes.calculate(records, opts, context)
      assert result == []
    end

    test "handles multiple records" do
      records = [
        %{name: %{"en" => "Item 1"}},
        %{name: %{"en" => "Item 2", "de" => "Artikel 2"}}
      ]

      opts = [attribute: :name]
      context = %{arguments: %{}}

      [r1, r2] = LocalizedAttributes.calculate(records, opts, context)
      assert length(r1) == 1
      assert length(r2) == 2
    end
  end

  describe "UpsertLocalizedAttribute.init/1" do
    test "returns ok with valid options" do
      assert {:ok, [target_attribute: :description, input_argument: :description_input]} ==
               UpsertLocalizedAttribute.init(
                 target_attribute: :description,
                 input_argument: :description_input
               )
    end

    test "returns error without target_attribute" do
      assert {:error, _} = UpsertLocalizedAttribute.init(input_argument: :desc)
    end

    test "returns error without input_argument" do
      assert {:error, _} = UpsertLocalizedAttribute.init(target_attribute: :desc)
    end

    test "returns error with non-atom target_attribute" do
      assert {:error, _} =
               UpsertLocalizedAttribute.init(
                 target_attribute: "string",
                 input_argument: :desc
               )
    end

    test "returns error with non-atom input_argument" do
      assert {:error, _} =
               UpsertLocalizedAttribute.init(
                 target_attribute: :desc,
                 input_argument: "string"
               )
    end
  end

  describe "LocalizedAttribute graphql types" do
    test "graphql_type returns :localized_attribute" do
      assert :localized_attribute == LocalizedAttribute.graphql_type(nil)
    end

    test "graphql_input_type returns :localized_attribute_input" do
      assert :localized_attribute_input == LocalizedAttribute.graphql_input_type(nil)
    end
  end

  describe "LocalizedAttributeUpdateInput graphql types" do
    test "graphql_input_type returns :localized_attribute_update_input" do
      assert :localized_attribute_update_input ==
               LocalizedAttributeUpdateInput.graphql_input_type(nil)
    end
  end
end
