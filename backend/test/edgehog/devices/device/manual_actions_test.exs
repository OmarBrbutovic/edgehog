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

defmodule Edgehog.Devices.Device.ManualActionsTest do
  use ExUnit.Case, async: true

  alias Edgehog.Devices.Device.ManualActions.SendApplicationCommand
  alias Edgehog.Devices.Device.ManualActions.SetLedBehavior

  describe "SetLedBehavior.update/3 error paths" do
    test "returns error for unknown led behavior" do
      changeset = %Ash.Changeset{
        arguments: %{behavior: :unknown_behavior},
        data: %{}
      }

      assert {:error, "Unknown led behavior"} == SetLedBehavior.update(changeset, [], %{})
    end
  end

  describe "SendApplicationCommand.update/3 error paths" do
    test "returns error for unknown deployment command" do
      changeset = %Ash.Changeset{
        arguments: %{command: :unknown_command, release: nil},
        data: %{}
      }

      assert {:error, "Unknown deployment command"} ==
               SendApplicationCommand.update(changeset, [], %{})
    end
  end
end
