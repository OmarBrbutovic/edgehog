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

defmodule Edgehog.Validations.PEMPrivateKeyEdgeTest do
  use ExUnit.Case, async: true

  alias Edgehog.Validations.PEMPrivateKey

  describe "init/1" do
    test "returns error when attribute is not an atom" do
      assert {:error, "attribute must be an atom"} = PEMPrivateKey.init(attribute: "not_an_atom")
    end
  end

  describe "validate/3" do
    test "returns :ok when attribute is not in changeset" do
      changeset = %Ash.Changeset{
        data: struct(Edgehog.Tenants.Tenant),
        attributes: %{},
        arguments: %{},
        action_type: :update
      }

      assert :ok = PEMPrivateKey.validate(changeset, [attribute: :private_key], %{})
    end
  end
end
