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

defmodule Edgehog.Devices.Reconciler.ReconcilerTest do
  use ExUnit.Case, async: true

  alias Edgehog.Devices.Reconciler

  @doc """
  Tests for the Devices Reconciler GenServer module.
  """
  describe "module exports" do
    test "start_link/1 is exported" do
      assert function_exported?(Reconciler, :start_link, 1)
    end

    test "init/1 callback is exported" do
      assert function_exported?(Reconciler, :init, 1)
    end
  end
end
