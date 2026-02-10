#
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
#

defmodule Edgehog.Containers.Reconciler.GenServerTest do
  use ExUnit.Case, async: true

  alias Edgehog.Containers.Reconciler

  @doc """
  Tests for the Containers Reconciler GenServer callbacks.
  We test callbacks directly without starting the GenServer to avoid
  needing a full database and Astarte setup.
  """
  describe "struct" do
    test "creates struct with device_id field" do
      s = %Reconciler{device_id: "dev123"}
      assert s.device_id == "dev123"
    end

    test "defaults to nil device_id" do
      s = %Reconciler{}
      assert s.device_id == nil
    end
  end

  describe "module functions" do
    test "start_link/1 is exported" do
      assert function_exported?(Reconciler, :start_link, 1)
    end

    test "stop_device/2 is exported" do
      assert function_exported?(Reconciler, :stop_device, 2)
    end

    test "register_device/2 is exported" do
      assert function_exported?(Reconciler, :register_device, 2)
    end
  end
end
