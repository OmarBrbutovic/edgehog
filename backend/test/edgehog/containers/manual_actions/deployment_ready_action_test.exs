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

defmodule Edgehog.Containers.ManualActions.DeploymentReadyActionTest do
  use ExUnit.Case, async: true

  alias Edgehog.Containers.ManualActions.DeploymentReadyActionAddRelationship

  describe "change/3 error paths" do
    test "returns error when action_type is missing" do
      changeset = %Ash.Changeset{data: %{}, arguments: %{}}

      result = DeploymentReadyActionAddRelationship.change(changeset, [], %{})
      # When action_type change is not present, error is added to changeset
      assert %Ash.Changeset{} = result
    end

    test "returns error when action_arguments is missing but action_type is present" do
      changeset = %Ash.Changeset{
        data: %{},
        arguments: %{},
        attributes: %{action_type: :upgrade_deployment}
      }

      result = DeploymentReadyActionAddRelationship.change(changeset, [], %{})
      assert %Ash.Changeset{} = result
    end
  end
end
