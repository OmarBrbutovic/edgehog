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

defmodule Edgehog.Config.GeocodingProvidersTest do
  use ExUnit.Case, async: true

  alias Edgehog.Config.GeocodingProviders
  alias Edgehog.Geolocation.Providers.GoogleGeocoding

  describe "cast/1" do
    test "casts a comma-separated string of known providers" do
      assert {:ok, providers} = GeocodingProviders.cast("google")
      assert GoogleGeocoding in providers
    end

    test "skips unknown providers in string" do
      assert {:ok, []} = GeocodingProviders.cast("unknown")
    end

    test "handles whitespace in string" do
      assert {:ok, providers} = GeocodingProviders.cast(" google , unknown ")
      assert GoogleGeocoding in providers
      assert length(providers) == 1
    end

    test "casts a list of atoms" do
      list = [GoogleGeocoding]
      assert {:ok, ^list} = GeocodingProviders.cast(list)
    end

    test "returns error for a list with non-atoms" do
      assert :error = GeocodingProviders.cast(["not_atom"])
    end

    test "returns error for other types" do
      assert :error = GeocodingProviders.cast(42)
    end
  end
end
