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

defmodule Edgehog.ErrorTest do
  use ExUnit.Case, async: true

  alias Astarte.Client.APIError
  alias Edgehog.Error

  describe "maybe_match_error/3" do
    test "returns :ok unchanged" do
      assert :ok = Error.maybe_match_error(:ok, "device-1", "TestInterface")
    end

    test "returns {:ok, value} unchanged" do
      assert {:ok, :data} = Error.maybe_match_error({:ok, :data}, "device-1", "TestInterface")
    end

    test "converts 404 APIError to DeviceOffline error" do
      api_error = %APIError{status: 404, response: "Not Found"}

      assert {:error, %Error.DeviceOffline{}} =
               Error.maybe_match_error({:error, api_error}, "device-1", "TestInterface")
    end

    test "converts non-404 APIError to AstarteAPIError" do
      api_error = %APIError{status: 500, response: "Internal Server Error"}

      assert {:error, %Error.AstarteAPIError{}} =
               Error.maybe_match_error({:error, api_error}, "device-1", "TestInterface")
    end
  end

  describe "DeviceOffline" do
    test "message/1 includes device_id and interface" do
      error = Error.DeviceOffline.exception(device_id: "test-device", interface: "TestInterface")
      msg = Error.DeviceOffline.message(error)
      assert msg =~ "test-device"
      assert msg =~ "TestInterface"
    end
  end
end
