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

defmodule Edgehog.Astarte.DataLayerImplementationsTest do
  use ExUnit.Case, async: true

  import Tesla.Mock

  alias Astarte.Client.RealmManagement

  defp make_rm_client do
    {:ok, client} =
      RealmManagement.new("https://api.astarte.example.com", "test_realm", jwt: "test-token")

    client
  end

  # ── Interface AstarteDataLayer ────────────────────────────────────────

  describe "Interface.AstarteDataLayer" do
    alias Edgehog.Astarte.Interface.AstarteDataLayer

    test "get/3 retrieves interface" do
      client = make_rm_client()

      mock(fn %{method: :get} ->
        json(%{"data" => %{"interface_name" => "com.example.Test", "version_major" => 1}})
      end)

      assert {:ok, _} = AstarteDataLayer.get(client, "com.example.Test", 1)
    end

    test "create/2 creates interface" do
      client = make_rm_client()

      mock(fn %{method: :post} ->
        %Tesla.Env{status: 201, body: ""}
      end)

      assert :ok = AstarteDataLayer.create(client, %{"interface_name" => "com.example.New"})
    end

    test "update/4 updates interface" do
      client = make_rm_client()

      mock(fn %{method: :put} ->
        %Tesla.Env{status: 204, body: ""}
      end)

      assert :ok = AstarteDataLayer.update(client, "com.example.Test", 1, %{})
    end
  end

  # ── Trigger AstarteDataLayer ─────────────────────────────────────────

  describe "Trigger.AstarteDataLayer" do
    alias Edgehog.Astarte.Trigger.AstarteDataLayer

    test "get/2 retrieves trigger" do
      client = make_rm_client()

      mock(fn %{method: :get} ->
        json(%{"data" => %{"name" => "test_trigger"}})
      end)

      assert {:ok, _} = AstarteDataLayer.get(client, "test_trigger")
    end

    test "list/1 lists triggers" do
      client = make_rm_client()

      mock(fn %{method: :get} ->
        json(%{"data" => ["trigger1", "trigger2"]})
      end)

      assert {:ok, _} = AstarteDataLayer.list(client)
    end

    test "create/2 creates trigger" do
      client = make_rm_client()

      mock(fn %{method: :post} ->
        %Tesla.Env{status: 201, body: ""}
      end)

      assert :ok = AstarteDataLayer.create(client, %{"name" => "new_trigger"})
    end

    test "delete/2 deletes trigger" do
      client = make_rm_client()

      mock(fn %{method: :delete} ->
        %Tesla.Env{status: 204, body: ""}
      end)

      assert :ok = AstarteDataLayer.delete(client, "test_trigger")
    end
  end

  # ── DeliveryPolicies AstarteDataLayer ─────────────────────────────────

  describe "DeliveryPolicies.AstarteDataLayer" do
    alias Edgehog.Astarte.DeliveryPolicies.AstarteDataLayer

    test "get/2 retrieves policy" do
      client = make_rm_client()

      mock(fn %{method: :get} ->
        json(%{"data" => %{"name" => "test_policy"}})
      end)

      assert {:ok, _} = AstarteDataLayer.get(client, "test_policy")
    end

    test "create/2 creates policy" do
      client = make_rm_client()

      mock(fn %{method: :post} ->
        %Tesla.Env{status: 201, body: ""}
      end)

      assert :ok = AstarteDataLayer.create(client, %{"name" => "new_policy"})
    end

    test "delete/2 deletes policy" do
      client = make_rm_client()

      mock(fn %{method: :delete} ->
        %Tesla.Env{status: 204, body: ""}
      end)

      assert :ok = AstarteDataLayer.delete(client, "test_policy")
    end
  end

  # ── Realm Calculations.RealmManagementClient ───────────────────────

  describe "Realm.Calculations.RealmManagementClient" do
    alias Edgehog.Astarte.Realm.Calculations.RealmManagementClient

    test "load/3 returns required fields" do
      assert [cluster: [:base_api_url]] = RealmManagementClient.load(nil, nil, nil)
    end

    test "calculate/3 returns client for valid realm" do
      mock(fn _ -> json(%{}) end)

      realms = [
        %{
          name: "test_realm",
          private_key: :secp256r1 |> X509.PrivateKey.new_ec() |> X509.PrivateKey.to_pem(),
          cluster: %{base_api_url: "https://api.astarte.example.com"}
        }
      ]

      results = RealmManagementClient.calculate(realms, nil, nil)
      assert [%RealmManagement{}] = results
    end

    test "calculate/3 returns nil for invalid realm data" do
      realms = [
        %{
          name: "test_realm",
          private_key: "invalid_key",
          cluster: %{base_api_url: "https://api.astarte.example.com"}
        }
      ]

      results = RealmManagementClient.calculate(realms, nil, nil)
      assert [nil] = results
    end
  end
end
