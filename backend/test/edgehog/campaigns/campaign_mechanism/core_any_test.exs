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

defmodule Edgehog.Campaigns.CampaignMechanism.Core.AnyTest do
  use ExUnit.Case, async: true

  alias Astarte.Client.APIError
  alias Edgehog.Campaigns.CampaignMechanism.Core
  alias Edgehog.Campaigns.CampaignTarget

  # Use a struct that doesn't have its own Core implementation to trigger the Any fallback
  defmodule TestStruct do
    @moduledoc false
    defstruct [:max_in_progress_operations, :request_retries, :request_timeout_seconds, :type]
  end

  defp any_mechanism(attrs \\ %{}) do
    defaults = %{
      max_in_progress_operations: 10,
      request_retries: 3,
      request_timeout_seconds: 300,
      type: :test
    }

    struct(TestStruct, Map.merge(defaults, attrs))
  end

  describe "available_slots/2" do
    test "returns available slots" do
      mechanism = any_mechanism(%{max_in_progress_operations: 10})
      assert Core.available_slots(mechanism, 3) == 7
    end

    test "returns 0 when in_progress equals max" do
      mechanism = any_mechanism(%{max_in_progress_operations: 5})
      assert Core.available_slots(mechanism, 5) == 0
    end

    test "returns 0 when in_progress exceeds max" do
      mechanism = any_mechanism(%{max_in_progress_operations: 5})
      assert Core.available_slots(mechanism, 8) == 0
    end
  end

  describe "get_campaign_status/2" do
    test "returns campaign status" do
      mechanism = any_mechanism()
      campaign = %{status: :in_progress}
      assert Core.get_campaign_status(mechanism, campaign) == :in_progress
    end

    test "returns idle status" do
      mechanism = any_mechanism()
      campaign = %{status: :idle}
      assert Core.get_campaign_status(mechanism, campaign) == :idle
    end
  end

  describe "can_retry?/2" do
    test "returns true when retry_count < request_retries" do
      mechanism = any_mechanism(%{request_retries: 3})
      target = %{retry_count: 1}
      assert Core.can_retry?(mechanism, target)
    end

    test "returns false when retry_count >= request_retries" do
      mechanism = any_mechanism(%{request_retries: 3})
      target = %{retry_count: 3}
      refute Core.can_retry?(mechanism, target)
    end

    test "returns false when retry_count exceeds request_retries" do
      mechanism = any_mechanism(%{request_retries: 2})
      target = %{retry_count: 5}
      refute Core.can_retry?(mechanism, target)
    end
  end

  describe "pending_request_timeout_ms/3" do
    test "computes remaining timeout" do
      mechanism = any_mechanism(%{request_timeout_seconds: 60})
      now = DateTime.utc_now()
      latest_attempt = DateTime.add(now, -30, :second)

      target = %CampaignTarget{
        latest_attempt: latest_attempt
      }

      result = Core.pending_request_timeout_ms(mechanism, target, now)
      # Should be approximately 30 seconds remaining (30000 ms)
      assert result > 29_000
      assert result <= 30_000
    end

    test "returns 0 when timeout is exceeded" do
      mechanism = any_mechanism(%{request_timeout_seconds: 30})
      now = DateTime.utc_now()
      latest_attempt = DateTime.add(now, -60, :second)

      target = %CampaignTarget{
        latest_attempt: latest_attempt
      }

      assert Core.pending_request_timeout_ms(mechanism, target, now) == 0
    end
  end

  describe "error_message/3" do
    test "connection refused" do
      mechanism = any_mechanism()
      msg = Core.error_message(mechanism, "connection refused", "device-123")
      assert msg =~ "device-123"
      assert msg =~ "Astarte API"
    end

    test "4xx API error" do
      mechanism = any_mechanism()
      error = %APIError{status: 404, response: "Not Found"}
      msg = Core.error_message(mechanism, error, "device-456")
      assert msg =~ "device-456"
      assert msg =~ "404"
    end

    test "5xx API error" do
      mechanism = any_mechanism()
      error = %APIError{status: 502, response: "Bad Gateway"}
      msg = Core.error_message(mechanism, error, "device-789")
      assert msg =~ "device-789"
      assert msg =~ "502"
    end

    test "unknown error" do
      mechanism = any_mechanism()
      msg = Core.error_message(mechanism, :some_error, "device-abc")
      assert msg =~ "device-abc"
      assert msg =~ "unknown error"
    end
  end

  describe "temporary_error?/2" do
    test "connection refused is temporary" do
      mechanism = any_mechanism()
      assert Core.temporary_error?(mechanism, "connection refused")
    end

    test "5xx API error is temporary" do
      mechanism = any_mechanism()
      error = %APIError{status: 500, response: "Internal Server Error"}
      assert Core.temporary_error?(mechanism, error)
    end

    test "other errors are not temporary" do
      mechanism = any_mechanism()
      refute Core.temporary_error?(mechanism, :some_error)
    end

    test "4xx API error is not temporary" do
      mechanism = any_mechanism()
      error = %APIError{status: 400, response: "Bad Request"}
      refute Core.temporary_error?(mechanism, error)
    end
  end

  describe "raise stubs for Any" do
    test "get_operation_id raises" do
      mechanism = any_mechanism()

      assert_raise RuntimeError, ~r/must be implemented/, fn ->
        Core.get_operation_id(mechanism, %{})
      end
    end

    test "mark_operation_as_timed_out! raises" do
      mechanism = any_mechanism()

      assert_raise RuntimeError, ~r/must be implemented/, fn ->
        Core.mark_operation_as_timed_out!(mechanism, "op-1", "tenant-1")
      end
    end

    test "subscribe_to_operation_updates! raises" do
      mechanism = any_mechanism()

      assert_raise RuntimeError, ~r/must be implemented/, fn ->
        Core.subscribe_to_operation_updates!(mechanism, "op-1")
      end
    end

    test "unsubscribe_to_operation_updates! raises" do
      mechanism = any_mechanism()

      assert_raise RuntimeError, ~r/must be implemented/, fn ->
        Core.unsubscribe_to_operation_updates!(mechanism, "op-1")
      end
    end

    test "fetch_next_valid_target raises" do
      mechanism = any_mechanism()

      assert_raise RuntimeError, ~r/must be implemented/, fn ->
        Core.fetch_next_valid_target(mechanism, "campaign-1", "tenant-1")
      end
    end

    test "do_operation raises" do
      mechanism = any_mechanism()

      assert_raise RuntimeError, ~r/must be implemented/, fn ->
        Core.do_operation(mechanism, %{})
      end
    end

    test "retry_operation raises" do
      mechanism = any_mechanism()

      assert_raise RuntimeError, ~r/must be implemented/, fn ->
        Core.retry_operation(mechanism, %{})
      end
    end

    test "get_mechanism raises" do
      mechanism = any_mechanism()

      assert_raise RuntimeError, ~r/must be implemented/, fn ->
        Core.get_mechanism(mechanism, %{})
      end
    end

    test "list_in_progress_targets raises" do
      mechanism = any_mechanism()

      assert_raise RuntimeError, ~r/must be implemented/, fn ->
        Core.list_in_progress_targets(mechanism, "tenant-1", "campaign-1")
      end
    end
  end
end
