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

defmodule Edgehog.Validations.ValidationModulesTest do
  use ExUnit.Case, async: true

  alias Edgehog.Validations.PEMPrivateKey
  alias Edgehog.Validations.Version, as: VersionValidation
  alias Edgehog.Validations.VersionRequirement

  @doc """
  Tests for validation modules: PEMPrivateKey, Version, VersionRequirement.
  """

  # ── PEMPrivateKey ──

  describe "PEMPrivateKey.init/1" do
    test "succeeds with atom attribute" do
      assert {:ok, [attribute: :private_key]} = PEMPrivateKey.init(attribute: :private_key)
    end

    test "fails with non-atom attribute" do
      assert {:error, "attribute must be an atom"} = PEMPrivateKey.init(attribute: "string")
    end
  end

  # ── Version ──

  describe "VersionValidation.init/1" do
    test "succeeds with atom attribute" do
      assert {:ok, [attribute: :version]} = VersionValidation.init(attribute: :version)
    end

    test "fails with non-atom attribute" do
      assert {:error, "attribute must be an atom"} = VersionValidation.init(attribute: "string")
    end
  end

  # ── VersionRequirement ──

  describe "VersionRequirement.init/1" do
    test "succeeds with atom attribute" do
      assert {:ok, [attribute: :version_requirement]} =
               VersionRequirement.init(attribute: :version_requirement)
    end

    test "fails with non-atom attribute" do
      assert {:error, "attribute must be an atom"} = VersionRequirement.init(attribute: "bad")
    end
  end
end
