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

defmodule Edgehog.Astarte.Device.DeviceStatusTest do
  use ExUnit.Case, async: true

  alias Edgehog.Astarte.Device.DeviceStatus

  describe "DeviceStatus struct" do
    test "has correct fields" do
      status = %DeviceStatus{}
      assert Map.has_key?(status, :attributes)
      assert Map.has_key?(status, :groups)
      assert Map.has_key?(status, :introspection)
      assert Map.has_key?(status, :online)
      assert Map.has_key?(status, :last_connection)
      assert Map.has_key?(status, :last_disconnection)
      assert Map.has_key?(status, :last_seen_ip)
      assert Map.has_key?(status, :previous_interfaces)
    end

    test "can be created with all fields" do
      status = %DeviceStatus{
        attributes: %{"key" => "val"},
        groups: ["g1"],
        introspection: %{},
        last_connection: ~U[2024-01-01 00:00:00Z],
        last_disconnection: ~U[2024-01-02 00:00:00Z],
        last_seen_ip: "1.2.3.4",
        online: true,
        previous_interfaces: []
      }

      assert status.online == true
      assert status.last_seen_ip == "1.2.3.4"
    end
  end
end
