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

defmodule Edgehog.Changes.NormalizeTagNameTest do
  use ExUnit.Case, async: true

  alias Edgehog.Changes.NormalizeTagName

  describe "init/1" do
    test "returns ok with attribute option" do
      assert {:ok, [attribute: :name]} == NormalizeTagName.init(attribute: :name)
    end

    test "returns ok with argument option" do
      assert {:ok, [argument: :tag]} == NormalizeTagName.init(argument: :tag)
    end

    test "returns error when both attribute and argument are given" do
      assert {:error, _msg} = NormalizeTagName.init(attribute: :name, argument: :tag)
    end

    test "returns error when neither attribute nor argument is given" do
      assert {:error, _msg} = NormalizeTagName.init([])
    end
  end
end
