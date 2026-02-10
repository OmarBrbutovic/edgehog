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

defmodule Edgehog.Containers.CalculationsEdgeTest do
  use ExUnit.Case, async: true

  alias Edgehog.Containers.Calculations.Dangling
  alias Edgehog.Containers.Calculations.OptionsEncoding
  alias Edgehog.Containers.Container.EnvEncoding
  alias Edgehog.Devices.Device.Calculations.Capabilities

  describe "Dangling" do
    test "init returns error when :parent key is missing" do
      assert {:error, :missing_parent_key} = Dangling.init([])
    end

    test "dangling? returns true for empty list" do
      assert true == Dangling.dangling?(%{releases: []}, :releases)
    end

    test "dangling? returns true for nil" do
      assert true == Dangling.dangling?(%{releases: nil}, :releases)
    end

    test "dangling? returns false for non-empty list" do
      assert false == Dangling.dangling?(%{releases: [:something]}, :releases)
    end
  end

  describe "EnvEncoding" do
    test "encodes env key-value pairs" do
      records = [%{env: [%{key: "MY_VAR", value: "123"}, %{key: "FOO", value: "bar"}]}]
      assert [["MY_VAR=123", "FOO=bar"]] = EnvEncoding.calculate(records, [], %{})
    end
  end

  describe "OptionsEncoding" do
    test "encodes options map to key=value strings" do
      records = [%{options: %{"key1" => "val1", "key2" => "val2"}}]
      [result] = OptionsEncoding.calculate(records, [], %{})
      assert "key1=val1" in result
      assert "key2=val2" in result
    end
  end

  describe "Capabilities" do
    test "returns empty list when device_status is nil" do
      devices = [%{device_status: nil}]
      assert [[]] = Capabilities.calculate(devices, [], %{})
    end

    test "returns empty list when device_status has no introspection map" do
      devices = [%{device_status: %{introspection: nil}}]
      assert [[]] = Capabilities.calculate(devices, [], %{})
    end
  end
end
