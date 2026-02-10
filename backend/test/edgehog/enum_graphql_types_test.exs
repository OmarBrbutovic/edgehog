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

defmodule Edgehog.EnumGraphqlTypesTest do
  @moduledoc "Tests for all enum graphql_type/1 functions across the codebase"
  use ExUnit.Case, async: true

  alias Edgehog.Localization.LocalizedAttribute

  describe "graphql_type/1 returns correct types" do
    test "Forwarder.Session.Status" do
      assert :forwarder_session_status = Edgehog.Forwarder.Session.Status.graphql_type(nil)
    end

    test "Devices.Device.Types.Capability" do
      assert :device_capability = Edgehog.Devices.Device.Types.Capability.graphql_type(nil)
    end

    test "Devices.Device.LedBehavior" do
      assert :device_led_behavior = Edgehog.Devices.Device.LedBehavior.graphql_type(nil)
    end

    test "Containers.Deployment.EventType" do
      assert :deployment_event_type = Edgehog.Containers.Deployment.EventType.graphql_type(nil)
    end

    test "OSManagement.OTAOperation.Status" do
      assert :ota_operation_status = Edgehog.OSManagement.OTAOperation.Status.graphql_type(nil)
    end

    test "OSManagement.OTAOperation.StatusCode" do
      assert :ota_operation_status_code =
               Edgehog.OSManagement.OTAOperation.StatusCode.graphql_type(nil)
    end

    test "Devices.Device.Modem.Technology" do
      assert :modem_technology = Edgehog.Devices.Device.Modem.Technology.graphql_type(nil)
    end

    test "Devices.Device.Modem.RegistrationStatus" do
      assert :modem_registration_status =
               Edgehog.Devices.Device.Modem.RegistrationStatus.graphql_type(nil)
    end

    test "Devices.Device.BatterySlot.Status" do
      assert :battery_slot_status = Edgehog.Devices.Device.BatterySlot.Status.graphql_type(nil)
    end
  end

  describe "Types.Id" do
    test "graphql_input_type returns :id" do
      assert :id = Edgehog.Types.Id.graphql_input_type(nil)
    end
  end

  describe "Localization.LocalizedAttribute" do
    test "graphql_type returns :localized_attribute" do
      assert :localized_attribute = LocalizedAttribute.graphql_type(nil)
    end

    test "graphql_input_type returns :localized_attribute_input" do
      assert :localized_attribute_input =
               LocalizedAttribute.graphql_input_type(nil)
    end
  end
end
