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

defmodule Edgehog.Containers.ImageCredentials.Base64JsonEncodingTest do
  use ExUnit.Case, async: true

  alias Edgehog.Containers.ImageCredentials.Base64JsonEncoding

  describe "load/3" do
    test "returns required fields" do
      assert [:username, :password] = Base64JsonEncoding.load(nil, nil, nil)
    end
  end

  describe "calculate/3" do
    test "encodes username and password as base64 JSON" do
      records = [%{username: "user", password: "pass"}]

      result = Base64JsonEncoding.calculate(records, nil, nil)

      assert [encoded] = result
      decoded = Base.decode64!(encoded)
      assert is_binary(decoded)
    end

    test "handles multiple records" do
      records = [
        %{username: "user1", password: "pass1"},
        %{username: "user2", password: "pass2"}
      ]

      result = Base64JsonEncoding.calculate(records, nil, nil)
      assert length(result) == 2
    end
  end
end
