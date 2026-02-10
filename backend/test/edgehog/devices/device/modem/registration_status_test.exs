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

defmodule Edgehog.Devices.Device.Modem.RegistrationStatusTest do
  use ExUnit.Case, async: true

  alias Edgehog.Devices.Device.Modem.RegistrationStatus

  describe "match/1" do
    test "matches PascalCase Astarte strings" do
      assert {:ok, :not_registered} = RegistrationStatus.match("NotRegistered")
      assert {:ok, :registered} = RegistrationStatus.match("Registered")
      assert {:ok, :searching_operator} = RegistrationStatus.match("SearchingOperator")
      assert {:ok, :registration_denied} = RegistrationStatus.match("RegistrationDenied")
      assert {:ok, :unknown} = RegistrationStatus.match("Unknown")
      assert {:ok, :registered_roaming} = RegistrationStatus.match("RegisteredRoaming")
    end

    test "matches atom values" do
      assert {:ok, :registered} = RegistrationStatus.match(:registered)
      assert {:ok, :not_registered} = RegistrationStatus.match(:not_registered)
    end

    test "matches lowercase string values" do
      assert {:ok, :registered} = RegistrationStatus.match("registered")
    end

    test "returns error for unknown values" do
      assert :error = RegistrationStatus.match("bogus")
    end
  end
end
