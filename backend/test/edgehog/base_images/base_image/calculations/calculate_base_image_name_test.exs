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

defmodule Edgehog.BaseImages.BaseImage.Calculations.CalculateBaseImageNameTest do
  use ExUnit.Case, async: true

  alias Edgehog.BaseImages.BaseImage.Calculations.CalculateBaseImageName

  describe "load/3" do
    test "returns required fields" do
      assert [:version, :localized_release_display_names] =
               CalculateBaseImageName.load(nil, nil, nil)
    end
  end

  describe "calculate/3" do
    test "formats name with version and display name" do
      records = [
        %{
          version: "1.0.0",
          localized_release_display_names: [%{value: "My Release"}]
        }
      ]

      assert ["1.0.0 (My Release)"] = CalculateBaseImageName.calculate(records, nil, nil)
    end

    test "handles empty display names" do
      records = [
        %{
          version: "2.0.0",
          localized_release_display_names: []
        }
      ]

      assert ["2.0.0 ()"] = CalculateBaseImageName.calculate(records, nil, nil)
    end

    test "uses first display name when multiple present" do
      records = [
        %{
          version: "3.0.0",
          localized_release_display_names: [%{value: "First"}, %{value: "Second"}]
        }
      ]

      assert ["3.0.0 (First)"] = CalculateBaseImageName.calculate(records, nil, nil)
    end
  end
end
