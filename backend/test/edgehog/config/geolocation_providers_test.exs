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

defmodule Edgehog.Config.GeolocationProvidersTest do
  use ExUnit.Case, async: true

  alias Edgehog.Config.GeolocationProviders
  alias Edgehog.Geolocation.Providers.DeviceGeolocation

  describe "cast/1" do
    test "casts a comma-separated string of known providers" do
      assert {:ok, providers} = GeolocationProviders.cast("device,ipbase,google")
      assert DeviceGeolocation in providers
      assert Edgehog.Geolocation.Providers.IPBase in providers
      assert Edgehog.Geolocation.Providers.GoogleGeolocation in providers
    end

    test "skips unknown providers in string" do
      assert {:ok, providers} = GeolocationProviders.cast("device,unknown")
      assert DeviceGeolocation in providers
      assert length(providers) == 1
    end

    test "casts a list of atoms" do
      list = [DeviceGeolocation]
      assert {:ok, ^list} = GeolocationProviders.cast(list)
    end

    test "returns error for a list with non-atoms" do
      assert :error = GeolocationProviders.cast(["not_atom"])
    end

    test "returns error for other types" do
      assert :error = GeolocationProviders.cast(42)
    end
  end
end
