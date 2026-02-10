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

defmodule Edgehog.Error.AstarteAPIErrorTest do
  use ExUnit.Case, async: true

  alias Edgehog.Error.AstarteAPIError

  describe "message/1" do
    test "formats error with detail in error key" do
      error = %AstarteAPIError{
        status: 404,
        response: %{"error" => %{"detail" => "Device not found"}},
        device_id: "device-123",
        interface: "com.example.Interface"
      }

      msg = AstarteAPIError.message(error)
      assert msg =~ "Astarte API Error with status 404"
      assert msg =~ "Device not found"
      assert msg =~ "device-123"
      assert msg =~ "com.example.Interface"
    end

    test "formats error with detail in errors key" do
      error = %AstarteAPIError{
        status: 422,
        response: %{"errors" => %{"detail" => "Validation failed"}},
        device_id: "device-456",
        interface: "com.example.Other"
      }

      msg = AstarteAPIError.message(error)
      assert msg =~ "Validation failed"
    end

    test "formats error with non-standard response" do
      error = %AstarteAPIError{
        status: 500,
        response: %{"something" => "unexpected"},
        device_id: nil,
        interface: nil
      }

      msg = AstarteAPIError.message(error)
      assert msg =~ "500"
      # Should JSON encode the response
      assert msg =~ "unexpected"
    end

    test "handles missing device_id and interface" do
      error = %AstarteAPIError{
        status: 400,
        response: %{"error" => %{"detail" => "Bad request"}},
        device_id: nil,
        interface: nil
      }

      msg = AstarteAPIError.message(error)
      # device_id and interface are nil, Map.get with default "Unknown" is used
      assert msg =~ "400"
      assert msg =~ "Bad request"
    end
  end

  describe "AshGraphql.Error impl" do
    test "converts to GraphQL error format" do
      error = %AstarteAPIError{
        status: 404,
        response: %{"error" => %{"detail" => "Not found"}},
        device_id: "d1",
        interface: "i1"
      }

      graphql_error = AshGraphql.Error.to_error(error)
      assert graphql_error.code == "astarte_api_error"
      assert graphql_error.short_message =~ "status 404"
      assert is_binary(graphql_error.message)
    end
  end
end
