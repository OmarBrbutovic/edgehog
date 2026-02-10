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

defmodule Edgehog.OSManagement.OTAOperation.StatusCodeTest do
  use ExUnit.Case, async: true

  alias Edgehog.OSManagement.OTAOperation.StatusCode

  describe "match/1" do
    test "matches PascalCase strings" do
      assert {:ok, :request_timeout} = StatusCode.match("RequestTimeout")
      assert {:ok, :invalid_request} = StatusCode.match("InvalidRequest")
      assert {:ok, :update_already_in_progress} = StatusCode.match("UpdateAlreadyInProgress")
      assert {:ok, :network_error} = StatusCode.match("NetworkError")
      assert {:ok, :io_error} = StatusCode.match("IOError")
      assert {:ok, :internal_error} = StatusCode.match("InternalError")
      assert {:ok, :invalid_base_image} = StatusCode.match("InvalidBaseImage")
      assert {:ok, :system_rollback} = StatusCode.match("SystemRollback")
    end

    test "matches atom values" do
      assert {:ok, :request_timeout} = StatusCode.match(:request_timeout)
      assert {:ok, :io_error} = StatusCode.match(:io_error)
      assert {:ok, :canceled} = StatusCode.match(:canceled)
    end

    test "matches lowercase string values" do
      assert {:ok, :network_error} = StatusCode.match("network_error")
    end

    test "returns error for unknown values" do
      assert :error = StatusCode.match("bogus")
    end
  end
end
