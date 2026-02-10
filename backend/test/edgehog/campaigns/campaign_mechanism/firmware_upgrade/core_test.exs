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

defmodule Edgehog.Campaigns.CampaignMechanism.FirmwareUpgrade.CoreTest do
  use ExUnit.Case, async: true

  alias Edgehog.Campaigns.CampaignMechanism.Core
  alias Edgehog.Campaigns.CampaignMechanism.FirmwareUpgrade

  # The protocol impl module for FirmwareUpgrade
  @fw_impl Module.concat(
             Core,
             FirmwareUpgrade
           )

  defp firmware_upgrade_mechanism(attrs \\ %{}) do
    defaults = %{
      type: :firmware_upgrade,
      force_downgrade: false,
      max_failure_percentage: 10.0,
      max_in_progress_operations: 5,
      request_retries: 3,
      request_timeout_seconds: 300
    }

    struct(FirmwareUpgrade, Map.merge(defaults, attrs))
  end

  describe "needs_update?/2" do
    test "returns true when base image version is greater than target" do
      target_version = Version.parse!("1.0.0")
      base_image = %{version: "2.0.0"}

      assert @fw_impl.needs_update?(target_version, base_image)
    end

    test "returns false when versions are equal" do
      target_version = Version.parse!("1.0.0")
      base_image = %{version: "1.0.0"}

      refute @fw_impl.needs_update?(target_version, base_image)
    end

    test "returns true when versions are equal but builds differ" do
      target_version = Version.parse!("1.0.0+build1")
      base_image = %{version: "1.0.0+build2"}

      assert @fw_impl.needs_update?(target_version, base_image)
    end

    test "returns true when base image version is less than target (downgrade)" do
      target_version = Version.parse!("2.0.0")
      base_image = %{version: "1.0.0"}

      assert @fw_impl.needs_update?(target_version, base_image)
    end
  end

  describe "verify_compatibility/3" do
    test "returns :ok for upgrade without version requirement" do
      target_version = Version.parse!("1.0.0")
      base_image = %{version: "2.0.0", starting_version_requirement: nil}
      mechanism = firmware_upgrade_mechanism(%{force_downgrade: false})

      assert :ok == @fw_impl.verify_compatibility(target_version, base_image, mechanism)
    end

    test "returns :ok for upgrade matching version requirement" do
      target_version = Version.parse!("1.5.0")
      base_image = %{version: "2.0.0", starting_version_requirement: ">= 1.0.0"}
      mechanism = firmware_upgrade_mechanism(%{force_downgrade: false})

      assert :ok == @fw_impl.verify_compatibility(target_version, base_image, mechanism)
    end

    test "returns error when downgrade not allowed" do
      target_version = Version.parse!("2.0.0")
      base_image = %{version: "1.0.0", starting_version_requirement: nil}
      mechanism = firmware_upgrade_mechanism(%{force_downgrade: false})

      assert {:error, :downgrade_not_allowed} ==
               @fw_impl.verify_compatibility(target_version, base_image, mechanism)
    end

    test "returns :ok when force downgrade is enabled" do
      target_version = Version.parse!("2.0.0")
      base_image = %{version: "1.0.0", starting_version_requirement: nil}
      mechanism = firmware_upgrade_mechanism(%{force_downgrade: true})

      assert :ok == @fw_impl.verify_compatibility(target_version, base_image, mechanism)
    end

    test "returns error for ambiguous version ordering" do
      target_version = Version.parse!("1.0.0+build1")
      base_image = %{version: "1.0.0+build2", starting_version_requirement: nil}
      mechanism = firmware_upgrade_mechanism(%{force_downgrade: false})

      assert {:error, :ambiguous_version_ordering} ==
               @fw_impl.verify_compatibility(target_version, base_image, mechanism)
    end

    test "returns error when version requirement not matched" do
      target_version = Version.parse!("0.5.0")
      base_image = %{version: "2.0.0", starting_version_requirement: ">= 1.0.0"}
      mechanism = firmware_upgrade_mechanism(%{force_downgrade: false})

      assert {:error, :version_requirement_not_matched} ==
               @fw_impl.verify_compatibility(target_version, base_image, mechanism)
    end

    test "returns :ok for equal versions with same build" do
      target_version = Version.parse!("1.0.0+build1")
      base_image = %{version: "1.0.0+build1", starting_version_requirement: nil}
      mechanism = firmware_upgrade_mechanism(%{force_downgrade: false})

      assert :ok == @fw_impl.verify_compatibility(target_version, base_image, mechanism)
    end
  end

  describe "error_message/3 via protocol" do
    test "version_requirement_not_matched" do
      mechanism = firmware_upgrade_mechanism()

      msg = Core.error_message(mechanism, :version_requirement_not_matched, "device-123")
      assert msg =~ "device-123"
      assert msg =~ "version requirement"
    end

    test "downgrade_not_allowed" do
      mechanism = firmware_upgrade_mechanism()

      msg = Core.error_message(mechanism, :downgrade_not_allowed, "device-456")
      assert msg =~ "device-456"
      assert msg =~ "downgraded"
    end

    test "ambiguous_version_ordering" do
      mechanism = firmware_upgrade_mechanism()

      msg = Core.error_message(mechanism, :ambiguous_version_ordering, "device-789")
      assert msg =~ "device-789"
      assert msg =~ "same version"
    end

    test "invalid_version" do
      mechanism = firmware_upgrade_mechanism()

      msg = Core.error_message(mechanism, :invalid_version, "device-abc")
      assert msg =~ "device-abc"
      assert msg =~ "invalid"
    end

    test "missing_version" do
      mechanism = firmware_upgrade_mechanism()

      msg = Core.error_message(mechanism, :missing_version, "device-def")
      assert msg =~ "device-def"
      assert msg =~ "null"
    end

    test "falls back to Any for unknown errors" do
      mechanism = firmware_upgrade_mechanism()

      msg = Core.error_message(mechanism, "some unknown error", "device-ghi")
      assert msg =~ "device-ghi"
      assert msg =~ "unknown error"
    end
  end

  describe "get_operation_id/2 via protocol" do
    test "returns target ota_operation_id" do
      mechanism = firmware_upgrade_mechanism()
      target = %{ota_operation_id: "ota-op-123"}

      assert "ota-op-123" == Core.get_operation_id(mechanism, target)
    end
  end

  describe "subscribe/unsubscribe via protocol" do
    test "subscribe_to_operation_updates!/2 subscribes to PubSub" do
      mechanism = firmware_upgrade_mechanism()
      operation_id = "fw-op-#{System.unique_integer([:positive])}"

      # Should not raise
      Core.subscribe_to_operation_updates!(mechanism, operation_id)
      # Clean up
      Core.unsubscribe_to_operation_updates!(mechanism, operation_id)
    end

    test "unsubscribe_to_operation_updates!/2 unsubscribes from PubSub" do
      mechanism = firmware_upgrade_mechanism()
      operation_id = "fw-op-#{System.unique_integer([:positive])}"

      Core.subscribe_to_operation_updates!(mechanism, operation_id)
      # Should not raise
      Core.unsubscribe_to_operation_updates!(mechanism, operation_id)
    end
  end

  describe "temporary_error?/2 via protocol" do
    test "connection refused is temporary" do
      mechanism = firmware_upgrade_mechanism()
      assert Core.temporary_error?(mechanism, "connection refused")
    end

    test "5xx API error is temporary" do
      mechanism = firmware_upgrade_mechanism()
      error = %Astarte.Client.APIError{status: 503, response: "Service Unavailable"}
      assert Core.temporary_error?(mechanism, error)
    end

    test "other errors are not temporary" do
      mechanism = firmware_upgrade_mechanism()
      refute Core.temporary_error?(mechanism, :some_other_error)
    end
  end
end
