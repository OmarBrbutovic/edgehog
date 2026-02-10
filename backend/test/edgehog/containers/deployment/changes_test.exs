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

defmodule Edgehog.Containers.Deployment.ChangesTest do
  use ExUnit.Case, async: true

  alias Edgehog.Containers.Deployment
  alias Edgehog.Containers.Deployment.Changes.MarkAsStarting
  alias Edgehog.Containers.Deployment.Changes.MarkAsStopping

  # Build a minimal changeset-like struct that has .data and .attributes
  defp build_changeset(state) do
    # MarkAsStarting/Stopping only accesses changeset.data.state
    # and calls Ash.Changeset.change_attribute
    %Ash.Changeset{
      data: struct(Deployment, state: state),
      attributes: %{},
      resource: Deployment,
      action_type: :update
    }
  end

  describe "MarkAsStarting.change/3" do
    test "returns changeset unchanged when state is :started" do
      changeset = build_changeset(:started)
      result = MarkAsStarting.change(changeset, [], %{})
      # When already started, the exact same changeset is returned
      assert result === changeset
    end

    test "calls change_attribute when state is not :started" do
      changeset = build_changeset(:stopped)
      result = MarkAsStarting.change(changeset, [], %{})
      assert %Ash.Changeset{} = result
      # change_attribute was called, so the changeset is modified
      refute result == changeset
    end
  end

  describe "MarkAsStopping.change/3" do
    test "returns changeset unchanged when state is :stopped" do
      changeset = build_changeset(:stopped)
      result = MarkAsStopping.change(changeset, [], %{})
      assert result === changeset
    end

    test "calls change_attribute when state is not :stopped" do
      changeset = build_changeset(:started)
      result = MarkAsStopping.change(changeset, [], %{})
      assert %Ash.Changeset{} = result
      refute result == changeset
    end
  end
end
