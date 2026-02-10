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

defmodule Edgehog.Astarte.Device.SystemStatusEdgeTest do
  use ExUnit.Case, async: true

  import Tesla.Mock

  alias Astarte.Client.AppEngine
  alias Edgehog.Astarte.Device.SystemStatus

  describe "get/2 edge cases" do
    test "returns error when systemStatus key is missing from data" do
      {:ok, client} =
        AppEngine.new("https://astarte.example.com", "test-realm", jwt: "test-token")

      mock(fn %{method: :get} ->
        %Tesla.Env{
          status: 200,
          body: %{"data" => %{"otherKey" => [%{}]}}
        }
      end)

      assert {:error, :system_status_not_found} = SystemStatus.get(client, "device-id")
    end

    test "returns error when systemStatus is empty list" do
      {:ok, client} =
        AppEngine.new("https://astarte.example.com", "test-realm", jwt: "test-token")

      mock(fn %{method: :get} ->
        %Tesla.Env{
          status: 200,
          body: %{"data" => %{}}
        }
      end)

      assert {:error, :system_status_not_found} = SystemStatus.get(client, "device-id")
    end

    test "handles nil datetime and non-binary longinteger in status" do
      {:ok, client} =
        AppEngine.new("https://astarte.example.com", "test-realm", jwt: "test-token")

      mock(fn %{method: :get} ->
        %Tesla.Env{
          status: 200,
          body: %{
            "data" => %{
              "systemStatus" => [
                %{
                  "bootId" => "boot-1",
                  "availMemoryBytes" => 12_345,
                  "taskCount" => 5,
                  "uptimeMillis" => nil,
                  "timestamp" => nil
                }
              ]
            }
          }
        }
      end)

      assert {:ok, %SystemStatus{timestamp: nil, uptime_milliseconds: nil, memory_free_bytes: nil}} =
               SystemStatus.get(client, "device-id")
    end

    test "handles invalid datetime string" do
      {:ok, client} =
        AppEngine.new("https://astarte.example.com", "test-realm", jwt: "test-token")

      mock(fn %{method: :get} ->
        %Tesla.Env{
          status: 200,
          body: %{
            "data" => %{
              "systemStatus" => [
                %{
                  "bootId" => "boot-1",
                  "availMemoryBytes" => "1000",
                  "taskCount" => 5,
                  "uptimeMillis" => "invalid",
                  "timestamp" => "not-a-date"
                }
              ]
            }
          }
        }
      end)

      assert {:ok, %SystemStatus{timestamp: nil, uptime_milliseconds: nil}} =
               SystemStatus.get(client, "device-id")
    end
  end
end
