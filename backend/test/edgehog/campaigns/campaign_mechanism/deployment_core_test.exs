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

defmodule Edgehog.Campaigns.CampaignMechanism.DeploymentCoreTest do
  use ExUnit.Case, async: true

  alias Astarte.Client.APIError
  alias Edgehog.Campaigns.CampaignMechanism.Core

  defp deploy_mechanism(attrs \\ %{}) do
    defaults = %{
      type: :deployment_deploy,
      max_failure_percentage: 10.0,
      max_in_progress_operations: 5,
      request_retries: 3,
      request_timeout_seconds: 300
    }

    struct(Edgehog.Campaigns.CampaignMechanism.DeploymentDeploy, Map.merge(defaults, attrs))
  end

  defp start_mechanism(attrs \\ %{}) do
    defaults = %{
      type: :deployment_start,
      max_failure_percentage: 10.0,
      max_in_progress_operations: 5,
      request_retries: 3,
      request_timeout_seconds: 300
    }

    struct(Edgehog.Campaigns.CampaignMechanism.DeploymentStart, Map.merge(defaults, attrs))
  end

  defp stop_mechanism(attrs \\ %{}) do
    defaults = %{
      type: :deployment_stop,
      max_failure_percentage: 10.0,
      max_in_progress_operations: 5,
      request_retries: 3,
      request_timeout_seconds: 300
    }

    struct(Edgehog.Campaigns.CampaignMechanism.DeploymentStop, Map.merge(defaults, attrs))
  end

  defp delete_mechanism(attrs \\ %{}) do
    defaults = %{
      type: :deployment_delete,
      max_failure_percentage: 10.0,
      max_in_progress_operations: 5,
      request_retries: 3,
      request_timeout_seconds: 300
    }

    struct(Edgehog.Campaigns.CampaignMechanism.DeploymentDelete, Map.merge(defaults, attrs))
  end

  defp upgrade_mechanism(attrs \\ %{}) do
    defaults = %{
      type: :deployment_upgrade,
      max_failure_percentage: 10.0,
      max_in_progress_operations: 5,
      request_retries: 3,
      request_timeout_seconds: 300
    }

    struct(Edgehog.Campaigns.CampaignMechanism.DeploymentUpgrade, Map.merge(defaults, attrs))
  end

  describe "DeploymentDeploy Core" do
    test "get_operation_id returns target deployment_id" do
      mechanism = deploy_mechanism()
      target = %{deployment_id: "deploy-123"}

      assert Core.get_operation_id(mechanism, target) == "deploy-123"
    end

    test "subscribe_to_operation_updates! subscribes to PubSub" do
      mechanism = deploy_mechanism()
      op_id = "deploy-sub-#{System.unique_integer([:positive])}"

      Core.subscribe_to_operation_updates!(mechanism, op_id)
      Core.unsubscribe_to_operation_updates!(mechanism, op_id)
    end

    test "unsubscribe_to_operation_updates! unsubscribes from PubSub" do
      mechanism = deploy_mechanism()
      op_id = "deploy-unsub-#{System.unique_integer([:positive])}"

      Core.subscribe_to_operation_updates!(mechanism, op_id)
      Core.unsubscribe_to_operation_updates!(mechanism, op_id)
    end

    test "error_message delegates to Any" do
      mechanism = deploy_mechanism()
      msg = Core.error_message(mechanism, "connection refused", "device-123")
      assert msg =~ "device-123"
      assert msg =~ "Astarte API"
    end

    test "error_message with unknown error" do
      mechanism = deploy_mechanism()
      msg = Core.error_message(mechanism, :some_error, "device-456")
      assert msg =~ "device-456"
      assert msg =~ "unknown error"
    end

    test "temporary_error? delegates to Any for connection refused" do
      mechanism = deploy_mechanism()
      assert Core.temporary_error?(mechanism, "connection refused")
    end

    test "temporary_error? delegates to Any for other errors" do
      mechanism = deploy_mechanism()
      refute Core.temporary_error?(mechanism, :some_error)
    end

    test "available_slots delegates to Any" do
      mechanism = deploy_mechanism(%{max_in_progress_operations: 10})
      assert Core.available_slots(mechanism, 3) == 7
    end

    test "get_campaign_status delegates to Any" do
      mechanism = deploy_mechanism()
      assert Core.get_campaign_status(mechanism, %{status: :in_progress}) == :in_progress
    end

    test "can_retry? delegates to Any" do
      mechanism = deploy_mechanism(%{request_retries: 3})
      assert Core.can_retry?(mechanism, %{retry_count: 1})
      refute Core.can_retry?(mechanism, %{retry_count: 3})
    end
  end

  describe "DeploymentStart Core" do
    test "get_operation_id returns target deployment_id" do
      mechanism = start_mechanism()
      target = %{deployment_id: "start-123"}

      assert Core.get_operation_id(mechanism, target) == "start-123"
    end

    test "subscribe_to_operation_updates! subscribes to PubSub" do
      mechanism = start_mechanism()
      op_id = "start-sub-#{System.unique_integer([:positive])}"

      Core.subscribe_to_operation_updates!(mechanism, op_id)
      Core.unsubscribe_to_operation_updates!(mechanism, op_id)
    end

    test "unsubscribe_to_operation_updates! unsubscribes" do
      mechanism = start_mechanism()
      op_id = "start-unsub-#{System.unique_integer([:positive])}"

      Core.subscribe_to_operation_updates!(mechanism, op_id)
      Core.unsubscribe_to_operation_updates!(mechanism, op_id)
    end

    test "error_message delegates to Any" do
      mechanism = start_mechanism()
      msg = Core.error_message(mechanism, "connection refused", "device-start")
      assert msg =~ "device-start"
    end

    test "temporary_error? for 5xx error" do
      mechanism = start_mechanism()
      error = %APIError{status: 500, response: "Internal Server Error"}
      assert Core.temporary_error?(mechanism, error)
    end

    test "available_slots delegates to Any" do
      mechanism = start_mechanism(%{max_in_progress_operations: 8})
      assert Core.available_slots(mechanism, 5) == 3
    end

    test "can_retry? delegates to Any" do
      mechanism = start_mechanism(%{request_retries: 2})
      assert Core.can_retry?(mechanism, %{retry_count: 0})
      refute Core.can_retry?(mechanism, %{retry_count: 2})
    end
  end

  describe "DeploymentStop Core" do
    test "get_operation_id returns target deployment_id" do
      mechanism = stop_mechanism()
      target = %{deployment_id: "stop-123"}

      assert Core.get_operation_id(mechanism, target) == "stop-123"
    end

    test "subscribe_to_operation_updates! subscribes to PubSub" do
      mechanism = stop_mechanism()
      op_id = "stop-sub-#{System.unique_integer([:positive])}"

      Core.subscribe_to_operation_updates!(mechanism, op_id)
      Core.unsubscribe_to_operation_updates!(mechanism, op_id)
    end

    test "unsubscribe_to_operation_updates! unsubscribes" do
      mechanism = stop_mechanism()
      op_id = "stop-unsub-#{System.unique_integer([:positive])}"

      Core.subscribe_to_operation_updates!(mechanism, op_id)
      Core.unsubscribe_to_operation_updates!(mechanism, op_id)
    end

    test "error_message delegates to Any" do
      mechanism = stop_mechanism()
      msg = Core.error_message(mechanism, "connection refused", "device-stop")
      assert msg =~ "device-stop"
    end

    test "error_message with API error" do
      mechanism = stop_mechanism()
      error = %APIError{status: 404, response: "Not Found"}
      msg = Core.error_message(mechanism, error, "device-stop-2")
      assert msg =~ "device-stop-2"
      assert msg =~ "404"
    end

    test "temporary_error? delegates to Any" do
      mechanism = stop_mechanism()
      refute Core.temporary_error?(mechanism, :not_temporary)
    end

    test "available_slots delegates to Any" do
      mechanism = stop_mechanism(%{max_in_progress_operations: 15})
      assert Core.available_slots(mechanism, 10) == 5
    end
  end

  describe "DeploymentDelete Core" do
    test "get_operation_id returns target deployment_id" do
      mechanism = delete_mechanism()
      target = %{deployment_id: "delete-123"}

      assert Core.get_operation_id(mechanism, target) == "delete-123"
    end

    test "subscribe_to_operation_updates! subscribes to PubSub" do
      mechanism = delete_mechanism()
      op_id = "delete-sub-#{System.unique_integer([:positive])}"

      Core.subscribe_to_operation_updates!(mechanism, op_id)
      Core.unsubscribe_to_operation_updates!(mechanism, op_id)
    end

    test "unsubscribe_to_operation_updates! unsubscribes" do
      mechanism = delete_mechanism()
      op_id = "delete-unsub-#{System.unique_integer([:positive])}"

      Core.subscribe_to_operation_updates!(mechanism, op_id)
      Core.unsubscribe_to_operation_updates!(mechanism, op_id)
    end

    test "error_message delegates to Any" do
      mechanism = delete_mechanism()
      msg = Core.error_message(mechanism, "connection refused", "device-del")
      assert msg =~ "device-del"
    end

    test "temporary_error? delegates to Any" do
      mechanism = delete_mechanism()
      assert Core.temporary_error?(mechanism, "connection refused")
      refute Core.temporary_error?(mechanism, :other)
    end

    test "available_slots delegates to Any" do
      mechanism = delete_mechanism(%{max_in_progress_operations: 20})
      assert Core.available_slots(mechanism, 12) == 8
    end

    test "can_retry? delegates to Any" do
      mechanism = delete_mechanism(%{request_retries: 5})
      assert Core.can_retry?(mechanism, %{retry_count: 2})
      refute Core.can_retry?(mechanism, %{retry_count: 5})
    end
  end

  describe "DeploymentUpgrade Core" do
    test "get_operation_id returns target deployment_id" do
      mechanism = upgrade_mechanism()
      target = %{deployment_id: "upgrade-123"}

      assert Core.get_operation_id(mechanism, target) == "upgrade-123"
    end

    test "subscribe_to_operation_updates! subscribes to PubSub" do
      mechanism = upgrade_mechanism()
      op_id = "upgrade-sub-#{System.unique_integer([:positive])}"

      Core.subscribe_to_operation_updates!(mechanism, op_id)
      Core.unsubscribe_to_operation_updates!(mechanism, op_id)
    end

    test "unsubscribe_to_operation_updates! unsubscribes" do
      mechanism = upgrade_mechanism()
      op_id = "upgrade-unsub-#{System.unique_integer([:positive])}"

      Core.subscribe_to_operation_updates!(mechanism, op_id)
      Core.unsubscribe_to_operation_updates!(mechanism, op_id)
    end

    test "error_message delegates to Any" do
      mechanism = upgrade_mechanism()
      msg = Core.error_message(mechanism, :some_error, "device-upg")
      assert msg =~ "device-upg"
    end

    test "temporary_error? delegates to Any" do
      mechanism = upgrade_mechanism()
      error = %APIError{status: 502, response: "Bad Gateway"}
      assert Core.temporary_error?(mechanism, error)
    end

    test "available_slots delegates to Any" do
      mechanism = upgrade_mechanism(%{max_in_progress_operations: 6})
      assert Core.available_slots(mechanism, 4) == 2
    end

    test "can_retry? delegates to Any" do
      mechanism = upgrade_mechanism(%{request_retries: 1})
      assert Core.can_retry?(mechanism, %{retry_count: 0})
      refute Core.can_retry?(mechanism, %{retry_count: 1})
    end
  end
end
