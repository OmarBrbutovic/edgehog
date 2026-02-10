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

defmodule Edgehog.Groups.DeviceGroup.ValidationsTest do
  use ExUnit.Case, async: true

  alias Edgehog.Groups.DeviceGroup.Validations.ChannelAbsent
  alias Edgehog.Groups.DeviceGroup.Validations.DeploymentChannelAbsent

  describe "DeploymentChannelAbsent" do
    test "returns ok when deployment_channel_id is nil" do
      changeset = %Ash.Changeset{
        data: %{deployment_channel_id: nil, name: "test-group"}
      }

      assert :ok == DeploymentChannelAbsent.validate(changeset, [], %{})
    end

    test "returns error when deployment_channel_id is set" do
      changeset = %Ash.Changeset{
        data: %{deployment_channel_id: "some-id", name: "test-group"}
      }

      assert {:error, _} = DeploymentChannelAbsent.validate(changeset, [], %{})
    end
  end

  describe "ChannelAbsent" do
    test "returns ok when channel_id is nil" do
      changeset = %Ash.Changeset{
        data: %{channel_id: nil, name: "test-group"}
      }

      assert :ok == ChannelAbsent.validate(changeset, [], %{})
    end

    test "returns error when channel_id is set" do
      changeset = %Ash.Changeset{
        data: %{channel_id: "some-id", name: "test-group"}
      }

      assert {:error, _} = ChannelAbsent.validate(changeset, [], %{})
    end
  end
end
