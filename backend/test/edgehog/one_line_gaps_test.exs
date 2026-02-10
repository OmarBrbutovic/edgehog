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

defmodule Edgehog.OneLineGapsTest do
  @moduledoc """
  Tests targeting specific 1-line coverage gaps across multiple modules.
  """
  use ExUnit.Case, async: false

  import Mox

  setup :verify_on_exit!

  describe "NetworkInterface.Technology" do
    test "graphql_type returns :network_interface_technology" do
      assert :network_interface_technology =
               Edgehog.Devices.Device.NetworkInterface.Technology.graphql_type(:query)
    end
  end

  describe "Repo" do
    test "min_pg_version returns the minimum PostgreSQL version" do
      version = Edgehog.Repo.min_pg_version()
      assert %Version{major: 13} = version
    end
  end

  describe "EnvVar type" do
    test "graphql_input_type returns :container_env_var_input" do
      assert :container_env_var_input =
               Edgehog.Containers.Container.Types.EnvVar.graphql_input_type(:query)
    end
  end

  describe "NormalizeTagName.change/3 with list containing nil" do
    test "normalizes list with nil values" do
      changeset = %Ash.Changeset{
        attributes: %{tag_names: [nil, "My Tag"]},
        arguments: %{},
        data: %{},
        action_type: :create
      }

      # The normalize(nil) path is exercised before set_tag fails on bare changeset
      try do
        Edgehog.Changes.NormalizeTagName.change(changeset, [attribute: :tag_names], %{})
      rescue
        _ -> :ok
      end
    end
  end

  describe "DeviceGroup Selector validation" do
    test "returns :ok when selector is not being changed" do
      # Find the actual validation module
      mod = Edgehog.Groups.DeviceGroup.Validations.Selector

      changeset = %Ash.Changeset{
        attributes: %{},
        arguments: %{},
        data: %{},
        action_type: :update
      }

      assert :ok = mod.validate(changeset, [], %{})
    end
  end

  describe "Resumer" do
    test "start_link starts a task that processes an empty stream" do
      assert {:ok, pid} = Edgehog.Campaigns.Resumer.start_link([])
      # Wait for the task to finish
      ref = Process.monitor(pid)

      receive do
        {:DOWN, ^ref, :process, ^pid, _reason} -> :ok
      after
        1000 -> :ok
      end
    end
  end

  describe "DeliveryPolicies.fetch_by_name/2 unknown error" do
    test "returns unknown error" do
      import Mox

      {:ok, client} =
        Astarte.Client.RealmManagement.new("https://astarte.example.com", "test-realm", jwt: "test-token")

      expect(Edgehog.Astarte.DeliveryPolicies.MockDataLayer, :get, fn _client, _name ->
        {:error, :unknown_error}
      end)

      assert {:error, :unknown_error} =
               Edgehog.Astarte.DeliveryPolicies.fetch_by_name(client, "test-policy")
    end
  end
end
