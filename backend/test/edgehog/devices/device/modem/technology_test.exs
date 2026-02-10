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

defmodule Edgehog.Devices.Device.Modem.TechnologyTest do
  use ExUnit.Case, async: true

  alias Edgehog.Devices.Device.Modem.Technology

  describe "match/1" do
    test "matches PascalCase Astarte strings" do
      assert {:ok, :gsm} = Technology.match("GSM")
      assert {:ok, :gsm_compact} = Technology.match("GSMCompact")
      assert {:ok, :utran} = Technology.match("UTRAN")
      assert {:ok, :gsm_egprs} = Technology.match("GSMwEGPRS")
      assert {:ok, :utran_hsdpa} = Technology.match("UTRANwHSDPA")
      assert {:ok, :utran_hsupa} = Technology.match("UTRANwHSUPA")
      assert {:ok, :utran_hsdpa_hsupa} = Technology.match("UTRANwHSDPAandHSUPA")
      assert {:ok, :eutran} = Technology.match("EUTRAN")
    end

    test "matches atom values" do
      assert {:ok, :gsm} = Technology.match(:gsm)
      assert {:ok, :eutran} = Technology.match(:eutran)
    end

    test "matches lowercase string values" do
      assert {:ok, :gsm} = Technology.match("gsm")
      assert {:ok, :eutran} = Technology.match("eutran")
    end

    test "returns error for unknown values" do
      assert :error = Technology.match("unknown_tech")
    end
  end
end
