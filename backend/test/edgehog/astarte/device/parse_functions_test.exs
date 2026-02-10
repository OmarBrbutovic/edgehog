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

defmodule Edgehog.Astarte.Device.ParseFunctionsTest do
  use ExUnit.Case, async: true

  alias Astarte.Client.AppEngine
  alias Edgehog.Astarte.Device.BaseImage
  alias Edgehog.Astarte.Device.CellularConnection
  alias Edgehog.Astarte.Device.Geolocation
  alias Edgehog.Astarte.Device.NetworkInterface
  alias Edgehog.Astarte.Device.OSInfo
  alias Edgehog.Astarte.Device.RuntimeInfo
  alias Edgehog.Astarte.Device.StorageUsage
  alias Edgehog.Astarte.Device.SystemStatus
  alias Edgehog.Astarte.Device.WiFiScanResult

  # ── BaseImage ──

  describe "BaseImage.get/2" do
    setup do
      Tesla.Mock.mock(fn
        %{method: :get} ->
          {:ok,
           %Tesla.Env{
             status: 200,
             body: %{
               "data" => %{
                 "name" => "base",
                 "version" => "1.0",
                 "buildId" => "b1",
                 "fingerprint" => "fp"
               }
             }
           }}
      end)

      {:ok, client} =
        AppEngine.new("https://api.example.com", "test", jwt: "token")

      {:ok, client: client}
    end

    test "returns parsed base image", %{client: client} do
      {:ok, result} = BaseImage.get(client, "device1")
      assert result.name == "base"
      assert result.version == "1.0"
      assert result.build_id == "b1"
      assert result.fingerprint == "fp"
    end
  end

  describe "BaseImage.parse_data/1" do
    test "parses all fields" do
      data = %{"name" => "base", "version" => "1.0", "buildId" => "b1", "fingerprint" => "fp"}
      result = BaseImage.parse_data(data)
      assert result.name == "base"
      assert result.version == "1.0"
      assert result.build_id == "b1"
      assert result.fingerprint == "fp"
    end

    test "handles nil fields" do
      result = BaseImage.parse_data(%{})
      assert result.name == nil
      assert result.version == nil
    end
  end

  # ── OSInfo ──

  describe "OSInfo.get/2" do
    setup do
      Tesla.Mock.mock(fn
        %{method: :get} ->
          {:ok,
           %Tesla.Env{
             status: 200,
             body: %{"data" => %{"osName" => "Linux", "osVersion" => "5.10"}}
           }}
      end)

      {:ok, client} =
        AppEngine.new("https://api.example.com", "test", jwt: "token")

      {:ok, client: client}
    end

    test "returns parsed os info", %{client: client} do
      {:ok, result} = OSInfo.get(client, "device1")
      assert result.name == "Linux"
      assert result.version == "5.10"
    end
  end

  describe "OSInfo.parse_data/1" do
    test "parses os name and version" do
      data = %{"osName" => "Linux", "osVersion" => "5.10"}
      result = OSInfo.parse_data(data)
      assert result.name == "Linux"
      assert result.version == "5.10"
    end
  end

  # ── RuntimeInfo ──

  describe "RuntimeInfo.get/2" do
    setup do
      Tesla.Mock.mock(fn
        %{method: :get} ->
          {:ok,
           %Tesla.Env{
             status: 200,
             body: %{
               "data" => %{
                 "name" => "edgehog",
                 "version" => "1.0",
                 "environment" => "prod",
                 "url" => "http://example.com"
               }
             }
           }}
      end)

      {:ok, client} =
        AppEngine.new("https://api.example.com", "test", jwt: "token")

      {:ok, client: client}
    end

    test "returns parsed runtime info", %{client: client} do
      {:ok, result} = RuntimeInfo.get(client, "device1")
      assert result.name == "edgehog"
      assert result.version == "1.0"
      assert result.environment == "prod"
      assert result.url == "http://example.com"
    end
  end

  describe "RuntimeInfo.parse_data/1" do
    test "parses all fields" do
      data = %{
        "name" => "edgehog",
        "version" => "1.0",
        "environment" => "prod",
        "url" => "http://example.com"
      }

      result = RuntimeInfo.parse_data(data)
      assert result.name == "edgehog"
      assert result.version == "1.0"
      assert result.environment == "prod"
      assert result.url == "http://example.com"
    end
  end

  # ── NetworkInterface ──

  describe "NetworkInterface.get/2" do
    setup do
      Tesla.Mock.mock(fn
        %{method: :get} ->
          {:ok,
           %Tesla.Env{
             status: 200,
             body: %{
               "data" => %{
                 "eth0" => %{"macAddress" => "AA:BB:CC:DD:EE:FF", "technologyType" => "ethernet"}
               }
             }
           }}
      end)

      {:ok, client} =
        AppEngine.new("https://api.example.com", "test", jwt: "token")

      {:ok, client: client}
    end

    test "returns parsed interfaces", %{client: client} do
      {:ok, result} = NetworkInterface.get(client, "device1")
      assert [iface] = result
      assert iface.name == "eth0"
      assert iface.mac_address == "AA:BB:CC:DD:EE:FF"
    end
  end

  describe "NetworkInterface.parse_data/1" do
    test "parses interface list" do
      data = %{
        "eth0" => %{"macAddress" => "AA:BB:CC:DD:EE:FF", "technologyType" => "ethernet"},
        "wlan0" => %{"macAddress" => "11:22:33:44:55:66", "technologyType" => "wifi"}
      }

      result = NetworkInterface.parse_data(data)
      assert length(result) == 2
      assert Enum.any?(result, &(&1.name == "eth0" and &1.mac_address == "AA:BB:CC:DD:EE:FF"))
      assert Enum.any?(result, &(&1.name == "wlan0" and &1.technology == "wifi"))
    end
  end

  # ── CellularConnection ──

  describe "CellularConnection.get_modem_properties/2" do
    setup do
      Tesla.Mock.mock(fn
        %{method: :get} ->
          {:ok,
           %Tesla.Env{
             status: 200,
             body: %{
               "data" => %{
                 "modem_1" => %{"apn" => "internet", "imei" => "123", "imsi" => "456"}
               }
             }
           }}
      end)

      {:ok, client} =
        AppEngine.new("https://api.example.com", "test", jwt: "token")

      {:ok, client: client}
    end

    test "returns parsed modem properties", %{client: client} do
      {:ok, result} = CellularConnection.get_modem_properties(client, "device1")
      assert [modem] = result
      assert modem.slot == "modem_1"
      assert modem.apn == "internet"
    end
  end

  describe "CellularConnection.get_modem_status/2" do
    setup do
      Tesla.Mock.mock(fn
        %{method: :get} ->
          {:ok,
           %Tesla.Env{
             status: 200,
             body: %{
               "data" => %{
                 "modem_1" => [
                   %{
                     "carrier" => "TestCarrier",
                     "cellId" => "123",
                     "mobileCountryCode" => 222,
                     "mobileNetworkCode" => 10,
                     "localAreaCode" => 1234,
                     "registrationStatus" => "registered",
                     "rssi" => -70,
                     "technology" => "lte"
                   }
                 ]
               }
             }
           }}
      end)

      {:ok, client} =
        AppEngine.new("https://api.example.com", "test", jwt: "token")

      {:ok, client: client}
    end

    test "returns parsed modem status", %{client: client} do
      {:ok, result} = CellularConnection.get_modem_status(client, "device1")
      assert [modem] = result
      assert modem.carrier == "TestCarrier"
      assert modem.cell_id == 123
    end
  end

  describe "CellularConnection.parse_properties_data/1" do
    test "parses modem properties" do
      data = %{
        "modem_1" => %{"apn" => "internet", "imei" => "123456", "imsi" => "9876"}
      }

      result = CellularConnection.parse_properties_data(data)
      assert [modem] = result
      assert modem.slot == "modem_1"
      assert modem.apn == "internet"
      assert modem.imei == "123456"
      assert modem.imsi == "9876"
    end
  end

  describe "CellularConnection.parse_status_data/1" do
    test "parses modem status with longinteger cell_id" do
      data = %{
        "modem_1" => [
          %{
            "carrier" => "Carrier",
            "cellId" => "123456789",
            "mobileCountryCode" => 222,
            "mobileNetworkCode" => 10,
            "localAreaCode" => 1234,
            "registrationStatus" => "registered",
            "rssi" => -70,
            "technology" => "lte"
          }
        ]
      }

      result = CellularConnection.parse_status_data(data)
      assert [modem] = result
      assert modem.slot == "modem_1"
      assert modem.carrier == "Carrier"
      assert modem.cell_id == 123_456_789
      assert modem.technology == "lte"
    end

    test "parses nil cell_id" do
      data = %{
        "modem_1" => [%{"cellId" => nil, "carrier" => nil}]
      }

      [modem] = CellularConnection.parse_status_data(data)
      assert modem.cell_id == nil
    end

    test "parses invalid string cell_id" do
      data = %{
        "modem_1" => [%{"cellId" => "not_a_number"}]
      }

      [modem] = CellularConnection.parse_status_data(data)
      assert modem.cell_id == nil
    end
  end

  # ── SystemStatus ──

  describe "SystemStatus.get/2 success" do
    setup do
      Tesla.Mock.mock(fn
        %{method: :get} ->
          {:ok,
           %Tesla.Env{
             status: 200,
             body: %{
               "data" => %{
                 "systemStatus" => [
                   %{
                     "bootId" => "boot-123",
                     "availMemoryBytes" => "1048576",
                     "taskCount" => 42,
                     "uptimeMillis" => "86400000",
                     "timestamp" => "2024-01-01T12:00:00Z"
                   }
                 ]
               }
             }
           }}
      end)

      {:ok, client} =
        AppEngine.new("https://api.example.com", "test", jwt: "token")

      {:ok, client: client}
    end

    test "returns parsed system status", %{client: client} do
      {:ok, result} = SystemStatus.get(client, "device1")
      assert result.boot_id == "boot-123"
      assert result.memory_free_bytes == 1_048_576
      assert result.task_count == 42
      assert result.uptime_milliseconds == 86_400_000
      assert %DateTime{} = result.timestamp
    end
  end

  describe "SystemStatus.get/2 not found" do
    setup do
      Tesla.Mock.mock(fn
        %{method: :get} ->
          {:ok, %Tesla.Env{status: 200, body: %{"data" => %{}}}}
      end)

      {:ok, client} =
        AppEngine.new("https://api.example.com", "test", jwt: "token")

      {:ok, client: client}
    end

    test "returns error when system status not found", %{client: client} do
      assert {:error, :system_status_not_found} = SystemStatus.get(client, "device1")
    end
  end

  describe "SystemStatus.get/2 error" do
    # Testing the internal parsing via Tesla mock
    setup do
      Tesla.Mock.mock(fn _env -> {:error, :connection_error} end)

      {:ok, client} =
        AppEngine.new("https://api.example.com", "test", jwt: "token")

      {:ok, client: client}
    end

    test "returns error when API call fails", %{client: client} do
      assert {:error, _} = SystemStatus.get(client, "device1")
    end
  end

  # ── StorageUsage ──

  describe "StorageUsage" do
    setup do
      Tesla.Mock.mock(fn
        %{method: :get} ->
          data = %{
            "data" => %{
              "disk0" => [%{"totalBytes" => "1000000", "freeBytes" => "500000"}],
              "disk1" => %{"totalBytes" => "2000", "freeBytes" => "abc"}
            }
          }

          {:ok, %Tesla.Env{status: 200, body: data}}
      end)

      {:ok, client} =
        AppEngine.new("https://api.example.com", "test", jwt: "token")

      {:ok, client: client}
    end

    test "parses storage units with longinteger values", %{client: client} do
      {:ok, units} = StorageUsage.get(client, "device1")
      assert length(units) == 2

      disk0 = Enum.find(units, &(&1.label == "disk0"))
      assert disk0.total_bytes == 1_000_000
      assert disk0.free_bytes == 500_000

      # disk1 has single object (not list) and invalid free_bytes
      disk1 = Enum.find(units, &(&1.label == "disk1"))
      assert disk1.total_bytes == 2000
      assert disk1.free_bytes == nil
    end
  end

  # ── WiFiScanResult ──

  describe "WiFiScanResult" do
    setup do
      Tesla.Mock.mock(fn
        %{method: :get} ->
          data = %{
            "data" => %{
              "ap" => [
                %{
                  "channel" => 6,
                  "connected" => true,
                  "essid" => "MyNetwork",
                  "macAddress" => "AA:BB:CC:DD:EE:FF",
                  "rssi" => -50,
                  "timestamp" => "2024-01-01T12:00:00Z"
                },
                %{
                  "channel" => 11,
                  "connected" => false,
                  "essid" => "Other",
                  "macAddress" => "11:22:33:44:55:66",
                  "rssi" => -80,
                  "timestamp" => nil
                }
              ]
            }
          }

          {:ok, %Tesla.Env{status: 200, body: data}}
      end)

      {:ok, client} =
        AppEngine.new("https://api.example.com", "test", jwt: "token")

      {:ok, client: client}
    end

    test "parses wifi scan results with timestamps", %{client: client} do
      {:ok, results} = WiFiScanResult.get(client, "device1")
      assert length(results) == 2

      first = Enum.find(results, &(&1.essid == "MyNetwork"))
      assert first.channel == 6
      assert first.connected == true
      assert first.rssi == -50
      assert %DateTime{} = first.timestamp

      second = Enum.find(results, &(&1.essid == "Other"))
      assert second.timestamp == nil
    end
  end

  # ── Geolocation ──

  describe "Geolocation.get/2" do
    setup do
      Tesla.Mock.mock(fn
        %{method: :get} ->
          {:ok,
           %Tesla.Env{
             status: 200,
             body: %{
               "data" => %{
                 "gps" => [
                   %{
                     "latitude" => 45.0,
                     "longitude" => 9.0,
                     "altitude" => 100.0,
                     "accuracy" => 5.0,
                     "altitudeAccuracy" => 10.0,
                     "heading" => 180.0,
                     "speed" => 1.5,
                     "timestamp" => "2024-06-15T10:00:00Z"
                   }
                 ]
               }
             }
           }}
      end)

      {:ok, client} =
        AppEngine.new("https://api.example.com", "test", jwt: "token")

      {:ok, client: client}
    end

    test "returns parsed geolocation", %{client: client} do
      {:ok, result} = Geolocation.get(client, "device1")
      assert [pos] = result
      assert pos.sensor_id == "gps"
      assert pos.latitude == 45.0
      assert pos.longitude == 9.0
    end
  end

  describe "Geolocation.parse_data/1" do
    test "parses sensor positions, rejecting nil lat/lon" do
      data = %{
        "gps" => [
          %{
            "latitude" => 45.0,
            "longitude" => 9.0,
            "altitude" => 100.0,
            "accuracy" => 5.0,
            "altitudeAccuracy" => 10.0,
            "heading" => 180.0,
            "speed" => 1.5,
            "timestamp" => "2024-06-15T10:00:00Z"
          }
        ],
        "network" => [
          %{"latitude" => nil, "longitude" => nil}
        ],
        "single" => %{
          "latitude" => 46.0,
          "longitude" => 10.0,
          "timestamp" => "invalid-date"
        }
      }

      {:ok, positions} = Geolocation.parse_data(data)
      # "network" should be rejected (nil lat/lon)
      assert length(positions) == 2

      gps = Enum.find(positions, &(&1.sensor_id == "gps"))
      assert gps.latitude == 45.0
      assert gps.longitude == 9.0
      assert gps.altitude == 100.0
      assert %DateTime{} = gps.timestamp

      single = Enum.find(positions, &(&1.sensor_id == "single"))
      assert single.latitude == 46.0
      # invalid timestamp returns nil
      assert single.timestamp == nil
    end
  end
end
