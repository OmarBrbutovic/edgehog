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

defmodule Edgehog.Selector.AST.AttributeFilterTest do
  use ExUnit.Case, async: true

  alias Edgehog.Selector.AST.AttributeFilter

  describe "struct" do
    test "creates an attribute filter struct" do
      filter = %AttributeFilter{
        namespace: "custom",
        key: "firmware_version",
        operator: :==,
        type: :string,
        value: "1.0.0"
      }

      assert filter.namespace == "custom"
      assert filter.key == "firmware_version"
      assert filter.operator == :==
      assert filter.type == :string
      assert filter.value == "1.0.0"
    end
  end

  describe "Edgehog.Selector.Filter implementation" do
    test "to_ash_expr raises TODO" do
      filter = %AttributeFilter{
        namespace: "custom",
        key: "test",
        operator: :==,
        type: :string,
        value: "val"
      }

      assert_raise RuntimeError, "TODO", fn ->
        Edgehog.Selector.Filter.to_ash_expr(filter)
      end
    end
  end
end
