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

defmodule Edgehog.Devices.Reconciler.CoreFunctionsTest do
  use ExUnit.Case, async: true

  alias Edgehog.Devices.Reconciler.Core

  @doc """
  Tests for Edgehog.Devices.Reconciler.Core pure helper functions.
  """
  describe "module exports" do
    test "reconcile/1 is exported" do
      Code.ensure_loaded!(Core)
      assert function_exported?(Core, :reconcile, 1)
    end

    test "reconcile_device/2 is exported" do
      Code.ensure_loaded!(Core)
      assert function_exported?(Core, :reconcile_device, 2)
    end
  end
end
