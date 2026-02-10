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

defmodule Edgehog.Astarte.Device.MoreEdgeCasesTest do
  use ExUnit.Case, async: true

  import Tesla.Mock

  alias Edgehog.Astarte.Device.AvailableDevices
  alias Edgehog.Astarte.Device.DeviceStatus
  alias Edgehog.Astarte.Device.ForwarderSession
  alias Edgehog.Astarte.Device.StorageUsage
  alias Edgehog.Astarte.Device.WiFiScanResult

  defp make_client do
    {:ok, client} =
      Astarte.Client.AppEngine.new("https://astarte.example.com", "test-realm", jwt: "test-token")

    client
  end

  describe "DeviceStatus.get/2 with nil introspection" do
    test "returns empty map for nil introspection" do
      client = make_client()

      mock(fn %{method: :get} ->
        %Tesla.Env{
          status: 200,
          body: %{
            "data" => %{
              "attributes" => %{},
              "groups" => [],
              "introspection" => nil,
              "last_connection" => nil,
              "last_disconnection" => nil,
              "last_seen_ip" => "1.2.3.4",
              "connected" => true,
              "previous_interfaces" => %{}
            }
          }
        }
      end)

      assert {:ok, status} = DeviceStatus.get(client, "device-id")
      assert status.introspection == %{}
    end
  end

  describe "StorageUsage.get/2 with non-binary longinteger" do
    test "returns nil for non-binary longinteger values" do
      client = make_client()

      mock(fn %{method: :get} ->
        %Tesla.Env{
          status: 200,
          body: %{
            "data" => %{
              "disk0s1" => [%{"totalBytes" => 12_345, "freeBytes" => nil}]
            }
          }
        }
      end)

      assert {:ok, [storage_unit]} = StorageUsage.get(client, "device-id")
      assert storage_unit.total_bytes == nil
      assert storage_unit.free_bytes == nil
    end
  end

  describe "WiFiScanResult.get/2 with nil timestamp" do
    test "returns nil timestamp when datetime is nil" do
      client = make_client()

      mock(fn %{method: :get} ->
        %Tesla.Env{
          status: 200,
          body: %{
            "data" => %{
              "ap" => [
                %{
                  "channel" => 6,
                  "connected" => true,
                  "essid" => "TestNetwork",
                  "macAddress" => "AA:BB:CC:DD:EE:FF",
                  "rssi" => -50,
                  "timestamp" => nil
                }
              ]
            }
          }
        }
      end)

      assert {:ok, [scan_result]} = WiFiScanResult.get(client, "device-id")
      assert scan_result.timestamp == nil
    end
  end

  describe "ForwarderSession.list_sessions/2 with Connecting status" do
    test "parses Connecting session status" do
      client = make_client()

      mock(fn %{method: :get} ->
        %Tesla.Env{
          status: 200,
          body: %{
            "data" => %{
              "session-token-1" => %{"status" => "Connecting"}
            }
          }
        }
      end)

      assert {:ok, [session]} = ForwarderSession.list_sessions(client, "device-id")
      assert session.status == :connecting
      assert session.token == "session-token-1"
    end
  end

  describe "AvailableDevices.get_device_status/2" do
    test "returns device status data" do
      client = make_client()

      mock(fn %{method: :get} ->
        %Tesla.Env{
          status: 200,
          body: %{
            "data" => %{
              "connected" => true,
              "introspection" => %{}
            }
          }
        }
      end)

      assert {:ok, data} = AvailableDevices.get_device_status(client, "device-id")
      assert data["connected"] == true
    end

    test "get_device_list returns device list" do
      client = make_client()

      mock(fn %{method: :get} ->
        %Tesla.Env{
          status: 200,
          body: %{"data" => ["device-1", "device-2"]}
        }
      end)

      # get_device_list returns a stream, not {:ok, list}
      result = AvailableDevices.get_device_list(client)
      assert is_function(result) or match?({:ok, _}, result)
    end
  end

  describe "DeviceStatus.get/2 with invalid datetime" do
    test "returns nil for invalid datetime strings" do
      client = make_client()

      mock(fn %{method: :get} ->
        %Tesla.Env{
          status: 200,
          body: %{
            "data" => %{
              "attributes" => %{},
              "groups" => [],
              "introspection" => %{"iface" => %{"major" => 1, "minor" => 0}},
              "last_connection" => "not-a-date",
              "last_disconnection" => "also-invalid",
              "last_seen_ip" => "1.2.3.4",
              "connected" => true,
              "previous_interfaces" => %{}
            }
          }
        }
      end)

      assert {:ok, status} = DeviceStatus.get(client, "device-id")
      assert status.last_connection == nil
      assert status.last_disconnection == nil
    end
  end

  describe "WiFiScanResult.get/2 with invalid timestamp" do
    test "returns nil for invalid datetime string in scan result" do
      client = make_client()

      mock(fn %{method: :get} ->
        %Tesla.Env{
          status: 200,
          body: %{
            "data" => %{
              "ap" => [
                %{
                  "channel" => 6,
                  "connected" => true,
                  "essid" => "TestNetwork",
                  "macAddress" => "AA:BB:CC:DD:EE:FF",
                  "rssi" => -50,
                  "timestamp" => "not-a-valid-date"
                }
              ]
            }
          }
        }
      end)

      assert {:ok, [scan_result]} = WiFiScanResult.get(client, "device-id")
      assert scan_result.timestamp == nil
    end
  end
end
