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

defmodule Edgehog.Selector.ParserNegativeFloatTest do
  use ExUnit.Case, async: true

  alias Edgehog.Selector.Parser

  describe "parse/1 with negative float values" do
    test "parses selector with negative float value" do
      assert {:ok, _, "", _, _, _} =
               Parser.parse(~s(attributes["custom:key"] > -3.14))
    end

    test "parses selector with negative float in comparison" do
      assert {:ok, _, "", _, _, _} =
               Parser.parse(~s(attributes["custom:temp"] <= -0.5))
    end
  end
end
