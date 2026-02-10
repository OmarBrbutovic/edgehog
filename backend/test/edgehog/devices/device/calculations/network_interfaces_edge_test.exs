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

defmodule Edgehog.Devices.Device.Calculations.NetworkInterfacesEdgeTest do
  use ExUnit.Case, async: true

  import Mox

  alias Edgehog.Devices.Device.Calculations.NetworkInterfaces

  setup :verify_on_exit!

  describe "calculate/3" do
    test "returns nil when appengine_client is nil" do
      devices = [
        %{device_id: "device-1", appengine_client: nil}
      ]

      assert [nil] = NetworkInterfaces.calculate(devices, [], %{})
    end

    test "returns nil when network interface get returns error" do
      {:ok, client} =
        Astarte.Client.AppEngine.new("https://astarte.example.com", "test-realm", jwt: "test-token")

      expect(Edgehog.Astarte.Device.NetworkInterfaceMock, :get, fn _client, _device_id ->
        {:error, :some_error}
      end)

      devices = [
        %{device_id: "device-1", appengine_client: client}
      ]

      assert [nil] = NetworkInterfaces.calculate(devices, [], %{})
    end
  end
end
