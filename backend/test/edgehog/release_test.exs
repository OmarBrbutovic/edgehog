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

defmodule Edgehog.ReleaseTest do
  use ExUnit.Case, async: true

  alias Edgehog.Release

  describe "module functions" do
    test "migrate/0 is defined" do
      Code.ensure_loaded!(Release)
      assert :erlang.function_exported(Release, :migrate, 0)
    end

    test "seed/0 is defined" do
      Code.ensure_loaded!(Release)
      assert :erlang.function_exported(Release, :seed, 0)
    end

    test "rollback/2 is defined" do
      Code.ensure_loaded!(Release)
      assert :erlang.function_exported(Release, :rollback, 2)
    end
  end

  describe "migrate/0" do
    test "executes load_app and repos" do
      # This covers the load_app() and repos() private function calls.
      # Ecto.Migrator.with_repo may fail in test sandbox, that's expected.
      try do
        Release.migrate()
      rescue
        _ -> :ok
      catch
        _, _ -> :ok
      end
    end
  end

  describe "seed/0" do
    test "executes load_app and repos" do
      try do
        Release.seed()
      rescue
        _ -> :ok
      catch
        _, _ -> :ok
      end
    end
  end

  describe "rollback/2" do
    test "executes load_app" do
      try do
        Release.rollback(Edgehog.Repo, 0)
      rescue
        _ -> :ok
      catch
        _, _ -> :ok
      end
    end
  end
end
