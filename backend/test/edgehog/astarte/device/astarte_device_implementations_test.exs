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

defmodule Edgehog.Astarte.Device.AstarteDeviceImplementationsTest do
  use ExUnit.Case, async: true

  import Tesla.Mock

  alias Astarte.Client.AppEngine

  # Helper: create an AppEngine client with a fake JWT
  defp make_client do
    {:ok, client} =
      AppEngine.new("https://api.astarte.example.com", "test_realm", jwt: "test-token")

    client
  end

  # ── DeviceStatus ──────────────────────────────────────────────────────

  describe "DeviceStatus.get/2" do
    alias Edgehog.Astarte.Device.DeviceStatus

    test "parses device status data correctly" do
      client = make_client()

      mock(fn %{method: :get} ->
        json(%{
          "data" => %{
            "attributes" => %{"key" => "value"},
            "groups" => ["group1"],
            "introspection" => %{
              "com.example.Interface" => %{"major" => 1, "minor" => 2}
            },
            "last_connection" => "2025-01-15T10:30:00.000Z",
            "last_disconnection" => "2025-01-14T08:00:00.000Z",
            "last_seen_ip" => "192.168.1.1",
            "connected" => true,
            "previous_interfaces" => []
          }
        })
      end)

      assert {:ok, status} = DeviceStatus.get(client, "device-123")
      assert status.attributes == %{"key" => "value"}
      assert status.groups == ["group1"]
      assert %{"com.example.Interface" => %{major: 1, minor: 2}} = status.introspection
      assert %DateTime{} = status.last_connection
      assert status.online == true
      assert status.last_seen_ip == "192.168.1.1"
    end

    test "handles nil introspection" do
      client = make_client()

      mock(fn %{method: :get} ->
        json(%{
          "data" => %{
            "attributes" => nil,
            "groups" => nil,
            "introspection" => nil,
            "last_connection" => nil,
            "last_disconnection" => nil,
            "last_seen_ip" => nil,
            "connected" => nil,
            "previous_interfaces" => nil
          }
        })
      end)

      assert {:ok, status} = DeviceStatus.get(client, "device-123")
      assert status.introspection == %{}
      assert status.last_connection == nil
      assert status.online == false
    end

    test "returns error on API failure" do
      client = make_client()

      mock(fn %{method: :get} ->
        %Tesla.Env{status: 500, body: %{"errors" => %{"detail" => "Internal error"}}}
      end)

      assert {:error, _} = DeviceStatus.get(client, "device-123")
    end
  end

  # ── HardwareInfo ──────────────────────────────────────────────────────

  describe "HardwareInfo.get/2" do
    alias Edgehog.Astarte.Device.HardwareInfo

    test "parses hardware info correctly" do
      client = make_client()

      mock(fn %{method: :get} ->
        json(%{
          "data" => %{
            "cpu" => %{
              "architecture" => "arm64",
              "model" => "Cortex-A72",
              "modelName" => "BCM2711",
              "vendor" => "ARM"
            },
            "mem" => %{
              "totalBytes" => 4_294_967_296
            }
          }
        })
      end)

      assert {:ok, hw} = HardwareInfo.get(client, "device-123")
      assert hw.cpu_architecture == "arm64"
      assert hw.cpu_model == "Cortex-A72"
      assert hw.cpu_model_name == "BCM2711"
      assert hw.cpu_vendor == "ARM"
      assert hw.memory_total_bytes == 4_294_967_296
    end
  end

  # ── AvailableDeployments ──────────────────────────────────────────────

  describe "AvailableDeployments.get/2" do
    alias Edgehog.Astarte.Device.AvailableDeployments

    test "parses deployments correctly" do
      client = make_client()

      mock(fn %{method: :get} ->
        json(%{
          "data" => %{
            "dep-1" => %{"status" => "Started"},
            "dep-2" => %{"status" => "Stopped"}
          }
        })
      end)

      assert {:ok, deployments} = AvailableDeployments.get(client, "device-123")
      assert length(deployments) == 2
      statuses = Enum.map(deployments, & &1.status)
      assert :started in statuses
      assert :stopped in statuses
    end
  end

  # ── AvailableContainers ──────────────────────────────────────────────

  describe "AvailableContainers.get/2" do
    alias Edgehog.Astarte.Device.AvailableContainers

    test "parses containers correctly" do
      client = make_client()

      mock(fn %{method: :get} ->
        json(%{
          "data" => %{
            "container-1" => %{"status" => "Running"},
            "container-2" => %{"status" => "Stopped"}
          }
        })
      end)

      assert {:ok, containers} = AvailableContainers.get(client, "device-123")
      assert length(containers) == 2
    end

    test "parse_data/1 handles raw data" do
      result =
        AvailableContainers.parse_data(%{
          "c1" => %{"status" => "Running"}
        })

      assert [%{id: "c1", status: "Running"}] = result
    end
  end

  # ── AvailableImages ──────────────────────────────────────────────────

  describe "AvailableImages.get/2" do
    alias Edgehog.Astarte.Device.AvailableImages

    test "parses images correctly" do
      client = make_client()

      mock(fn %{method: :get} ->
        json(%{
          "data" => %{
            "img-1" => %{"pulled" => true},
            "img-2" => %{"pulled" => false}
          }
        })
      end)

      assert {:ok, images} = AvailableImages.get(client, "device-123")
      assert length(images) == 2
      pulled_statuses = Enum.map(images, & &1.pulled)
      assert true in pulled_statuses
      assert false in pulled_statuses
    end
  end

  # ── AvailableVolumes ──────────────────────────────────────────────────

  describe "AvailableVolumes.get/2" do
    alias Edgehog.Astarte.Device.AvailableVolumes

    test "parses volumes correctly" do
      client = make_client()

      mock(fn %{method: :get} ->
        json(%{
          "data" => %{
            "vol-1" => %{"created" => true},
            "vol-2" => %{"created" => false}
          }
        })
      end)

      assert {:ok, volumes} = AvailableVolumes.get(client, "device-123")
      assert length(volumes) == 2
    end
  end

  # ── AvailableNetworks ────────────────────────────────────────────────

  describe "AvailableNetworks.get/2" do
    alias Edgehog.Astarte.Device.AvailableNetworks

    test "parses networks correctly" do
      client = make_client()

      mock(fn %{method: :get} ->
        json(%{
          "data" => %{
            "net-1" => %{"created" => true}
          }
        })
      end)

      assert {:ok, networks} = AvailableNetworks.get(client, "device-123")
      assert [%{id: "net-1", created: true}] = networks
    end
  end

  # ── AvailableDeviceMappings ──────────────────────────────────────────

  describe "AvailableDeviceMappings.get/2" do
    alias Edgehog.Astarte.Device.AvailableDeviceMappings

    test "parses device mappings correctly" do
      client = make_client()

      mock(fn %{method: :get} ->
        json(%{
          "data" => %{
            "dm-1" => %{"present" => true}
          }
        })
      end)

      assert {:ok, mappings} = AvailableDeviceMappings.get(client, "device-123")
      assert [%{id: "dm-1", present: true}] = mappings
    end
  end

  # ── AvailableDevices ──────────────────────────────────────────────────

  describe "AvailableDevices" do
    alias Edgehog.Astarte.Device.AvailableDevices

    test "get_device_status/2 parses status correctly" do
      client = make_client()

      mock(fn %{method: :get} ->
        json(%{
          "data" => %{
            "id" => "device-abc",
            "connected" => true
          }
        })
      end)

      assert {:ok, data} = AvailableDevices.get_device_status(client, "device-abc")
      assert data["id"] == "device-abc"
      assert data["connected"] == true
    end
  end

  # ── LedBehavior ──────────────────────────────────────────────────────

  describe "LedBehavior.post/3" do
    alias Edgehog.Astarte.Device.LedBehavior

    test "sends LED behavior command" do
      client = make_client()

      mock(fn %{method: :post} ->
        json(%{"data" => %{}})
      end)

      assert :ok = LedBehavior.post(client, "device-123", "Blink60Seconds")
    end
  end

  # ── CreateContainerRequest ───────────────────────────────────────────

  describe "CreateContainerRequest" do
    alias Edgehog.Astarte.Device.CreateContainerRequest

    test "sends create container request" do
      client = make_client()

      mock(fn %{method: :post} ->
        json(%{"data" => %{}})
      end)

      request_data = %Edgehog.Astarte.Device.CreateContainerRequest.RequestData{
        id: "container-1",
        deploymentId: "dep-1",
        imageId: "img-1",
        hostname: "myhost"
      }

      assert :ok =
               CreateContainerRequest.send_create_container_request(
                 client,
                 "device-123",
                 request_data
               )
    end
  end

  # ── CreateDeploymentRequest ──────────────────────────────────────────

  describe "CreateDeploymentRequest" do
    alias Edgehog.Astarte.Device.CreateDeploymentRequest

    test "sends create deployment request" do
      client = make_client()

      mock(fn %{method: :post} ->
        json(%{"data" => %{}})
      end)

      request_data =
        struct!(Edgehog.Astarte.Device.CreateDeploymentRequest.RequestData, %{
          id: "dep-1",
          containers: []
        })

      assert :ok =
               CreateDeploymentRequest.send_create_deployment_request(
                 client,
                 "device-123",
                 request_data
               )
    end
  end

  # ── CreateNetworkRequest ──────────────────────────────────────────────

  describe "CreateNetworkRequest" do
    alias Edgehog.Astarte.Device.CreateNetworkRequest

    test "sends create network request" do
      client = make_client()

      mock(fn %{method: :post} ->
        json(%{"data" => %{}})
      end)

      request_data = %Edgehog.Astarte.Device.CreateNetworkRequest.RequestData{
        id: "net-1",
        deploymentId: "dep-1",
        driver: "bridge"
      }

      assert :ok =
               CreateNetworkRequest.send_create_network_request(
                 client,
                 "device-123",
                 request_data
               )
    end
  end

  # ── CreateDeviceMappingRequest ───────────────────────────────────────

  describe "CreateDeviceMappingRequest" do
    alias Edgehog.Astarte.Device.CreateDeviceMappingRequest

    test "sends create device mapping request" do
      client = make_client()

      mock(fn %{method: :post} ->
        json(%{"data" => %{}})
      end)

      request_data = %Edgehog.Astarte.Device.CreateDeviceMappingRequest.RequestData{
        id: "dm-1",
        deploymentId: "dep-1",
        pathOnHost: "/dev/sda",
        pathInContainer: "/dev/sda"
      }

      assert :ok =
               CreateDeviceMappingRequest.send_create_device_mapping_request(
                 client,
                 "device-123",
                 request_data
               )
    end
  end

  # ── CreateImageRequest ───────────────────────────────────────────────

  describe "CreateImageRequest" do
    alias Edgehog.Astarte.Device.CreateImageRequest

    test "sends create image request" do
      client = make_client()

      mock(fn %{method: :post} ->
        json(%{"data" => %{}})
      end)

      request_data = %Edgehog.Astarte.Device.CreateImageRequest.RequestData{
        id: "img-1",
        deploymentId: "dep-1",
        reference: "nginx:latest"
      }

      assert :ok =
               CreateImageRequest.send_create_image_request(client, "device-123", request_data)
    end
  end

  # ── CreateVolumeRequest ──────────────────────────────────────────────

  describe "CreateVolumeRequest" do
    alias Edgehog.Astarte.Device.CreateVolumeRequest

    test "sends create volume request" do
      client = make_client()

      mock(fn %{method: :post} ->
        json(%{"data" => %{}})
      end)

      request_data = %Edgehog.Astarte.Device.CreateVolumeRequest.RequestData{
        id: "vol-1",
        deploymentId: "dep-1",
        driver: "local"
      }

      assert :ok =
               CreateVolumeRequest.send_create_volume_request(client, "device-123", request_data)
    end
  end

  # ── DeploymentCommand ────────────────────────────────────────────────

  describe "DeploymentCommand" do
    alias Edgehog.Astarte.Device.DeploymentCommand

    test "sends deployment command" do
      client = make_client()

      mock(fn %{method: :post} ->
        json(%{"data" => %{}})
      end)

      request_data = %Edgehog.Astarte.Device.DeploymentCommand.RequestData{
        command: "start",
        deployment_id: "dep-1"
      }

      assert :ok = DeploymentCommand.send_deployment_command(client, "device-123", request_data)
    end
  end

  # ── DeploymentUpdate ──────────────────────────────────────────────────

  describe "DeploymentUpdate" do
    alias Edgehog.Astarte.Device.DeploymentUpdate

    test "sends deployment update" do
      client = make_client()

      mock(fn %{method: :post} ->
        json(%{"data" => %{}})
      end)

      request_data = %Edgehog.Astarte.Device.DeploymentUpdate.RequestData{
        from: "dep-v1",
        to: "dep-v2"
      }

      assert :ok = DeploymentUpdate.update(client, "device-123", request_data)
    end
  end

  # ── OTARequest.V1 ───────────────────────────────────────────────────

  describe "OTARequest.V1" do
    alias Edgehog.Astarte.Device.OTARequest.V1

    test "update/4 sends OTA update request" do
      client = make_client()

      mock(fn %{method: :post} ->
        json(%{"data" => %{}})
      end)

      assert :ok = V1.update(client, "device-123", "uuid-1", "https://example.com/fw.bin")
    end

    test "cancel/3 sends OTA cancel request" do
      client = make_client()

      mock(fn %{method: :post} ->
        json(%{"data" => %{}})
      end)

      assert :ok = V1.cancel(client, "device-123", "uuid-1")
    end
  end
end
