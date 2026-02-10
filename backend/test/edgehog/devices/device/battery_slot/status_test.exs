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

defmodule Edgehog.Devices.Device.BatterySlot.StatusTest do
  use ExUnit.Case, async: true

  alias Edgehog.Devices.Device.BatterySlot.Status

  describe "match/1" do
    test "matches PascalCase Astarte strings" do
      assert {:ok, :charging} = Status.match("Charging")
      assert {:ok, :discharging} = Status.match("Discharging")
      assert {:ok, :idle} = Status.match("Idle")
      assert {:ok, :either_idle_or_charging} = Status.match("EitherIdleOrCharging")
      assert {:ok, :failure} = Status.match("Failure")
      assert {:ok, :removed} = Status.match("Removed")
      assert {:ok, :unknown} = Status.match("Unknown")
    end

    test "matches atom values" do
      assert {:ok, :charging} = Status.match(:charging)
      assert {:ok, :idle} = Status.match(:idle)
    end

    test "returns error for unknown values" do
      assert :error = Status.match("bogus")
    end
  end
end
